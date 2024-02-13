#!/bin/bash
# https://github.com/golang/go/issues/50750#issuecomment-1939891224
find . -name go.mod -exec sh -c 'cd "$(dirname "$0")" && go mod tidy' {} \;
