#!/bin/bash

# Step 1
apt update
apt upgrade -y
apt install python curl git -y
# Step 2
git clone https://github.com/revoxhere/duino-coin
cd duino-coin

# Step 3
python -m venv .venv
source .venv/bin/activate

# Step 4
python -m pip install -r requirements.txt
python PC_Miner.py
