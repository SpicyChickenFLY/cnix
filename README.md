# 写一个操作系统

## 启动程序boot

###  编写启动程序的汇编源文件
1. 声明程序开始内存地址
2. 设置屏幕为文本模式
3. 初始化段寄存器
4. 显示文本
5. 阻塞程序
6. 填充剩余内存并设置结尾符号

### 编译源码
```bash
nasm -f bin boot.asm -o boot.bin
```

### 创建镜像
```bash
bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat master.img

bximage \
    -q \ #
    -hd=16 \ # 块设备大小为16MB
    -func=create \ # 要创建镜像
    -sectsize=512 \ # 一个块设备的扇区的大小为512KB
    -imgmode=flat \ # 镜像是个普通文件
    master.img # 镜像名
# ata0-master: type=disk, path="master.img", mode=flat
```
### 镜像写入主引导扇区
```bash
# if    输入文件
# of    输出文件
# bs    扇区大小
# count 扇区数目
# conv  不截断img
dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc
```

### 配置bochs
ata0-master: type=disk, path="master.img", mode=flat

### 运行启动程序
```bash
bochs.exe -q -f ./bochsrc.bxrc
```

### 开机流程
* BIOS加电自检（POST）
* 寻找启动盘（如果起始扇区以0xaa55结束，认定为引导盘）
* 读取并跳转主引导扇区0x7c00处，并将控制权交由引导程序

### 主引导扇区
通常一个扇区容量为512B - 主引导扇区结构：
* 代码： 446B
* 硬盘分区表： 64B = 4 *  16B （最多四个主分区，每个分区信息16字节）
* 魔数(Magic Number)： 0xaa55 (2B)
其功能为:
* 读取内核加载器（bootloader）并执行

### 实模式（8086模式）16位、保护模式

#### 实模式
由于早期，CPU只有20位地址线，20位只能表示2^20个地址，因此地址空间为1MB；而通用寄存器只有16位。
因此需要通过16位寄存器访问20位内存地址，这种方式称为**实模式**:
* 实模式的地址是真实的物理地址
* CPU复位（reset）或加电（power on）的时候以实模式启动

实模式寻址方式:
由`16位段寄存器`的内容乘以`进制数`作为`段基地址`，加上16位`偏移地址`形成`20位物理地址`
> 有效地址 = 段地址 * 进制数（16） + 偏移地址
```nasm
mov ax, 0xb800 ; screen memory
mov ds, ax
mov byte[0] , 'h'
;;; EA = 0xb800 * 0x10 + 0 = 0xb8000
```

#### 保护模式
现在CPU有32位地址线，地址空间为4GB，实模式方式访问就不够了


### 实模式下打印字符串
* ah : 0x0e
* al : 字符
* int 0x10
