BINARY=tableme

install: ${BINARY}.go
	go install -v ${BINARY}

#all: macos linux

#macos: ${BINARY}.go
	#go install -v ${BINARY}

#linux: ${BINARY}.go
	#@mkdir -p ${DAVINCI_HOME}/davinci/go/linux_amd64
	#GOOS=linux GOARCH=amd64 go build -v -o ${DAVINCI_HOME}/davinci/go/linux_amd64/${BINARY} $^

clean:
	go clean -i -x

.PHONY: all clean
