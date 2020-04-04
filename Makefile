default:
	make img

ipl.bin: ipl.asm Makefile
	nasm ipl.asm -o ipl.bin -l ipl.lst
# tail.bin: tail.asm Makefile
# 	nasm tail.asm -o tail.bin -l tail.lst
haribote.sys: haribote.asm Makefile
	nasm haribote.asm -o haribote.sys -l haribote.lst

haribote.img: ipl.bin haribote.sys Makefile
	mformat -f 1440 -C -B ipl.bin -i haribote.img ::
	mcopy haribote.sys -i haribote.img ::

# helloos.img: ipl.bin tail.bin Makefile
# 	cat ipl.bin tail.bin > helloos.img

asm:
	make -r ipl.bin
img:
	# make -r helloos.img
	make -r haribote.img
run:
	make img
	# qemu-system-i386 -fda helloos.img # '-fda' option is floppy disk
	qemu-system-i386 -fda haribote.img # '-fda' option is floppy disk

