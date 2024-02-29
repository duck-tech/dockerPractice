# Docker 百科全書

## Docker 流程

Registry  -> pull -> baseImage  => create a Dockerfile -> build dockerfile -> docker image —run —> container

## Docker 指令

```bash
# 建立 image
docker build -t  first-app:1.0 .

# 執行 ㄏcontainer
docker run -p 3000:3000 -it -d first-app:1.0 

```

## 指令大全

* 查看 group
  * cat /etc/group
* 執行 container 指令 bash
  * docker exec -it <container_name or id> bash
