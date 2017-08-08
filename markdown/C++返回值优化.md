当一个未命名且未绑定到任何引用的临时变量被移动或复制到一个相同的对象时，拷贝和移动构造可以被省略。当这个临时对象在被构造的时候，他会直接被构造在将要拷贝/移动到的对象。当未命名临时对象是函数返回值时，发生的省略拷贝的行为被称为RVO，"返回值优化"。

其目的是为了优化掉栈上的临时对象。

```c++
#include <iostream>

struct BigObject{
    BigObject() { std::cout << "construct.\n"; }
    BigObject(const BigObject&) { std::cout << "copy construct.\n"; }
    BigObject(BigObject&&) { std::cout << "move construct.\n"; }
    ~BigObject() { std::cout << "destruct.\n"; }
};

/*
NRVO Named Return Value Optimization
命名返回值优化
 */
BigObject foo() {
    BigObject localObj;
    std::cout << std::hex << &localObj << std::endl;
    return localObj;  
}

/*
RVO Return Value Optimization
返回值优化
 */
BigObject bar() {
    return BigObject(); 
}


int main() {
    BigObject o = foo();
    std::cout << std::hex << &o << std::endl;
    return 0;
}
/*
construct.
0x7ffd0e56deef
0x7ffd0e56deef
destruct.
 */
```

可以看到`foo`中的temp和`main`中v0所在的地址值是相同的，且只有一次构造和析构操作，因此可以看到返回的类对象直接被构造在将要拷贝/移动到的对象栈空间上。

![2e8834591ba5295d242d6da33bca839a_b](http://oowjr8zsi.bkt.clouddn.com/2e8834591ba5295d242d6da33bca839a_b.jpg)

图片来源：[知乎-什么是完整的RVO以及NRVO过程](https://www.zhihu.com/question/48964719)

在看了维基百科上关于[返回值优化](https://zh.wikipedia.org/wiki/%E8%BF%94%E5%9B%9E%E5%80%BC%E4%BC%98%E5%8C%96)的解释之后，对于函数返回类对象从实现角度，一种实现办法是在函数调用语句前在stack frame上声明一个隐藏对象，把该对象的地址隐蔽传入被调用函数，函数的返回对象直接构造或者复制构造到该地址上。

```c++
struct BigObject {};

BigObject foo() {
  BigObject ret;
  // generate ret
  return ret;
}

int main() {
  BigObject o = foo();
}
```

可能产生的代码如下：
```c++
struct BigObject {};

BigObject * foo(BigObject * _hiddenAddress) {
  BigObject ret = {};
  // copy result into hidden object
  *_hiddenAddress = ret;
  return _hiddenAddress;
}

int main() {
  BigObject _hidden; // create hidden object
  BigObject o = *foo(&_hidden); // copy the result into d
}
```

这引起了BigObject对象被复制两次，也就是上图中左侧图片描述的过程。

优化之后可能会产生如下的代码：
```c++
struct BigObject {};

void f(BigObject& ret_value) {
  BigObject localObj;
  return ret_value.BigObject::BigObject(std::move(localObj));//显式构造
}

int main() {
  BigObject o; ///这里没有使用默认构造，定义而不构造
  f(&o);
}
```

返回的类对象直接被构造在将要拷贝/移动到的对象栈空间上,只会产生一次构造/析构，优化掉了栈上的临时对象。

大部分C++编译器均支持返回值优化。在某些环境下，编译器不能执行此优化。一个常见情形是当函数依据执行路径返回不同的命名对象，或者命名对象在asm内联块中被使用
```c++
#include <iostream>

struct C {
	C(int j) { i = j; }
	C(const C&) { std::cout << "A copy was made.\n"; }

	int i;
};

C  f(bool cond = false) {
	C first(101);
	C second(102);
	// the function may return one of two named objects
	// depending on its argument. RVO might not be applied
	return cond ? first : second;
}

int main() {
	std::cout << "Hello World!\n";
	C obj = f(true);
}
```

## 参考
[维基百科-返回值优化](https://zh.wikipedia.org/wiki/%E8%BF%94%E5%9B%9E%E5%80%BC%E4%BC%98%E5%8C%96)


