
## gdb使用技巧
### 每行打印一个结构体成员
可以执行“set print pretty on”命令，这样每行只会显示结构体的一名成员，而且还会根据成员的定义层次进行缩进

### 按照派生类打印对象
`set print object on`<br>
set p obj <on/off>: 在C++中，如果一个对象指针指向其派生类，如果打开这个选项，GDB会自动按照虚方法调用的规则显示输出，如果关闭这个选项的话，GDB就不管虚函数表了。这个选项默认是off。 使用show print object查看对象选项的设置。

### 查看虚函数表
在 GDB 中还可以直接查看虚函数表，通过如下设置：`set print vtbl on`<br>
之后执行如下命令查看虚函数表：`info vtbl 对象`或者`info vtbl 指针或引用所指向或绑定的对象`

### 打印内存的值
gdb中使用“x”命令来打印内存的值，格式为“x/nfu addr”。含义为以f格式打印从addr开始的n个长度单元为u的内存值。参数具体含义如下：<br>
 a）n：输出单元的个数。<br>
 b）f：是输出格式。比如x是以16进制形式输出，o是以8进制形式输出,a 表示将值当成一个地址打印,i 表示将值当作一条指令打印，等等。<br>
 c）u：标明一个单元的长度。b是一个byte，h是两个byte（halfword），w是四个byte（word），g是八个byte（giant word）。

### c++filt
GNU提供的从name mangling后的名字来找原函数的方法，如`c++filt _ZTV1A`

 
