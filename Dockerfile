# Stage 1: Python setup
FROM python:3.9 AS python-stage
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
WORKDIR /code
COPY requirements.txt /code/
RUN pip install -r requirements.txt
COPY . /code/
EXPOSE 8000

# Stage 2: Golang setup
FROM ubuntu:latest AS golang-stage
RUN apt-get update && apt-get install -y \
    wget \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://golang.org/dl/go1.17.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz && \
    rm go1.17.5.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go

# Stage 3: Final container setup
FROM python:3.9 AS final-stage
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
WORKDIR /code
COPY --from=python-stage /code /code
COPY --from=golang-stage /usr/local/go /usr/local/go
COPY requirements.txt /code/
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8000
CMD ["python", "app.py"]
