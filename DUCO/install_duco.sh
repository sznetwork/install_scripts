#!/bin/bash

# Step 1
apt update
apt upgrade -y
apt install python3 python3-dev python3-pip curl git python3-pil python3-pil.imagetk python3.11-venv -y
# Step 2
git clone https://github.com/revoxhere/duino-coin
cd duino-coin

# Step 3
python3 -m venv .venv
source .venv/bin/activate

# Step 4
python3 -m pip install -r requirements.txt
python3 PC_Miner.py
