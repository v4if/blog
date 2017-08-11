## 哪些地方需要编译时常量
常量表示该值不可修改，通常是通过const关键字修饰，比如`const int i = 3;`，但const描述的是`运行时常量性`的概念，即具有运行时数据的不可更改性。

但有的时候需要的却是编译时期的常量性，在没有`constexpr`之前可以使用`define`定义编译时常量

```c++
#define N 1

int arr[N] = {0}; //初始化数组

enum {e1 = N, e2}; //匿名枚举

switch (cond) { //switch-case
  case N: break;
  default: break;
}

template<int i = N> //模板函数的默认模板参数
void func_args_template(){}
```
