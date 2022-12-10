FROM ubuntu:20.04 as builder

RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && apt-get install -y build-essential tzdata pkg-config \
	wget 

RUN wget https://go.dev/dl/go1.19.1.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.1.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin

ADD . /tarmac
WORKDIR /tarmac

ADD fuzzers/fuzz_loadwasm.go ./fuzzers/
WORKDIR ./fuzzers/
RUN go mod init myfuzz
RUN go get github.com/madflojo/tarmac/pkg/wasm@v0.3.0
#RUN go get github.com/madflojo/tarmac
RUN go build
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/simple-name-section.wasm
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/simple.wasm
RUN wget https://github.com/mdn/webassembly-examples/blob/master/other-examples/table.wasm

FROM ubuntu:20.04
COPY --from=builder /tarmac/fuzzers/myfuzz /
COPY --from=builder /tarmac/fuzzers/*.wasm /testsuite/

ENTRYPOINT []
CMD ["/myfuzz", "@@"]
