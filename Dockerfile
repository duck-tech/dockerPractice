# docker env 的基底, best practice 1
FROM python:3.6

# 在 docker container 內的工作目錄
WORKDIR /app

# 將本地端的所有檔案複製到 docker container 內的 /app 目錄
COPY ./ ./

# 安裝依賴前切換回 root 用戶，確保有權限進行安裝
USER root

# 安裝所需的 Python 包
RUN pip install --no-cache-dir -r requirements.txt

# 創建一個用戶 'duck' 並確保該用戶有 /app 目錄的適當權限
RUN groupadd -r duck && useradd --no-log-init -r -g duck duck && \
    chown -R duck:duck /app

# 切換到創建的用戶
USER duck

LABEL maintainer='wang'
LABEL name='first-app'
LABEL build-date='2024/02/29'
LABEL description='This is a first app.'

ENV FLASK_APP=src/main.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=3000

CMD ["flask", "run"]

# 這個指令是用來檢查 container 是否正常運作
HEALTHCHECK CMD curl --fail http://localhost:3000 || exit 1
