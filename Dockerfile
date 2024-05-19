# Use the official Arch Linux base image
FROM archlinux:latest

# Update package repositories and install required dependencies
RUN pacman -Sy --noconfirm && \
    pacman -S --noconfirm rust curl

# Install sshx using curl
RUN curl -sSf https://sshx.io/get | sh

# Set the entry point to sshx
ENTRYPOINT ["sshx"]
