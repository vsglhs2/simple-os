export $(grep -v '^#' .env | xargs)
qemu-system-x86_64 -drive format=raw,file=build/$IMAGE_NAME
