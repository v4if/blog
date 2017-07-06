## Template中的class和typename
```c++
template<class T> class Test; 
template<typename T> class Test; 
```
在模板引入C++后最初定义模板的方式是用关键字`class`，表明紧跟在后面的符号是一个类型，后来为了避免在class在定义类的时候带来混淆，又引入了`typename`关键字。
在模板定义语法中关键字class与typename的作用完全一样，但是在使用嵌套依赖类型(nested depended name)时只能使用`typename`关键字。
```c++
typedef typename T::NestType NT;
```
