#!/usr/bin/env bash

scp -o StrictHostKeyChecking=no -i .ssh/master_key vagrant@master:kubejoin.sh .
chmod +x ./kubejoin.sh
sudo ./kubejoin.sh
