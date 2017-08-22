# DeeppinkOS
操作系统研究，借鉴了许多《30天自制操作系统》、《一个orange操作系统的实现》和《linux内核设计的艺术》上面的代码

最开始在Windows下借鉴《30天～～～》，最后将代码移植到ubuntu下
编译环境：
系统：ubuntu16.04 64位


-------->2017.05.13
C:\kernel developer\tolset\helloos0>make

C:\kernel developer\tolset\helloos0>..\z_tools\make.exe
../z_tools/make.exe -r img
make.exe[1]: Entering directory `C:/kernel developer/tolset/helloos0'
../z_tools/make.exe -r wrwos.img
make.exe[2]: Entering directory `C:/kernel developer/tolset/helloos0'
../z_tools/nask.exe bootfirst.nas bootfirst.bin bootfirst.lst
NASK : LSTBUF is not enough
make.exe[2]: *** [bootfirst.bin] Error 19
make.exe[2]: Leaving directory `C:/kernel developer/tolset/helloos0'
make.exe[1]: *** [img] Error 2
make.exe[1]: Leaving directory `C:/kernel developer/tolset/helloos0'
..\z_tools\make.exe: *** [default] Error 2
    这个错误是没有将bootfirst后边填充数据的代码去掉，由于添加了其他代码，空间已经不过用了

-------->2017.05.14
C:\kernel developer\tolset\helloos0>make

C:\kernel developer\tolset\helloos0>..\z_tools\make.exe
../z_tools/make.exe -r img
make.exe[1]: Entering directory `C:/kernel developer/tolset/helloos0'
../z_tools/make.exe -r wrwos.img
make.exe[2]: Entering directory `C:/kernel developer/tolset/helloos0'
../z_tools/nask.exe bootfirst.nas bootfirst.bin bootfirst.lst
../z_tools/edimg.exe   imgin:../z_tools/fdimg0at.tek \
        wbinimg src:bootfirst.bin len:512 from:0 to:0 \
        copy from:bootsecond.sys to:@: \
        imgout:wrwos.img
imgout BPB data error.
make.exe[2]: *** [wrwos.img] Error 37
make.exe[2]: Leaving directory `C:/kernel developer/tolset/helloos0'
make.exe[1]: *** [img] Error 2
make.exe[1]: Leaving directory `C:/kernel developer/tolset/helloos0'
..\z_tools\make.exe: *** [default] Error 2
FAT12文件的很重要，不能随意更改其中的文件名字（只是更改名字会出错）


-------->2017.05.24
       向64h端口写入的字节，被认为是对8042芯片发布的命令（Command）： 写入的字节将会被存放Input Register中； 同时会引起Status Register的Bit-3自动被设置为1，表示现在放在Input Register中的数据是一个Command，而不是一个Data；
       在向64h端口写某些命令之前必须确保键盘是被禁止的，因为这些被写入的命令的返回结果将会放Output Register中，而键盘如果不被禁止，则也会将数据放入到Output Register中，会引起相互之间的数据覆盖；
       在向64h端口写数据之前必须确保Input Register是空的（通过判断Status Register的Bit-1是否为0）。60h端口（读操作），对60h端口进行读操作，将会读取Output Register的内容。Output Register的内容可能是：来自8048的数据。这些数据包括Scan Code，对8048发送的命令的确认字节（ACK)及回复数据。 通过64h端口对8042发布的命令的返回结果。在向60h端口读取数据之前必须确保Output Register中有数据（通过判断Status Register的Bit-0是否为1）。
       60h端口（写操作）向60h端口写入的字节，有两种可能： 
      1．如果之前通过64h端口向8042芯片发布的命令需要进一步的数据，则此时写入的字节就被认为是数据； 
      2．否则，此字节被认为是发送给8048的命令。 在向60h端口写数据之前，必须确保Input Register是空的（通过判断Status Register的Bit-1是否为0）。

-------->2017.06.21
向一个空软盘保存文件的时候,
1.文件名会写在0x2600以后的地方(这里我没有去验证);
2.文件的内容会写入到0x4200以后的地方.
决定后边的0xc200

-------->2017.06.23
      使用一般的编译器编译操作系统，不再依赖原来作者自己的编译器
>>使用linux系统，在ubuntu下选择和组合一套工具编译运行这个操作系统

2017/08/22
   当前对系统只将堆栈指针指向0x7c00，此处在C代码里边定义一个全局变量，似乎没有存储
这个全局变量的空间，如果设置成局部变量，达到了预想的效果，猜测可能是没有在链接脚本
指定全局变量空间


