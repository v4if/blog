# libev源码分析 - 从官方例程角度入手

阅读源码之前首先整理了一下手头阅读源码的工具，以visual studio code为主，然后用understand生成了几张调用图辅助源码分析。在分析出大概框架之后可以利用clion配合gdb动态跟进官方的例程进行单步调试验证自己的分析是否正确，进一步理清自己的思路。在分析的时候最好分析出来一部分然后先写出来，一是有助于后面的分析，在后面分析的时候可以结合前面已经写的内容，二是全盘分析结束之后前面有的细节可能会遗忘，如果发现前面分析有误还可以进一步修改

先说一个vs code阅读源码的小技巧，在linux上 `Ctrl+ 鼠标左键` 可以轻松跳转到代码定义的地方，撤销跳转即返回到跳转前的位置，快捷键为 `Ctrl + Alt + -`，有了这两个快捷键可以轻松的在阅读源码的时候来回跳转，查看结构体以及函数的原型。

understand生成的UML调用图
![UMLClassDiagram](http://oowjr8zsi.bkt.clouddn.com/UMLClassDiagram.png)

## 前言  
主要分析`ev.c`和`ev.h`文件，8000行左右的代码量 

编译阶段打印宏的内容
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
  wlist_add (&anfds[fd].head, (WL)w);

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

1. 调整ev_watcher的优先级，设置active为1，将loop的activecnt++递增，即当前io上挂了多少个激活的ev_watcher
