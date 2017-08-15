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
