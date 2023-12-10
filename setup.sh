#!/bin/bash

# assetfinder
GO111MODULE=on go get -u github.com/tomnomnom/assetfinder

# waybackurls
GO111MODULE=on go get github.com/tomnomnom/waybackurls

# dirb
sudo apt-get install -y dirb

# nuclei
GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei