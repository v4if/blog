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
template<typename... elements>class tuple;
```

在标识符elements之前使用了省略号来表示该参数是变长的。在C++11中被称作是一个`模板参数包`
