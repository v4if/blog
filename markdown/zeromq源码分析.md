ZMQ (ZeroMQ简称ZMQ)是一个简单好用的传输层，像框架一样的一个socket library，他使得Socket编程更加简单、简洁和性能更高。是一个消息处理队列库，可在多个线程、内核和主机之间弹性伸缩。ZMQ的明确目标是“成为标准网络协议栈的一部分，之后进入Linux内核”。

ZeroMQ几乎所有的I/O操作都是异步的，主线程不会被阻塞。ZeroMQ会根据用户调用zmq_init函数时传入的接口参数，创建对应数量的I/O Thread。每个I/O Thread都有与之绑定的Poller，Poller采用经典的Reactor模式实现，Poller根据不同操作系统平台使用不同的网络I/O模型（select、poll、epoll、devpoll、kequeue等）。

主线程与I/O线程通过Mail Box传递消息来进行通信。Server开始监听或者Client发起连接时，在主线程中创建zmq_connecter或zmq_listener，通过Mail Box发消息的形式将其绑定到I/O线程，I/O线程会把zmq_connecter或zmq_listener添加到Poller中用以侦听读/写事件。

Server与Client在第一次通信时，会创建zmq_init来发送identity，用以进行认证。认证结束后，双方会为此次连接创建Session，以后双方就通过Session进行通信。每个Session都会关联到相应的读/写管道， 主线程收发消息只是分别从管道中读/写数据。Session并不实际跟kernel交换I/O数据，而是通过plugin到Session中的Engine来与kernel交换I/O数据。

在多线程环境中，ZMQ的使用者不必使用互斥锁，条件变量或信号等用来同步并行处理的东西。ZMQ中的每个对象只会在自己所在的线程上执行，其他线程只能通过发送消息（以下称之为“命令”，以区别于使用者发送给ZMQ的消息）与对象进行交互而不能直接使用对象（这就是为什么是不需要互斥体的原因），同时对象间也可以相互发送命令进行交互（实际上线程在ZMQ中也是一种对象）。

`我们需要关注的ZMQ对象包括：消息、套接字、上下文。`


## 消息

```c++
typedef struct zmq_msg_t {
    unsigned char _ [64];
} zmq_msg_t;
```
zmq_msg_t只是一个64字节的数组，只是相当于为msg_t开辟了空间，加了一层封装，对外隐藏了msg_t
```c++
int zmq_msg_init (zmq_msg_t *msg_)
{
    return ((zmq::msg_t*) msg_)->init ();
}
```
初始化是强转为msg_t*调用init
```c++
namespace zmq {
  class msg_t {
    private:
      union {
        ...
        struct {
          metadata_t *metadata;
          unsigned char data [max_vsm_size];
          unsigned char size;
          unsigned char type;
          unsigned char flags;
          char group [16];
          uint32_t routing_id;
        } vsm;
        struct {
          metadata_t *metadata;
          content_t *content;
          unsigned char unused [msg_t_size - (sizeof (metadata_t *) +
                                          sizeof (content_t*) +
                                          2 +
                                          16 +
                                          sizeof (uint32_t))];
          unsigned char type;
          unsigned char flags;
          char group [16];
          uint32_t routing_id;
        } lmsg;
        ...
      }u;
  }
}
int zmq::msg_t::init ()
{
    u.vsm.metadata = NULL;
    u.vsm.type = type_vsm;
    u.vsm.flags = 0;
    u.vsm.size = 0;
    u.vsm.group[0] = '\0';
    u.vsm.routing_id = 0;
    return 0;
}

int zmq::msg_t::init_size (size_t size_)
{
    if (size_ <= max_vsm_size) {
        u.vsm.metadata = NULL;
        u.vsm.type = type_vsm;
        u.vsm.flags = 0;
        u.vsm.size = (unsigned char) size_;
        u.vsm.group[0] = '\0';
        u.vsm.routing_id = 0;
    }
    else {
        u.lmsg.metadata = NULL;
        u.lmsg.type = type_lmsg;
        u.lmsg.flags = 0;
        u.lmsg.group[0] = '\0';
        u.lmsg.routing_id = 0;
        u.lmsg.content = NULL;
        if (sizeof (content_t) + size_ > size_)
            u.lmsg.content = (content_t*) malloc (sizeof (content_t) + size_);
        if (unlikely (!u.lmsg.content)) {
            errno = ENOMEM;
            return -1;
        }

        /* u.lmsg.content类型为content_t*， 故跨过content_t管理节点的内容 */
        u.lmsg.content->data = u.lmsg.content + 1;
        u.lmsg.content->size = size_;
        u.lmsg.content->ffn = NULL;
        u.lmsg.content->hint = NULL;
        new (&u.lmsg.content->refcnt) zmq::atomic_counter_t ();
    }
    return 0;
}

int zmq::msg_t::close ()
{
    //  Check the validity of the message.
    if (unlikely (!check ())) {
        errno = EFAULT;
        return -1;
    }

    if (u.base.type == type_lmsg) {

        //  If the content is not shared, or if it is shared and the reference
        //  count has dropped to zero, deallocate it.
        if (!(u.lmsg.flags & msg_t::shared) ||
              !u.lmsg.content->refcnt.sub (1)) {

            //  We used "placement new" operator to initialize the reference
            //  counter so we call the destructor explicitly now.
            u.lmsg.content->refcnt.~atomic_counter_t ();

            if (u.lmsg.content->ffn)
                u.lmsg.content->ffn (u.lmsg.content->data,
                    u.lmsg.content->hint);
            free (u.lmsg.content);
        }
    }

    if (is_zcmsg())
    {
        zmq_assert(u.zclmsg.content->ffn);

        //  If the content is not shared, or if it is shared and the reference
        //  count has dropped to zero, deallocate it.
        if (!(u.zclmsg.flags & msg_t::shared) ||
            !u.zclmsg.content->refcnt.sub (1)) {

            //  We used "placement new" operator to initialize the reference
            //  counter so we call the destructor explicitly now.
            u.zclmsg.content->refcnt.~atomic_counter_t ();

            u.zclmsg.content->ffn (u.zclmsg.content->data,
                          u.zclmsg.content->hint);
        }
    }

    if (u.base.metadata != NULL) {
        if (u.base.metadata->drop_ref ()) {
            LIBZMQ_DELETE(u.base.metadata);
        }
        u.base.metadata = NULL;
    }

    //  Make the message invalid.
    u.base.type = 0;

    return 0;
}
```

小消息直接存储在vsm中，大消息需要另外开辟空间

用u.zclmsg.content->refcnt对堆上的大消息进行引用计数，close的时候当refcnt为0时释放内存


## 套接字
```c++
void *zmq_socket (void *ctx_, int type_)
{
    if (!ctx_ || !((zmq::ctx_t *) ctx_)->check_tag ()) {
        errno = EFAULT;
        return NULL;
    }
    zmq::ctx_t *ctx = (zmq::ctx_t *) ctx_;
    zmq::socket_base_t *s = ctx->create_socket (type_);
    return (void *) s;
}

zmq::socket_base_t *zmq::ctx_t::create_socket (int type_)
{
    scoped_lock_t locker(slot_sync);

    if (unlikely (starting)) {

        starting = false;
        //  Initialise the array of mailboxes. Additional three slots are for
        //  zmq_ctx_term thread and reaper thread.
        opt_sync.lock ();
        int mazmq = max_sockets;
        int ios = io_thread_count;
        opt_sync.unlock ();
        slot_count = mazmq + ios + 2;
        slots = (i_mailbox **) malloc (sizeof (i_mailbox*) * slot_count);
        alloc_assert (slots);

        //  Initialise the infrastructure for zmq_ctx_term thread.
        slots [term_tid] = &term_mailbox;

        //  Create the reaper thread.
        reaper = new (std::nothrow) reaper_t (this, reaper_tid);
        alloc_assert (reaper);
        slots [reaper_tid] = reaper->get_mailbox ();
        reaper->start ();

        //  Create I/O thread objects and launch them.
        for (int i = 2; i != ios + 2; i++) {
            io_thread_t *io_thread = new (std::nothrow) io_thread_t (this, i);
            alloc_assert (io_thread);
            io_threads.push_back (io_thread);
            slots [i] = io_thread->get_mailbox ();
            io_thread->start ();
        }

        //  In the unused part of the slot array, create a list of empty slots.
        for (int32_t i = (int32_t) slot_count - 1;
              i >= (int32_t) ios + 2; i--) {
            empty_slots.push_back (i);
            slots [i] = NULL;
        }
    }

    //  Once zmq_ctx_term() was called, we can't create new sockets.
    if (terminating) {
        errno = ETERM;
        return NULL;
    }

    //  If max_sockets limit was reached, return error.
    if (empty_slots.empty ()) {
        errno = EMFILE;
        return NULL;
    }

    //  Choose a slot for the socket.
    uint32_t slot = empty_slots.back ();
    empty_slots.pop_back ();

    //  Generate new unique socket ID.
    int sid = ((int) max_socket_id.add (1)) + 1;

    //  Create the socket and register its mailbox.
    socket_base_t *s = socket_base_t::create (type_, this, slot, sid);
    if (!s) {
        empty_slots.push_back (slot);
        return NULL;
    }
    sockets.push_back (s);
    slots [slot] = s->get_mailbox ();

    return s;
}

zmq::socket_base_t *zmq::socket_base_t::create (int type_, class ctx_t *parent_,
    uint32_t tid_, int sid_)
{
    socket_base_t *s = NULL;
    switch (type_) {
        ...
        case ZMQ_REP:
            s = new (std::nothrow) rep_t (parent_, tid_, sid_);
            break;
        ...
        default:
            errno = EINVAL;
            return NULL;
    }

    alloc_assert (s);

    if (s->mailbox == NULL) {
        s->destroyed = true;
        LIBZMQ_DELETE(s);
        return NULL;
    }

    return s;
}

int zmq_bind (void *s_, const char *addr_)
{
    if (!s_ || !((zmq::socket_base_t*) s_)->check_tag ()) {
        errno = ENOTSOCK;
        return -1;
    }
    zmq::socket_base_t *s = (zmq::socket_base_t *) s_;
    int result = s->bind (addr_);
    return result;
}
```
根据io_thread上加载fd的数量进行负载均衡选择最小的作为当前线程，每个io_thread_t类有一个poller_t*的变量poller，当前线程的事件分离器，在linux上表现为epool，继承自zmq::poller_base_t，且zmq::poller_base_t.load成员变量load记录了当前线程上监听的fd的数量


## 上下文
```c++
void *zmq_init (int io_threads_)
{
    if (io_threads_ >= 0) {
        void *ctx = zmq_ctx_new ();
        zmq_ctx_set (ctx, ZMQ_IO_THREADS, io_threads_);
        return ctx;
    }
    errno = EINVAL;
    return NULL;
}

void *zmq_ctx_new (void)
{
    //  Create 0MQ context.
    zmq::ctx_t *ctx = new (std::nothrow) zmq::ctx_t;
    alloc_assert (ctx);
    return ctx;
}
```

new && new(std::nothrow)
> new(std::nothrow) 顾名思义，即不抛出异常，当new一个对象失败时，默认设置该对象为NULL，这样可以方便的通过if(ctx == NULL) 来判断new操作是否成功

> 普通的new操作，如果分配内存失败则会抛出异常，虽然后面一般也会写上if(ctx == NULL) 但是实际上是自欺欺人，因为如果分配成功，p肯定不为NULL；而如果分配失败，则程序会抛出异常，if语句根本执行不到。

```c++
namespace zmq {
    class ctx_t {
        //  Maximum socket ID.
        static atomic_counter_t max_socket_id;
    };
}
zmq::atomic_counter_t zmq::ctx_t::max_socket_id; /* 静态成员在使用前必须先初始化 */
```
