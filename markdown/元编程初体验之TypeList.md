typelist和普通的list相似，只不过全是对类型的操作，而且是在编译期，第一次体验到对模板技法的应用，基本全是递归，拗口难懂，写完看着还差不多像个样子

```c++
#include <iostream>
#include <cxxabi.h>

struct NullType {};

/*
 * TypeList
 * */
template <typename...> struct TypeList;

template <typename Head, typename... Tail>
struct TypeList<Head, Tail...> {
    typedef Head head;
    typedef TypeList<Tail...> tails;
};

template <>
struct TypeList<> {
    typedef NullType head;
};

/*
 * length
 * */
template <typename> struct Length;

template <typename Head, typename... Tail>
struct Length<TypeList<Head, Tail...>> {
    enum { value = Length<TypeList<Tail...>>::value + 1 };
};

template <>
struct Length<TypeList<>> {
    enum { value = 0 };
};

/*
 * IndexOf
 * */
template <typename, typename> struct IndexOf;

template <typename Head, typename... Tail, typename T>
struct IndexOf<TypeList<Head, Tail...>, T> {
    using Result = IndexOf<TypeList<Tail...>, T>;
    enum { value = Result::value == -1 ? -1 : Result::value + 1 };
};

template <typename... Tail, typename T>
struct IndexOf<TypeList<T, Tail...>, T> {
    enum { value = 0 };
};

template <typename T>
struct IndexOf<TypeList<>, T> {
    enum { value = -1 };
};

/*
 * TypeAt
 * */
template <typename, size_t> struct TypeAt;

template <typename Head, typename... Tail, size_t i>
struct TypeAt<TypeList<Head, Tail...>, i> {
    static_assert(i < sizeof...(Tail), "i beyond the scope");
    typedef typename TypeAt<TypeList<Tail...>, i - 1>::type type;
};

template <typename Head, typename... Tail>
struct TypeAt<TypeList<Head, Tail...>, 0> {
    typedef Head type;
};

/*
 * Append
 * */
template <typename, typename> struct Append;

template <typename... TL, typename T>
struct Append<TypeList<TL...>, T> {
    typedef TypeList<TL..., T> Result;
};

template <typename... TL1, typename... TL2>
struct Append<TypeList<TL1...>, TypeList<TL2...>> {
    typedef TypeList<TL1..., TL2...> Result;
};

/*
 * Erase
 * */
template <typename> struct Erase;

template <typename Head, typename... Tail>
struct Erase<TypeList<Head, Tail...>> {
    typedef TypeList<Tail...> Result;
};

template <>
struct Erase<TypeList<>> {
    typedef NullType Result;
};


int main() {
    using namespace std;

    using TL1 = TypeList<int, char, double>;

    cout << Length<TL1>::value << endl;

    cout << IndexOf<TL1, char>::value << endl;

    cout << abi::__cxa_demangle(typeid(TypeAt<TL1, 0>::type).name(), nullptr, nullptr, nullptr) << endl;

    using AppendType1 = Append<TL1, int>::Result;
    cout << Length<AppendType1>::value << endl;
    using TL2 = TypeList<string, int>;
    using AppendType2 = Append<TL1, TL2>::Result;
    cout << Length<AppendType2>::value << endl;

    using EraseType = Erase<TL1>::Result;
    cout << abi::__cxa_demangle(typeid(EraseType).name(), nullptr, nullptr, nullptr) << endl;
}
```
