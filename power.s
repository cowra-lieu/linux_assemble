# 目的：展示函数如何工作的程序，使用栈帧局部变量
#	本程序将计算 2^3 + 5^2
#	计算结果作为进程退出状态码

.section .data
.section .text
.global _start
_start:	# (0)
pushl $3
pushl $2	# (1)
call power	# call将下行指令的地址入栈(2)，将符号power的值置入%eip寄存器
addl $8, %esp	# 将%esp寄存器的值还原到压入参数前(0)
pushl %eax # 后续调用将破坏%eax寄存器的值，所以这里先入栈保存(3)

pushl $2
pushl $5
call power
addl $8, %esp
popl %ebx	# 从栈顶(3)弹出一个字(旧的 %eax值)到 %ebx寄存器

addl %eax, %ebx	# 将计算结果保存到 %ebx寄存器

movl $1, %eax	# 设置系统调用号，准备退出进程
int $0x80	# 中断进程，切换CPU控制权到内核进行系统调用

# power是一个符号，带上冒号就变成一个标签，标签用它下行指令的地址给符号赋值
power:
pushl %ebp	# 将基址寄存器的当前值入栈(4)，开启一个新的栈帧
movl %esp, %ebp
subl $4, %esp	# 在当前栈帧申请一个字的空间用做局部变量，暂存返回值 (技术上，本程序的逻辑是不需要这个栈帧局部变量的，这里仅仅示范其用法的目的)

movl 8(%ebp), %ebx	# 通过基址寻址，将第一个参数置入 %ebx寄存器
movl 12(%ebp), %ecx	# 通过基址寻址，将第二个参数置入 %ecx寄存器

movl %ebx, -4(%ebp)	# 将结果保存到局部变量
power_loop_start:
cmpl $1, %ecx
je power_end
movl -4(%ebp), %eax	# 将结果变量的值提取到 %eax寄存器，因为乘法指令需要两个寄存器
imull %ebx, %eax	# 用寄存器完成乘法运算
movl %eax, -4(%ebp)	# 将乘法结果保存到结果变量
decl %ecx		# 指数减1
jmp power_loop_start	# 开始下轮循环


power_end:
movl -4(%ebp), %eax	# 将结果变量保存到 %eax寄存器
movl %ebp, %esp	# 将 %esp寄存器恢复到进入栈帧前(4)
popl %ebp	# 弹出栈顶到 %ebp寄存器，%esp寄存器上移指向(1)
ret	# 将栈顶弹出到 %eip寄存器，%esp寄存器上移指向(3)

