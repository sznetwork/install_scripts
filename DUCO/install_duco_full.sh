#!/bin/bash

# Step 1
echo "Step 1"
echo "Update your system and install requirements"
apt update
apt upgrade -y
apt install python3 python3-dev python3-pip curl git python3-pil python3-pil.imagetk python3.11-venv -y
# Step 2
echo "Step 2"
echo "Clone Duino-Coin repository"
git clone https://github.com/revoxhere/duino-coin
cd duino-coin

# Step 3
echo "Step 3"
echo "Install rustup for compilation (if asked, use the default settings):"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh
source $HOME/.cargo/env
echo "Download duino fasthash:"
wget https://server.duinocoin.com/fasthash/libducohash.tar.gz
tar -xvf libducohash.tar.gz
cd libducohash
echo "Compile fasthash"
cargo build --release
pwd
mv target/release/libducohasher.so ..
ls -la
cd ..
pwd
ls -la
# Step 4
python3 -m venv .venv
source .venv/bin/activate

# Step 5
python3 -m pip install -r requirements.txt
python3 PC_Miner.py
