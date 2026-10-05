.PHONY: all proto test lint build tidy clean

all: clean proto test build

proto:
	./hack/update-codegen.sh

test:
	go test -race -v ./...

lint:
	golangci-lint run ./...

build:
	mkdir -p bin
	go build -o bin/agent ./cmd/agent

tidy:
	go mod tidy

clean:
	rm -rf bin/
	rm -f api/kube_resource/v1/*.pb.go
	rm -f api/v1/*.pb.go
