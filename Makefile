include .env

HEADERS = src/include
C_SOURCES = $(shell find src -name "*.c")
OBJECTS = $(patsubst src/%.c, build/%.o, $(C_SOURCES))

QEMU = qemu-system-i386

CC = gcc
CC_FLAGS = -fno-pic -m32 -ffreestanding

NASM_FLAGS = -f elf
BOOT_NASM_FLAGS = -I src/boot
BOOT_NASM_FLAGS_ELF = -f elf $(BOOT_NASM_FLAGS)
BOOT_NASM_FLAGS_BIN = -f bin $(BOOT_NASM_FLAGS)

ifeq (${DEBUG}, true)
CC_FLAGS += -g
NASM_FLAGS += -g
BOOT_NASM_FLAGS += -g
endif

_DUMMY := $(shell mkdir -p build)

ifeq (${ENVIRONMENT}, docker)
all: docker
else
all: image
endif

sources:
	@echo "Headers: $(HEADERS)"
	@echo "Sources: $(C_SOURCES)"
	@echo "Objects: $(OBJECTS)"

run: all
	$(QEMU) -drive format=raw,file=build/${IMAGE_NAME},index=0,media=disk

debug: all
	$(QEMU) -drive format=raw,file=build/${IMAGE_NAME},index=0,media=disk -s -S & \
	lldb build/kernel.elf -o "gdb-remote localhost:1234"

docker:
	rm -rf build
	docker build --platform linux/amd64 --tag ${IMAGE_NAME} --build-arg IMAGE_NAME=${IMAGE_NAME} --build-arg DEBUG=${DEBUG} -f Dockerfile.image .
	CONTAINER=$$(docker create --platform linux/amd64 ${IMAGE_NAME}); \
	docker cp $$CONTAINER:/build .; \
	docker rm $$CONTAINER; \
	docker rmi ${IMAGE_NAME}

build/boot.asm: src/boot/boot.asm
	cp src/boot/boot.asm build/boot.asm
	sed -i "1d" build/boot.asm
build/boot.bin: src/boot/boot.asm
	nasm $< $(BOOT_NASM_FLAGS_BIN) -o $@
build/boot.o: build/boot.asm
	nasm $< $(BOOT_NASM_FLAGS_ELF) -o $@
build/boot.elf: build/boot.o
	ld -m elf_i386 -o $@ -Ttext 0x7C00 $^

$(OBJECTS): build/%.o : src/%.c
	mkdir -p $(dir $@)
	$(CC) $(CC_FLAGS) -c $< -I $(HEADERS) -o $@
build/bootstrap.o: src/boot/bootstrap.asm
	nasm $< $(NASM_FLAGS) -o $@
build/kernel.elf: build/bootstrap.o $(OBJECTS)
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^
build/kernel.bin: build/kernel.elf build/boot.elf # TODO: remove boot.elf from there
	objcopy -O binary $< $@

image: build/boot.bin build/kernel.bin
	cat $^ > build/${IMAGE_NAME}

clean:
	rm -rf build
