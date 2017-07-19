
## gdb使用技巧
### 每行打印一个结构体成员
可以执行“set print pretty on”命令，这样每行只会显示结构体的一名成员，而且还会根据成员的定义层次进行缩进

### 打印内存的值
gdb中使用“x”命令来打印内存的值，格式为“x/nfu addr”。含义为以f格式打印从addr开始的n个长度单元为u的内存值。参数具体含义如下：

a）n：输出单元的个数。

b）f：是输出格式。比如x是以16进制形式输出，o是以8进制形式输出,等等。

c）u：标明一个单元的长度。b是一个byte，h是两个byte（halfword），w是四个byte（word），g是八个byte（giant word）。

### c++flit mangling_name
linux从name mangling后的名字来找原函数的方法
