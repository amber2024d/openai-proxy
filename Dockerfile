# 构建阶段
FROM golang:1.24.0 AS builder

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o openai-proxy ./cmd/server

# 运行阶段
FROM alpine:latest

# 安装 CA 证书，用于 HTTPS 请求
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# 从构建阶段复制二进制文件
COPY --from=builder /app/openai-proxy .
# 复制配置文件目录
COPY --from=builder /app/config ./config/

# 暴露端口
EXPOSE 8080

# 运行应用
CMD ["./openai-proxy"]