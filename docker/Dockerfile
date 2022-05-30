FROM alpine AS md2html

RUN apk --no-cache add cmake clang clang-dev make gcc g++ libc-dev linux-headers git tree

RUN git clone https://github.com/mity/md4c.git

RUN cd md4c && \
    mkdir build && \
    cd build && \
    cmake -DBUILD_SHARED_LIBS=OFF .. && \
    make && \
    make install

FROM golang:alpine AS jsonnet

RUN go install github.com/google/go-jsonnet/cmd/jsonnet@latest
RUN which jsonnet

FROM alpine

RUN apk --no-cache add make bash

COPY --from=jsonnet /go/bin/jsonnet /usr/local/bin/jsonnet
COPY --from=md2html /usr/local/bin/md2html /usr/local/bin/md2html
