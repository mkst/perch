CCOPTS = -fno-builtin -Wall -fno-omit-frame-pointer -std=c99 -shared -fPIC -DKXVER=3 -O3 -I../../include
all:
	mkdir -p l32
	mkdir -p l64
	gcc $(CCOPTS) fix.c -o l32/fix.so -m32
	gcc $(CCOPTS) fix.c -o l64/fix.so
