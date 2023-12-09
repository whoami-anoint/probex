FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    wget \
    python3 \
    python3-pip \
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

COPY requirements.txt /code/
RUN pip3 install --no-cache-dir -r requirements.txt

CMD ["python3", "app.py"]
