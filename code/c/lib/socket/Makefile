CCOPTS = -fno-builtin -Wall -g -fno-omit-frame-pointer -std=c99 -shared -fPIC -DKXVER=3 -O3 -I../../include -D_BSD_SOURCE
all:
	mkdir -p l32
	mkdir -p l64
	gcc $(CCOPTS) socket.c -o l32/socket.so -m32
	gcc $(CCOPTS) socket.c -o l64/socket.so
