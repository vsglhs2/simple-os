include .env

all: image

run: all
	qemu-system-x86_64 -drive format=raw,file=build/${IMAGE_NAME}

docker:
	rm -rf build
	docker build --platform linux/amd64 --tag ${IMAGE_NAME} .
	CONTAINER=$$(docker create --platform linux/amd64 ${IMAGE_NAME}); \
	docker cp $$CONTAINER:/build .; \
	docker rm $$CONTAINER; \
	docker rmi ${IMAGE_NAME}

build/boot.bin: src/boot/boot.asm
	nasm $< -f bin -I src/boot -o $@

build/kernel.o: src/kernel/kernel.c
	gcc -fno-pic -m32 -ffreestanding -c $< -o $@
build/bootstrap.o: src/boot/bootstrap.asm
	nasm $< -f elf -o $@
build/kernel.bin: build/bootstrap.o build/kernel.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

image: build/boot.bin build/kernel.bin
	cat $^ > build/${IMAGE_NAME}

clean:
	rm -rf build
