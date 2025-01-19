FROM alpine

RUN apk add --no-cache gdb

ENTRYPOINT [ "gdb" ]