```c++
#include <iostream>
#include <vector>
#include <deque>
#include <typeinfo>
#include <cxxabi.h>

template <typename T,
        template<typename ELEM, typename ALLOC = std::allocator<ELEM>>
        class CONT = std::deque >
class NestTemplate{
public:
//    CONT<int> a;
    NestTemplate() {
        std::cout << abi::__cxa_demangle(typeid(CONT<T>).name(), nullptr, nullptr, nullptr) << std::endl;
    }
    template <typename N>
    void nest_func(N n) {
        std::cout << n << std::endl;
    }
};

int main() {
    NestTemplate<int> t;
//    t.nest_func(5);

    std::cout << abi::__cxa_demangle(typeid(int).name(), nullptr, nullptr, nullptr) << std::endl;

    return 0;
}
```

模板参数可以由类型、数值，类型的自动推导

嵌套模板，模板类型作为模板参数
template template argumnets(实参)必须完全匹配其对应参数

模板参数可以防止`array转为pointer`的转型动作，常被称为退化
```c++
template <typename T>
void avoid_decay_func(T& args) { //这里必须是引用传递
    std::cout << typeid(T&).name() << std::endl;
    std::cout << abi::__cxa_demangle(typeid(T&).name(), nullptr, nullptr, nullptr) << std::endl;
    std::cout << sizeof(args) << std::endl;
}
int main() {
    char type_array[10]{'0'};
    avoid_decay_func(type_array);
}
/*
A10_c
char [10]
10
*/
```
char array 与 char pointer


Template Parameters有三种类型：
>* Type parameters(类型参数)；这种参数最常用 `template <typename T>`
>* Non-type parameters(非类型参数 - 整数或枚举类型、pointer类型、reference类型)； `template <size_t N = 1>` `template <typename T, typename T::Allocator* Allocator>`
>* Template template parameters(双重模板参数) `template <typename T, template <typename ELEM, typename ALLOC = std::alloc<ELEM>> class CONT = std::vector>`
