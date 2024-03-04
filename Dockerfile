# docker env 的基底, best practice 1
FROM python:3.6 AS builder 

# 在 docker container 內的工作目錄
WORKDIR /app

# 將本地端的所有檔案複製到 docker container 內的 /app 目錄
COPY ./ /app

# 安裝所需的 Python 包
RUN pip install --no-cache-dir -r requirements.txt

# stage-2 Deployment
FROM python:3.6.15-alpine3.15

WORKDIR /app 

COPY --from=builder /app /app
COPY --from=builder /usr/local/lib/python3.6/site-packages /usr/local/lib/python3.6/site-packages
COPY --from=builder /usr/local/bin/flask /usr/local/bin/flask

# 建立一個使用者 duck
RUN adduser --disabled-password duck \
    && chown -R duck.duck /app
USER duck

LABEL maintainer='wang'
LABEL name='first-app'
LABEL build-date='2024/02/29'
LABEL description='This is a first app.'

ENV FLASK_APP=src/main.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=3000

EXPOSE 3000
CMD ["flask", "run"]