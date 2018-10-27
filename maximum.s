# 目的：寻找一组数据项中的最大值
# 
# 变量：
#
#	%edi —— 保存数据项索引
#	%ebx —— 保存最大值
#	%eax —— 保存当前值
#
# 使用以下内存位置：
#
# data_items —— 包含一组数据项
#		        0表示结尾
#
.section .data
data_items:	# 数据段里面的数据项
	.long 3,68,34,222,45,75,54,34,44,33,22,11,66,0

.section .text
.global _start

_start:
movl $0, %edi	# 将0置入索引寄存器
movl data_items(,%edi,4), %eax	# 将数据项第一个字置入 %eax 寄存器
movl %eax, %ebx

start_loop:	# 开始循环
cmpl $0, %eax	# 检查是否已到达数据尾
je loop_exit
incl %edi
movl data_items(,%edi,4), %eax
cmpl %ebx, %eax
jle start_loop  # 如果第二个操作数小于等于第一个操作数
movl %eax, %ebx
jmp start_loop

loop_exit:
movl $1, %eax
# 立即数千万不要忘记$前缀
int $0x80
