FROM randomdude/gcc-cross-x86_64-elf

WORKDIR /usr/app

COPY . .

RUN apt-get -y install nasm make

RUN mkdir -p build
RUN make
RUN mkdir -p /build && cp -r build/* /build