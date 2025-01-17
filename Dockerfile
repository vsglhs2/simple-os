FROM randomdude/gcc-cross-x86_64-elf

ARG IMAGE_NAME

WORKDIR /usr/app

COPY ./src ./
RUN mkdir -p build

RUN apt-get -y install nasm

RUN gcc -fno-pic -m32 -ffreestanding -c kernel.c -o build/kernel.o
RUN nasm bootstrap.asm -f elf -o build/bootstrap.o
RUN ld -m elf_i386 -o build/kernel.bin -Ttext 0x1000 build/bootstrap.o build/kernel.o --oformat binary

RUN nasm boot.asm -f bin -o build/boot.bin

RUN cat build/boot.bin build/kernel.bin > build/${IMAGE_NAME}

RUN mkdir -p /build && cp -r build/* /build

# objdump -d main.o
# ndisasm -b 32 basic.bin > basic.dis