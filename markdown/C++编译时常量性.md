## 哪些地方需要编译时常量
常量表示该值不可修改，通常是通过const关键字修饰，比如`const int i = 3;`，但const描述的是`运行时常量性`的概念，即具有运行时数据的不可更改性。

但有的时候需要的却是编译时期的常量性，可以在编译时进行值计算，在没有`constexpr`之前可以使用`define`定义编译时常量

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

## C++11 constexpr
`constexpr`，即常量表达式

```c++
constexpr int getCompileConst() {return 1;}
```

有了`constexpr`，编译器就可以在编译时期对`getCompileConst`表达式进行值计算(evaluation)，从而将其视为一个编译时期的常量

## 常量表达式函数
通常可以在函数返回类型前加入关键字`constexpr`来使其成为常量表达式函数，但常量表达式函数要求非常严格：
>* 函数体内只有一条语句，且该条语句必须是返回语句，`static_assert``using``typedef`通常不会造成问题
>* 常量表达式必须返回值
>* 常量表达式函数在使用前必须被定义，而不只是函数声明，函数调用与值计算
>* 返回的常量表达式中，不能使用非常量表达式的函数

## 常量表达式值
```c++
const int i = 1;
constexpr int j = 1;
```
两者在大多数情况下是没有区别的。不过有一点，就是如果i在全局名字空间中，编译器一定会为i产生数据。而对于j，如果不是有代码显示地使用了它的地址，编译器可以选择不为它产生数据，而仅将其当做编译时期的值，好像光有名字没有产生数据的枚举值，以及不会产生数据的右值字面量。事实上，也都只是编译时期的常量

## 常量表达式构造函数
```c++
struct MyType{
  constexpr MyType(int x):i(x){}
  int i;
};
constexpr MyType mt = {0};
```
常量表达式构造函数必须满足一下两点：
>* 函数体必须为空
>* 初始化列表只能由常量表达式赋值

## 参考资料
《深入理解C++11-C++ 11新特性解析与应用》
