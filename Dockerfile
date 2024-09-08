FROM golang:1.22-alpine3.20 as build

LABEL maintainer="erguotou525@gmail.compute"

ENV CGO_ENABLED=1

RUN apk update
RUN apk add git libc-dev gcc

WORKDIR /build/

COPY . .

RUN go install github.com/mjibson/esc@latest

RUN go mod download
RUN go generate ./...
RUN go build -o mailslurper ./cmd/mailslurper/

FROM alpine:3.20

WORKDIR /opt/mailslurper/

RUN apk add --no-cache ca-certificates \
  && echo -e '{\n\
  "wwwAddress": "0.0.0.0",\n\
  "wwwPort": 8080,\n\
  "wwwPublicURL": "",\n\
  "serviceAddress": "0.0.0.0",\n\
  "servicePort": 8085,\n\
  "servicePublicURL": "",\n\
  "smtpAddress": "0.0.0.0",\n\
  "smtpPort": 2500,\n\
  "dbEngine": "SQLite",\n\
  "dbHost": "",\n\
  "dbPort": 0,\n\
  "dbDatabase": "./mailslurper.db",\n\
  "dbUserName": "",\n\
  "dbPassword": "",\n\
  "maxWorkers": 1000,\n\
  "autoStartBrowser": false,\n\
  "keyFile": "",\n\
  "certFile": "",\n\
  "adminKeyFile": "",\n\
  "adminCertFile": ""\n\
  }'\
  >> config.json

COPY --from=build /build/mailslurper mailslurper

EXPOSE 8080 8085 2500

ENTRYPOINT ["/opt/mailslurper/mailslurper"]
