# docker env 以python 3.6為的基底, best practice 1
FROM python:3.6 AS builder 

# 在 docker container 內的工作目錄
WORKDIR /app

COPY requirements.txt .

# 安裝所需的 Python 包,防止pip在安装过程中使用cache，这样做可以减小Docker镜像
RUN pip install --no-cache-dir -r requirements.txt


# 現在，每次我們更改Sample.py時，建置都會重新安裝軟體包。這是非常低效的，尤其是在使用 Docker 容器作為開發環境時。因此，將經常更改的文件保留在 Dockerfile 的末尾至關重要。
# 這樣改到程式碼時, 不會重新安裝軟體包
COPY ./src ./src

# stage-2 Deployment
FROM python:3.6.15-alpine3.15

WORKDIR /app 

COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/python3.6/site-packages /usr/local/lib/python3.6/site-packages
COPY --from=builder /usr/local/bin/flask /usr/local/bin/flask
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

# 安裝curl, 用於健康檢查
RUN apk add --no-cache curl
# 建立一個使用者 duck, 並將 /app 的擁有者改為 duck
RUN adduser --disabled-password duck \
    && chown -R duck /app
USER duck

LABEL maintainer='wang'
LABEL name='first-app'
LABEL build-date='2024/02/29'
LABEL description='This is a first app.'

# 環境變數
ENV FLASK_APP=src/main.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=3000

# Container 要開啟的 Port是3000
EXPOSE 3000

HEALTHCHECK CMD curl -f http://0.0.0.0:3000 || exit 1

# 使用gunicorn而非Flask內建的flask run主要是
# 因為gunicorn是一個更強大且適合生產環境的WSGI伺服器。
# 它能處理多個用戶請求，提供更好的性能和穩定性。
# Flask自帶的伺服器主要用於開發環境，因為它並非設計來處理高並發和生產環境下的安全問題。
# gunicorn提供了多進程、多線程的工作模式，更適合在生產環境中使用，以確保應用能夠高效、安全地運行。
CMD ["gunicorn", "-b", "0.0.0.0:3000", "src.main:app"]
