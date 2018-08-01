#!/bin/sh

# zerolog
if [ ! -h gopath/src/github.com/rs/zerolog ]; then
    mkdir -p .gopath/src/github.com/rs/
    ln -s ${PWD} ./gopath/src/github.com/rs/zerolog
fi

export GOPATH=${PWD}/gopath
export GOBIN=${PWD}/output

go install zerolog
# go build -o output/zeorlog 
