FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://golang.org/dl/go1.17.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz && \
    rm go1.17.5.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go

RUN apt-get update && apt-get install -y \
    golang-go \
    dirb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code

CMD ["python", "app.py"]
