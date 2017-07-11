# libev源码分析 - 从官方例程角度入手

阅读源码之前首先整理了一下手头阅读源码的工具，以visual studio code为主，然后用understand生成了几张调用图辅助源码分析。

先说一个vs code阅读源码的小技巧，在linux上 `Ctrl+ 鼠标左键` 可以轻松跳转到代码定义的地方，撤销跳转即返回到跳转前的位置，快捷键为 `Ctrl + Alt + -`，有了这两个快捷键可以轻松的在阅读源码的时候来回跳转，查看结构体以及函数的原型。

understand生成的UML调用图
![UMLClassDiagram](http://oowjr8zsi.bkt.clouddn.com/UMLClassDiagram.png)

## 前言  
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

1. 将全局对象ev_default_loop_ptr即ev_loop的指针初始化为默认loop`static struct ev_loop default_loop_struct;`的地址
