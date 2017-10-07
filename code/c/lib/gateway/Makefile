CCOPTS = -fno-builtin -Wall -g -fno-omit-frame-pointer -std=c99 -fPIC -DKXVER=3 -O3 -shared -I../../include
all:
	mkdir -p l32
	mkdir -p l64
	gcc $(CCOPTS) gateway.c -o l32/gateway.so -m32
	gcc $(CCOPTS) gateway.c -o l64/gateway.so
