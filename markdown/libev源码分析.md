# libev源码分析 - 从官方例程角度入手

阅读源码之前首先整理了一下手头阅读源码的工具，以visual studio code为主，然后用understand生成了几张调用图辅助源码分析。在分析出大概框架之后可以利用clion配合gdb动态跟进官方的例程进行单步调试验证自己的分析是否正确，进一步理清自己的思路。在分析的时候最好分析出来一部分然后先写出来，一是有助于后面的分析，在后面分析的时候可以结合前面已经写的内容，二是全盘分析结束之后前面有的细节可能会遗忘，如果发现前面分析有误还可以进一步修改

先说一个vs code阅读源码的小技巧，在linux上 `Ctrl+ 鼠标左键` 可以轻松跳转到代码定义的地方，撤销跳转即返回到跳转前的位置，快捷键为 `Ctrl + Alt + -`，有了这两个快捷键可以轻松的在阅读源码的时候来回跳转，查看结构体以及函数的原型。

understand生成的UML调用图
![UMLClassDiagram](http://oowjr8zsi.bkt.clouddn.com/UMLClassDiagram.png)

## 前言  
主要分析`ev.c`、`ev.h`和`ev_epoll.c`文件，8000行左右的代码量 

### 编译阶段打印宏的内容
```c++
//首先定义两个辅助宏
#define   PRINT_MACRO_HELPER(x) #x  // 把参数x转化成字符串
#define   PRINT_MACRO(x) #x "=" PRINT_MACRO_HELPER(x)  // 宏展开
//编译阶段打印宏内容
#pragma message(PRINT_MACRO(EV_API_DECL))
```

主要记住这几个宏的含义：
```c++
// 用于ev_loop指针变量声明
# define EV_P  struct ev_loop *loop               /* a loop as sole parameter in a declaration */
// loop_ptr作为第一个形参，用于函数声明
# define EV_P_ EV_P,                              /* a loop as first of multiple parameters */
// 代指loop
# define EV_A  loop                               /* a loop as sole argument to a function call */
// loop_ptr作为第一个实参，用于函数声明
# define EV_A_ EV_A,                              /* a loop as first of multiple arguments */
```

### Reactor模式

![Reactor_Structures](http://oowjr8zsi.bkt.clouddn.com/Reactor_Structures.png)

### 官方例程
```c++
// a single header file is required
#include <ev.h>
#include <stdio.h> // for puts
// every watcher type has its own typedef'd struct
// with the name ev_TYPE
ev_io stdin_watcher;  // IO事件
ev_timer timeout_watcher; // 定时器事件
// all watcher callbacks have a similar signature
// this callback is called when data is readable on stdin
static void
stdin_cb (EV_P_ ev_io *w, int revents)
{
    puts ("stdin ready");
    // for one-shot events, one must manually stop the watcher
    // with its corresponding stop function.
    ev_io_stop (EV_A_ w);
    // this causes all nested ev_run's to stop iterating
    ev_break (EV_A_ EVBREAK_ALL);
}
// another callback, this time for a time-out
static void
timeout_cb (EV_P_ ev_timer *w, int revents)
{
    puts ("timeout");
    // this causes the innermost ev_run to stop iterating
    ev_break (EV_A_ EVBREAK_ONE);
}

int
main (void)
{
    // use the default event loop unless you have special needs
    struct ev_loop *loop = EV_DEFAULT;
    // initialise an io watcher, then start it
    // this one will watch for stdin to become readable
    ev_io_init (&stdin_watcher, stdin_cb, /*STDIN_FILENO*/ 0, EV_READ);  // 设置对stdin_watcher这个fd关注读事件，并指定回调函数
    ev_io_start (loop, &stdin_watcher);  // // 激活stdin_watcher这个fd，将其设置到loop中
    // initialise a timer watcher, then start it
    // simple non-repeating 5.5 second timeout
    ev_timer_init (&timeout_watcher, timeout_cb, 5.5, 0.); //设置一个定时器，并指定一个回调函数，这个timer只执行一次，5.5s后执行
    ev_timer_start (loop, &timeout_watcher); //激活这个定时器，将其设置到loop中

    // now wait for events to arrive
    ev_run (loop, 0);
    // break was called, so exit
    return 0;
}
```

## ev_loop
`# define EV_DEFAULT  ev_default_loop (0)          /* the default loop as sole arg */`

```c++
#if EV_MULTIPLICITY
struct ev_loop * ecb_cold
#else
int
#endif
ev_default_loop (unsigned int flags) EV_THROW
{
  if (!ev_default_loop_ptr)
    {
#if EV_MULTIPLICITY
      EV_P = ev_default_loop_ptr = &default_loop_struct;
#else
      ev_default_loop_ptr = 1;
#endif

      loop_init (EV_A_ flags);

      if (ev_backend (EV_A))
        {
#if EV_CHILD_ENABLE
          ev_signal_init (&childev, childcb, SIGCHLD);
          ev_set_priority (&childev, EV_MAXPRI);
          ev_signal_start (EV_A_ &childev);
          ev_unref (EV_A); /* child watcher should not keep loop alive */
#endif
        }
      else
        ev_default_loop_ptr = 0;
    }

  return ev_default_loop_ptr;
}
```
看这段代码的时候一直在疑惑`ev_default_loop_ptr`是从哪里来的，怎么变量没有声明就将default_loop_struct地址赋值过去了。。。

玄机都隐藏在下面的代码中：

`EV_API_DECL struct ev_loop *ev_default_loop_ptr = 0; /* needs to be initialised to make it a definition despite extern */`

注意：既指定的了关键字extern又指定了一个显示的初始值的全局对象的声明，将被视为该对象的定义!

即这里是定义！定义了一个ev_loop的指针并初始化为0

因此`ev_default_loop_ptr`是一个在`ev.c`文件中定义的全局变量！

ev_default_loop(0)主要的工作是：

1. 将全局对象ev_default_loop_ptr即ev_loop的指针初始化为默认loop`static struct ev_loop default_loop_struct;`的地址，初始化ev_loop结构体字段
2. 在linux下将backend即同步事件分离器初始化为epoll，IO多路复用。可以同时监听多个文件句柄，从而提高系统的并发性，但是epoll本身是阻塞的
```c++
#if EV_USE_EPOLL
      if (!backend && (flags & EVBACKEND_EPOLL )) backend = epoll_init  (EV_A_ flags);
#endif
```

## ev_io
ev_watcher结构体

![2017-07-12_09-58-57](http://oowjr8zsi.bkt.clouddn.com/2017-07-12_09-58-57.png)

ev_watcher_list
```c++
#define EV_WATCHER_LIST(type)			\
  EV_WATCHER (type)				\
  struct ev_watcher_list *next; /* private */
```

ev_io
```c++
/* invoked when fd is either EV_READable or EV_WRITEable */
/* revent EV_READ, EV_WRITE */
typedef struct ev_io
{
  EV_WATCHER_LIST (ev_io)

  int fd;     /* ro */
  int events; /* ro */
} ev_io;
```

### ev_io_init
```c++
#define ev_io_init(ev,cb,fd,events)          do { ev_init ((ev), (cb)); ev_io_set ((ev),(fd),(events)); } while (0)

/* these may evaluate ev multiple times, and the other arguments at most once */
/* either use ev_init + ev_TYPE_set, or the ev_TYPE_init macro, below, to first initialise a watcher */
#define ev_init(ev,cb_) do {			\
  ((ev_watcher *)(void *)(ev))->active  =	\
  ((ev_watcher *)(void *)(ev))->pending = 0;	\
  ev_set_priority ((ev), 0);			\
  ev_set_cb ((ev), cb_);			\
} while (0)

#define ev_io_set(ev,fd_,events_)            do { (ev)->fd = (fd_); (ev)->events = (events_) | EV__IOFDSET; } while (0)
```
使用`do{}while(0)`可以很好的包裹宏展开

初始化的时候很好的利用了ev_io中ev_watcher_list在结构体顶部，ev_watcher在ev_watcher_list顶部，有一个指针的向上强转
```c++
  ((ev_watcher *)(void *)(ev))->active  =	\
  ((ev_watcher *)(void *)(ev))->pending = 0;	\
```

事件默认优先级为0

### ev_io_start
```c++
void noinline
ev_io_start (EV_P_ ev_io *w) EV_THROW
{
  int fd = w->fd;

  if (expect_false (ev_is_active (w)))
    return;

  assert (("libev: ev_io_start called with negative fd", fd >= 0));
  assert (("libev: ev_io_start called with illegal event mask", !(w->events & ~(EV__IOFDSET | EV_READ | EV_WRITE))));

  EV_FREQUENT_CHECK;

  ev_start (EV_A_ (W)w, 1); // [1]
  array_needsize (ANFD, anfds, anfdmax, fd + 1, array_init_zero);
  wlist_add (&anfds[fd].head, (WL)w); // [2]

  /* common bug, apparently */
  assert (("libev: ev_io_start called with corrupted watcher", ((WL)w)->next != (WL)w));

  fd_change (EV_A_ fd, w->events & EV__IOFDSET | EV_ANFD_REIFY);
  w->events &= ~EV__IOFDSET;

  EV_FREQUENT_CHECK;
}
```
`expect_false`中用到了GCC内建函数`__builtin_expect()`

`#define ecb_expect_false(expr) ecb_expect (!!(expr), 0)`

 > 由于大部分程序员在分支预测方面做得很糟糕，所以 GCC 提供了这个内建函数来帮助程序员处理分支预测，优化程序。其第一个参数 exp 为一个整型表达式，这个内建函数的返回值也是这个 exp ，而 c 为一个编译期常量。这个函数的语义是：你期望 exp 表达式的值等于常量 c ，从而 GCC 为你优化程序，将符合这个条件的分支放在合适的地方。

 > 现在处理器都是流水线的，有些里面有多个逻辑运算单元，系统可以提前取多条指令进行并行处理，但遇到跳转时，则需要重新取指令，这相对于不用重新去指令就降低了速度。所以就引入了 __builtin_expect，目的是增加条件分支预测的准确性，cpu 会提前装载后面的指令，遇到条件转移指令时会提前预测并装载某个分 支的指令。确认该条件是极少发生的，还是多数情况下会发生。编译器会产生相应的代码来优化 cpu 执行效率。 

1. 调整ev_watcher的优先级，设置active为1，将loop的activecnt++递增，即当前loopptr上挂了多少个激活的ev_watcher
2. 将ev_watcher_list挂载到loop.anfds.head上

## ev_run
整个loop事件循环的主体
```c++
do{
	xxxx;
	backend_poll(); // [1]
	EV_INVOKE_PENDING // [2]
}while(condition_is_ok)
```
1. fd上的watcher如果监听的事件event和epoll得到的revent一致，则将该watcher添加到loopptr->pendings[pri][pendingcnt]上，loopptr->pendings是一个指针数组，相当于在第二维上动态的二维数组
2. ev_invoke_pending对应调度器dipatcher，从后到前依次调用挂在pendings上的回调

相关数据结构如下：

![215034_LAfF_917596](http://oowjr8zsi.bkt.clouddn.com/215034_LAfF_917596.png)

## 总结
> libev整个事件模型的框架是： 取得一个合适的时间，用这个时间去poll。然后标记poll之后pending的文件对象。poll出来后判断定时器然后统一处理pending对象

### 关于anfds
libev在关联fd和watcher的时候利用了fd作为下标，然后挂了watcher_list

> 从alloc_fd的实现上看，一般情况下，Linux每次都从上一次分配的fd（利用文件表中的一个变量next_fd记录），来开始查找未用的文件描述符。这样保证新分配的文件描述符都是持续增长的，直到上限，然后回绕。
close的内核实现，它调用__put_unused_fd用于释放文件描述符。
```c++
static void __put_unused_fd(struct files_struct *files, unsigned int fd)
{
  struct fdtable *fdt = files_fdtable(files);
  __FD_CLR(fd, fdt->open_fds);
  if (fd < files->next_fd)
  files->next_fd = fd;
}
```
从上面的代码中，可以发现，当释放的fd比文件表中的nextfd小的话，nextfd就会更新为当前fd。
结合alloc_fd的代码，进一步得到Linux文件描述符的选择策略。当持有的文件描述符关闭时，Linux会尽快的重用该文件描述符，而不是使用递增的文件描述符值

因此在anfds上可能会存在空洞，也存在文件描述符重用之后没有更新watcher的隐患

### 同步异步、阻塞非阻塞
> 同步和异步
同步和异步是针对应用程序和内核的交互而言的，同步指的是用户进程触发I/O操作并等待或者轮询的去查看I/O操作是否就绪，而异步是指用户进程触发I/O操作以后便开始做自己的事情，而当I/O操作已经完成的时候会得到I/O完成的通知。

> 阻塞和非阻塞
阻塞和非阻塞是针对于进程在访问数据的时候，根据I/O操作的就绪状态来采取的不同方式，说白了是一种读取或者写入操作函数的实现方式，阻塞方式下读取或者写入函数将一直等待，而非阻塞方式下，读取或者写入函数会立即返回一个状态值。

### I/O模型
同步阻塞I/O
> 在此种方式下，用户进程在发起一个I/O操作以后，必须等待I/O操作的完成，只有当真正完成了I/O操作以后，用户进程才能运行。Java传统的I/O模型属于此种方式。

同步非阻塞I/O
> 在此种方式下，用户进程发起一个I/O操作以后边可返回做其它事情，但是用户进程需要时不时的询问I/O操作是否就绪，这就要求用户进程不停的去询问，从而引入不必要的CPU资源浪费。目前Java的NIO就属于同步非阻塞I/O。

异步阻塞I/O
> 此种方式下是指应用发起一个I/O操作以后，不等待内核I/O操作的完成，等内核完成I/O操作以后会通知应用程序，这其实就是同步和异步最关键的区别，同步必须等待或者主动的去询问I/O是否完成，那么为什么说是阻塞的呢？因为此时是通过 select 系统调用来完成的，而 select 函数本身的实现方式是阻塞的，而采用 select 函数有个好处就是它可以同时监听多个文件句柄，从而提高系统的并发性。

异步非阻塞I/O
> 在此种模式下，用户进程只需要发起一个I/O操作然后立即返回，等I/O操作真正的完成以后，应用程序会得到I/O操作完成的通知，此时用户进程只需要对数据进行处理就好了，不需要进行实际的I/O读写操作，因为真正的I/O读取或者写入操作已经由内核完成了。目前Java中还没有支持此种I/O模型。
