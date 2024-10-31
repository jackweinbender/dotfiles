# Add GOPATH variable for convenience
export GOPATH=$(go env GOPATH)
# Add Go binaries to PATH
export PATH=$PATH:$(go env GOPATH)/bin
