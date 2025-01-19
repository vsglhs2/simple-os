include .env

HEADERS = src/include
C_SOURCES = $(shell find src -name "*.c")
OBJECTS = $(patsubst src/%.c, build/%.o, $(C_SOURCES))

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
	qemu-system-x86_64 -drive format=raw,file=build/${IMAGE_NAME}

docker:
	rm -rf build
	docker build --platform linux/amd64 --tag ${IMAGE_NAME} --build-arg IMAGE_NAME=${IMAGE_NAME} .
	CONTAINER=$$(docker create --platform linux/amd64 ${IMAGE_NAME}); \
	docker cp $$CONTAINER:/build .; \
	docker rm $$CONTAINER; \
	docker rmi ${IMAGE_NAME}

build/boot.bin: src/boot/boot.asm
	nasm $< -f bin -I src/boot -o $@

$(OBJECTS): build/%.o : src/%.c
	mkdir -p $(dir $@)
	gcc -fno-pic -m32 -ffreestanding -c $< -I $(HEADERS) -o $@
build/bootstrap.o: src/boot/bootstrap.asm
	nasm $< -f elf -o $@
build/kernel.bin: build/bootstrap.o $(OBJECTS)
	ld -m elf_i386 -o $@ -Ttext 0x1000 $< $(OBJECTS) --oformat binary

image: build/boot.bin build/kernel.bin
	cat $^ > build/${IMAGE_NAME}

clean:
	rm -rf build
