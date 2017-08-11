## 变长函数
C++11已经支持了C99的变长宏
```c++
#include <stdio.h>
#include <stdarg.h>

double sum_of_float(int argc, ...) {
  va_list ap;
  double sum = 0;
  va_start(ap, argc); //获得变长参数句柄 argv
  for (int i = 0; i < argc; i++) {
    sum += va_arg(ap, double); //每次获得一个参数
  }
  va_end(argv);
  
  return sum;
}
```

变长函数的第一个参数argc表示的是变长参数的个数，这必须由sum_of_float的调用者传进来。而在函数中需要通过一个类型为va_list的数据结构argv来辅助地获得参数

![20170811222450](http://oowjr8zsi.bkt.clouddn.com/QQ%E6%88%AA%E5%9B%BE20170811222450.png)

整个机制设计上变长函数本身完全无法知道参数数量或者参数类型

C++引入了一种变长参数的实现方式，即类型和变量同时能够传递给变长参数的函数，一个好的方式就是使用C++的模板

## 变长模板
```c++
template<typename... Elements>class tuple;
```

在标识符elements之前使用了省略号来表示该参数是变长的。在C++11中被称作是一个`模板参数包`

一个模板参数包在模板推导时会被认为是模板的单个参数(虽然实际上它将会打包任意数量的实参)。为了使用模板参数包，总是需要将其解包。在C++11中，通常是通过一个名为包扩展的表达式来完成

```c++
template<typename... Elements> class tuple; //变长模板的声明

template<typename Head, typename... Tail> //递归的偏特化定义
class tuple<Head, Tail...> : private tuple<Tail...> {
 Head head;
};

template<> class tuple<> {}; //边界条件
```
用变长模板实现`tuple`的一种方式，这个思路是使用数学的归纳法，转换为计算机能够实现的手段则是递归。通过定义递归的模板偏特化定义，可以使得模板参数包在实例化时能够层层展开，直到参数包中的参数逐渐耗尽或到达某个数量的边界为止


在C++11中，标准定义了7中参数包可以展开的位置：
>* 表达式
>* 初始化列表
>* 基类描述列表
>* 类成员初始化列表
>* 模板参数列表
>* 通用属性列表
>* lambda函数的捕捉列表

语言的其他地方则无法展开参数包

## 参考资料

《深入理解C++11-新特性解析与应用》
