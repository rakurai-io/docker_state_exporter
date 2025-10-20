FROM golang:alpine as builder
RUN apk update && apk add git && apk add ca-certificates
COPY *.go $GOPATH/src/mypackage/myapp/
WORKDIR $GOPATH/src/mypackage/myapp/
# Initialize Go module if it doesn’t exist
RUN go mod init mypackage/myapp || true

# Pin compatible Docker SDK version
RUN go get github.com/docker/docker@v20.10.7+incompatible
RUN go get github.com/docker/distribution@v2.8.2+incompatible
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/docker_state_exporter

FROM alpine:3
COPY --from=builder /go/bin/docker_state_exporter /go/bin/docker_state_exporter
EXPOSE 8080
ENTRYPOINT ["/go/bin/docker_state_exporter"]
CMD ["-listen-address=:8080"]