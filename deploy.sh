#!/bin/bash
set -ex

cd /home/isucon/isucon9-qualify && \
git pull team master && \
cd /home/isucon/isucon9-qualify/webapp/go/ && \
make && \
sudo systemctl restart mysql && \
sudo systemctl restart isucari.golang && \
sudo systemctl restart nginx
