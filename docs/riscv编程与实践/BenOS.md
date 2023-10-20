

### BenOS

BenOS包括MySBI和BenOS部分

#### MYSBI

MySBI是运行在M模式下的固件，为运行在S模式下的操作系统提供引导和统一的接口服务

MySBI源代码在sbi目录

##### 链接脚本

sbi/sbi_linker.ld

```LinkerScript
OUTPUT_ARCH(riscv)					# 说明处理器体系
ENTRY(_start)						# 指定入口地址_start

SECTIONS
{
	INCLUDE "sbi/sbi_base.ld"
}
```

sbi/sbi_base.ld

```
. = 0x80000000,						# 位置计数器设置为0x800000000

.text.boot : { *(.text.boot) }		# 启动时执行的代码，把_start函数链接放到0x80000000处
.text : { *(.text) }				# 代码段
.rodata : { *(.rodata) }			# 只读数据段
.data : { *(.data) }				# 数据段
. = ALIGN(0x8);						# 对齐方式按照8字节对齐
bss_begin = .;						#
.bss : { *(.bss*) } 				# 包含未初始化的全局变量和局部静态变量
bss_end = .;
```

`.=ALIGN(0x8) `的具体作用是将当前的地址或偏移量转到下一个8字节边界。例如，如果当前地址或偏移量是0x403，那么使用.=ALIGN(0x8)指令后，它将调整到0x408（下一个8字节边界）。

##### 汇编代码

sbi_boot.S

```asm
.section ".text.boot"	# sbi_boot.S文件编译链接到.text.boot段，在链接脚本中将它链接到可执行文件

.globl _start			# 指定 `_start` 标签是一个全局标签，这意味着该标签可以被其他模块或文件引用
_start:
	/* setup stack with 4KB size */
	la sp, stacks_start
	li t0, 4096
	add sp, sp, t0

	/* goto C */
	tail sbi_main

.section .data
.align  12						#将后续的数据或指令对齐
.global stacks_start			#将`stacks_start`标记为一个全局符号，表示它可以在程序的其他部分被访问到
stacks_start:
	.skip 4096					# 在内存中为后续的4096字节（4KB）分配空间，并将这段空间填充为零
```

sbi_main.c

```c
#include "asm/csr.h"

#define FW_JUMP_ADDR 0x80200000

/*
 * 运行在M模式
 */
void sbi_main(void)
{
	unsigned long val;

	/* 设置跳转模式为S模式 */
	val = read_csr(mstatus);
	val = INSERT_FIELD(val, MSTATUS_MPP, PRV_S);
	val = INSERT_FIELD(val, MSTATUS_MPIE, 0);
	write_csr(mstatus, val);

	/* 设置M模式的Exception Program Counter，用于mret跳转 */
	write_csr(mepc, FW_JUMP_ADDR);
	/* 设置S模式异常向量表入口*/
	write_csr(stvec, FW_JUMP_ADDR);
	/* 关闭S模式的中断*/
	write_csr(sie, 0);
	/* 关闭S模式的页表转换 */
	write_csr(satp, 0);

	/* 切换到S模式 */
	asm volatile("mret");
}
```

#### BenOS

目前只有串口输出功能

linker.ld

```
SECTIONS
{
	. = 0x80200000,

	.text.boot : { *(.text.boot) }
	.text : { *(.text) }
	.rodata : { *(.rodata) }
	.data : { *(.data) }
	. = ALIGN(0x8);
	bss_begin = .;
	.bss : { *(.bss*) } 
	bss_end = .;
}
```

boot.S

```asm
.section ".text.boot"

.globl _start
_start:
	/* Mask all interrupts */
	csrw sie, zero		# 将零值写入 sie 寄存器,禁用特权级别为 Supervisor 的中断

	/* set the stack of SP, size 4KB */
	la sp, stacks_start
	li t0, 4096
	add sp, sp, t0

	/* goto C */
	tail kernel_main

.section .data
.align  12
.global stacks_start
stacks_start:
	.skip 4096
```

kernel.c

```c
#include "uart.h"

void kernel_main(void)
{
	uart_init();
	uart_send_string("Welcome RISC-V!\r\n");

	while (1) {
		;
	}
}
```

接下来实现简单的串口驱动代码。QEMU使用兼容16550规范的串口控制器。

uart.c

16550串口初始化的代码

```c
#include "asm/uart.h"
#include "io.h"

void uart_send(char c)
{
	while((readb(UART_LSR) & UART_LSR_EMPTY) == 0)
		;

	writeb(c, UART_DAT);
}

void uart_send_string(char *str)
{
	int i;

	for (i = 0; str[i] != '\0'; i++)
		uart_send((char) str[i]);
}

static unsigned int uart16550_clock = 1843200;   // a common base clock
#define UART_DEFAULT_BAUD  115200

void uart_init(void)
{
	unsigned int divisor = uart16550_clock / (16 * UART_DEFAULT_BAUD);

	/* disable interrupt */
	writeb(0, UART_IER);

	/* Enable DLAB (set baud rate divisor)*/
	writeb(0x80, UART_LCR);
	writeb((unsigned char)divisor, UART_DLL);
	writeb((unsigned char)(divisor >> 8), UART_DLM);

	/*8 bits, no parity, one stop bit*/
	writeb(0x3, UART_LCR);

	/* 使能FIFO，清空FIFO，设置14字节threshold*/
	writeb(0xc7, UART_FCR);
}
```

#### makefile

```makefile
# ?=的意思是，仅当 `GNU` 还没有被定义时赋值
GNU ?= riscv64-linux-gnu				

COPS += -save-temps=obj -g -O0 -Wall -nostdlib -nostdinc -Iinclude -mcmodel=medany -mabi=lp64 -march=rv64imafd -fno-PIE -fomit-frame-pointer

board ?= qemu

ifeq ($(board), qemu)
COPS += -DCONFIG_BOARD_QEMU
else ifeq ($(board), nemu)
COPS += -DCONFIG_BOARD_NEMU
endif

##############
#  build benos
##############
BUILD_DIR = build_src
SRC_DIR = src

all : clean benos.bin mysbi.bin benos_payload.bin

# Check if verbosity is ON for build process
CMD_PREFIX_DEFAULT := @
ifeq ($(V), 1)
	CMD_PREFIX :=
else
	CMD_PREFIX := $(CMD_PREFIX_DEFAULT)
endif

clean :
	rm -rf $(BUILD_DIR) $(SBI_BUILD_DIR) *.bin  *.map *.elf

$(BUILD_DIR)/%_c.o: $(SRC_DIR)/%.c
# 模式变量 % 符合这种模式的都套用这个规则
# 自动变量   $@ 代表目标文件的名称，$< 表示依赖文件列表中的第一个依赖文件
	$(CMD_PREFIX)mkdir -p $(BUILD_DIR); echo " CC   $@" ; $(GNU)-gcc $(COPS) -c $< -o $@

$(BUILD_DIR)/%_s.o: $(SRC_DIR)/%.S
	$(CMD_PREFIX)mkdir -p $(BUILD_DIR); echo " AS   $@"; $(GNU)-gcc $(COPS) -c $< -o $@
# wildcard是一个函数，用于匹配文件列表，可以包含通配符，没有则返回空
# 所谓的列表，不过是空格隔开的字符串 uild_src/uart_c.o build_src/kernel_c.o build_src/boot_s.o
C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)

OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)
# 模式替换
DEP_FILES = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FILES)

benos.bin: $(SRC_DIR)/linker.ld $(OBJ_FILES)
	$(CMD_PREFIX)$(GNU)-ld -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/benos.elf  $(OBJ_FILES) -Map benos.map; echo " LD $(BUILD_DIR)/benos.elf"
	$(CMD_PREFIX)$(GNU)-objcopy $(BUILD_DIR)/benos.elf -O binary benos.bin; echo " OBJCOPY benos.bin"
	$(CMD_PREFIX)cp $(BUILD_DIR)/benos.elf benos.elf

##############
#  build SBI
##############
SBI_BUILD_DIR = build_sbi
SBI_SRC_DIR = sbi
$(SBI_BUILD_DIR)/%_c.o: $(SBI_SRC_DIR)/%.c
	$(CMD_PREFIX)mkdir -p $(SBI_BUILD_DIR); echo " CC   $@" ; $(GNU)-gcc $(COPS) -c $< -o $@

$(SBI_BUILD_DIR)/%_s.o: $(SBI_SRC_DIR)/%.S
	$(CMD_PREFIX)mkdir -p $(SBI_BUILD_DIR); echo " AS   $@"; $(GNU)-gcc $(COPS) -c $< -o $@

SBI_C_FILES = $(wildcard $(SBI_SRC_DIR)/*.c)
SBI_ASM_FILES = $(wildcard $(SBI_SRC_DIR)/*.S)
SBI_OBJ_FILES = $(SBI_C_FILES:$(SBI_SRC_DIR)/%.c=$(SBI_BUILD_DIR)/%_c.o)
SBI_OBJ_FILES += $(SBI_ASM_FILES:$(SBI_SRC_DIR)/%.S=$(SBI_BUILD_DIR)/%_s.o) 

# DEP_FILES = $(SBI_OBJ_FILES:%.o=%.d)
# -include $(DEP_FILES)

mysbi.bin: $(SBI_SRC_DIR)/sbi_linker.ld $(SBI_OBJ_FILES) 
	$(CMD_PREFIX)$(GNU)-ld -T $(SBI_SRC_DIR)/sbi_linker.ld -o $(SBI_BUILD_DIR)/mysbi.elf  $(SBI_OBJ_FILES) -Map mysbi.map; echo " LD $(SBI_BUILD_DIR)/mysbi.elf"
	$(CMD_PREFIX)$(GNU)-objcopy $(SBI_BUILD_DIR)/mysbi.elf -O binary mysbi.bin; echo " OBJCOPY mysbi.bin"
	$(CMD_PREFIX)cp $(SBI_BUILD_DIR)/mysbi.elf mysbi.elf

######################
#  build benos payload
######################
benos_payload.bin: $(SBI_SRC_DIR)/sbi_linker_payload.ld $(SBI_OBJ_FILES) $(OBJ_FILES)
	$(CMD_PREFIX)$(GNU)-ld -T $(SBI_SRC_DIR)/sbi_linker_payload.ld -o $(SBI_BUILD_DIR)/benos_payload.elf  $(SBI_OBJ_FILES) -Map benos_payload.map; echo " LD $(SBI_BUILD_DIR)/benos_payload.elf"
	$(CMD_PREFIX)$(GNU)-objcopy $(SBI_BUILD_DIR)/benos_payload.elf -O binary benos_payload.bin; echo " OBJCOPY benos_payload.bin"
	$(CMD_PREFIX)cp $(SBI_BUILD_DIR)/benos_payload.elf benos_payload.elf

##############
#  run qemu
##############
ifeq ($(board), qemu)
QEMU_FLAGS  += -nographic -machine virt -m 128M 
QEMU_BIOS = -bios mysbi.bin  -device loader,file=benos.bin,addr=0x80200000 
run:
	qemu-system-riscv64 $(QEMU_FLAGS) $(QEMU_BIOS) -kernel benos.elf
debug:
	qemu-system-riscv64 $(QEMU_FLAGS) $(QEMU_BIOS) -kernel benos.elf -S -s &
	gdb-multiarch mysbi.elf --tui -x ./gdbinit
payload:
	qemu-system-riscv64 $(QEMU_FLAGS) -bios none -device loader,file=benos_payload.bin,addr=0x80000000

else ifeq ($(board), nemu)
run:
	riscv64-nemu-interpreter -b benos_payload.bin
debug:
	riscv64-nemu-interpreter benos_payload.bin
endif
```

### helloRVOS

```makefile
# CROSS_COMPILE = riscv64-unknown-elf-
# CFLAGS = -nostdlib -fno-builtin -march=rv32ima -mabi=ilp32 -g -Wall

# QEMU = qemu-system-riscv32
# QFLAGS =-smp 1 -machine virt -bios none

# GDB = gdb-multiarch
# CC = ${CROSS_COMPILE}gcc
# OBJCOPY = ${CROSS_COMPILE}objcopy
# OBJDUMP = ${CROSS_COMPILE}objdump

include ../../common.mk

# 将代码行分成多行，以提高可读性
SRCS_ASM = \
	start.S \

SRCS_C = \
	kernel.c \
	uart.c \

OBJS = $(SRCS_ASM:.S=.o)		# 将 SRCS_ASM 中所有以 .S 结尾的字符串替换为以 .o 结尾的字符串
OBJS += $(SRCS_C:.c=.o)

.DEFAULT_GOAL := all

.PHONY : all
all: os.elf
	@echo ${SRCS_ASM}
	@echo ${SRCS_C}
	@echo ${OBJS}

# start.o must be the first in dependency!
os.elf: ${OBJS}
# 链接器将程序的起始地址设置为 0x80000000，名为 os.elf 的可执行文件，$^	会被展开为依赖文件列表
	${CC} ${CFLAGS} -Ttext=0x80000000 -o os.elf $^	
# 将os.elf以纯二进制格式复制到os.bin
	${OBJCOPY} -O binary os.elf os.bin

# 模式变量 % 符合这种模式的都套用这个规则
%.o : %.c
# 自动变量   $@ 代表目标文件的名称，$< 表示依赖文件列表中的第一个依赖文件
	${CC} ${CFLAGS} -c -o $@ $<

%.o : %.S
	${CC} ${CFLAGS} -c -o $@ $<

run: all
	@${QEMU} -M ? | grep virt >/dev/null || exit
	@echo "Press Ctrl-A and then X to exit QEMU"
	@echo "------------------------------------"
	@${QEMU} ${QFLAGS} -kernel os.elf

.PHONY : debug
debug: all
	@echo "Press Ctrl-C and then input 'quit' to exit GDB and QEMU"
	@echo "-------------------------------------------------------"
	@${QEMU} ${QFLAGS} -kernel os.elf -s -S &
	@${GDB} os.elf -q -x ../gdbinit

.PHONY : code
code: all
	@${OBJDUMP} -S os.elf | less

.PHONY : clean
clean:
	rm -rf *.o *.bin *.elf
```

