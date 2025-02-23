FROM golang:1.17.1-alpine as builder
WORKDIR /root
COPY ./go.mod ./
COPY ./go.sum ./
RUN go mod download
COPY . .
RUN export GO111MODULE=on && CGO_ENABLED=0 GOOS=linux go build  -ldflags "-s -w" -o build/casbin_mesh cmd/app/main.go


FROM alpine:latest
RUN apk --no-cache add ca-certificates

RUN apk update -v \
    && apk add bash \
    && apk upgrade -v --no-cache

WORKDIR /root
COPY --from=builder /root/build/casbin_mesh ./

RUN mkdir -p /casbin_mesh/file

VOLUME /casbin_mesh/data

COPY ./docker-entrypoint.sh ./
RUN chmod +x /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]

EXPOSE 4002

CMD ["/root/casbin_mesh", "-raft-address", "0.0.0.0:4002", "/casbin_mesh/data/data"]
