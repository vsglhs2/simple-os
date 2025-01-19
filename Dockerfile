FROM randomdude/gcc-cross-x86_64-elf

WORKDIR /usr/app

ARG IMAGE_NAME

COPY ./src ./src
COPY ./Makefile .

RUN apt-get -y install nasm make

RUN touch .env
RUN echo "IMAGE_NAME=${IMAGE_NAME}\nENVIRONMENT=native" >> .env
RUN cat .env
RUN mkdir -p build

RUN make

RUN mkdir -p /build && cp -r build/* /build