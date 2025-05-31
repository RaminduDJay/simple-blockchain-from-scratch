#!/bin/bash

# Create directory structure
mkdir -p blockchain-rust/{src/{chain,consensus,transactions,network,utils},tests}
cd blockchain-rust

# Create mod.rs files
touch src/chain/mod.rs
touch src/consensus/mod.rs
touch src/transactions/mod.rs
touch src/network/mod.rs

# Write boilerplate code

# src/lib.rs
cat <<EOL > src/lib.rs
pub mod chain;
pub mod consensus;
pub mod transactions;
pub mod network;
pub mod utils;
EOL

# src/main.rs
cat <<EOL > src/main.rs
mod lib;

fn main() {
    println!("Blockchain Rust Project");
}
EOL

# src/chain/block.rs
cat <<EOL > src/chain/block.rs
use serde::{Serialize, Deserialize};
use sha2::{Sha256, Digest};
use chrono::Utc;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Block {
    pub index: u64,
    pub timestamp: i64,
    pub data: String,
    pub previous_hash: String,
    pub hash: String,
    pub nonce: u64,
}

impl Block {
    pub fn new(index: u64, data: String, previous_hash: String) -> Self {
        let timestamp = Utc::now().timestamp();
        let (hash, nonce) = Self::mine_block(index, timestamp, &data, &previous_hash);
        Self {
            index,
            timestamp,
            data,
            previous_hash,
            hash,
            nonce,
        }
    }

    fn mine_block(index: u64, timestamp: i64, data: &str, previous_hash: &str) -> (String, u64) {
        let mut nonce = 0;
        loop {
            let payload = format!("{}{}{}{}{}", index, timestamp, data, previous_hash, nonce);
            let mut hasher = Sha256::new();
            hasher.update(payload);
            let hash = hasher.finalize();
            let hash_str = hex::encode(hash);
            
            // Difficulty: 2 leading zeros
            if hash_str.starts_with("00") {
                return (hash_str, nonce);
            }
            nonce += 1;
        }
    }

    fn calculate_hash(&self) -> String {
        let payload = format!(
            "{}{}{}{}{}",
            self.index, self.timestamp, self.data, self.previous_hash, self.nonce
        );
        let mut hasher = Sha256::new();
        hasher.update(payload);
        hex::encode(hasher.finalize())
    }
}
EOL

# src/chain/blockchain.rs
cat <<EOL > src/chain/blockchain.rs
use serde::{Serialize, Deserialize};
use crate::chain::block::Block;

#[derive(Serialize, Deserialize, Debug)]
pub struct Blockchain {
    pub chain: Vec<Block>,
}

impl Blockchain {
    pub fn new() -> Self {
        Self {
            chain: vec![Self::create_genesis_block()],
        }
    }

    fn create_genesis_block() -> Block {
        Block::new(0, "Genesis Block".to_string(), "0".to_string())
    }

    pub fn add_block(&mut self, mut new_block: Block) {
        new_block.previous_hash = self.latest_block().hash.clone();
        new_block.hash = new_block.calculate_hash();
        self.chain.push(new_block);
    }

    pub fn is_valid(&self) -> bool {
        for i in 1..self.chain.len() {
            let current = &self.chain[i];
            let previous = &self.chain[i-1];

            if current.hash != current.calculate_hash() {
                return false;
            }

            if current.previous_hash != previous.hash {
                return false;
            }
        }
        true
    }

    pub fn latest_block(&self) -> &Block {
        self.chain.last().expect("Empty blockchain")
    }
}
EOL

# src/chain/mod.rs
cat <<EOL > src/chain/mod.rs
pub mod block;
pub mod blockchain;
EOL

# src/consensus/pow.rs
cat <<EOL > src/consensus/pow.rs
use crate::chain::block::Block;

pub fn validate_block(prev_block: &Block, new_block: &Block) -> bool {
    if new_block.index != prev_block.index + 1 {
        return false;
    }
    if new_block.previous_hash != prev_block.hash {
        return false;
    }
    if new_block.calculate_hash() != new_block.hash {
        return false;
    }
    if !new_block.hash.starts_with("0000") {
        return false;
    }
    true
}
EOL

# src/consensus/mod.rs
cat <<EOL > src/consensus/mod.rs
pub mod pow;
EOL

# src/transactions/transaction.rs
cat <<EOL > src/transactions/transaction.rs
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Transaction {
    pub sender: String,
    pub receiver: String,
    pub amount: f64,
}

impl Transaction {
    pub fn new(sender: String, receiver: String, amount: f64) -> Self {
        Self { sender, receiver, amount }
    }
}
EOL

# src/transactions/wallet.rs
cat <<EOL > src/transactions/wallet.rs
use secp256k1::{Secp256k1, Message, SecretKey, PublicKey};
use rand::Rng;

pub struct Wallet {
    pub private_key: SecretKey,
    pub public_key: PublicKey,
}

impl Wallet {
    pub fn new() -> Self {
        let secp = Secp256k1::new();
        let mut rng = rand::thread_rng();
        let (sk, pk) = secp.generate_keypair(&mut rng);
        Self { private_key: sk, public_key: pk }
    }

    pub fn sign(&self, message: &[u8]) -> Vec<u8> {
        let secp = Secp256k1::new();
        let msg = Message::from_slice(message).unwrap();
        secp.sign_ecdsa(&msg, &self.private_key).serialize()
    }
}
EOL

# src/transactions/mod.rs
cat <<EOL > src/transactions/mod.rs
pub mod transaction;
pub mod wallet;
EOL

# src/utils/hashing.rs
cat <<EOL > src/utils/hashing.rs
use sha2::{Sha256, Digest};

pub fn hash_block(data: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(data);
    let result = hasher.finalize();
    format!("{:x}", result)
}
EOL

# src/utils/mod.rs
cat <<EOL > src/utils/mod.rs
pub mod hashing;
EOL

# src/network/api.rs
cat <<EOL > src/network/api.rs
use actix_web::{web, App, HttpResponse, HttpServer};
use crate::chain::blockchain::Blockchain;

async fn get_chain(data: web::Data<Blockchain>) -> HttpResponse {
    HttpResponse::Ok().json(&data.chain)
}

pub async fn start_server() -> std::io::Result<()> {
    let blockchain = web::Data::new(Blockchain::new());
    HttpServer::new(move || {
        App::new()
            .app_data(blockchain.clone())
            .route("/chain", web::get().to(get_chain))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
EOL

# src/network/node.rs
cat <<EOL > src/network/node.rs
// Placeholder for P2P node logic
pub fn connect_to_node(_address: &str) {
    println!("Connecting to node...");
}
EOL

# src/network/mod.rs
cat <<EOL > src/network/mod.rs
pub mod api;
pub mod node;
EOL

# tests/blockchain_tests.rs
cat <<EOL > tests/blockchain_tests.rs
#[test]
fn test_blockchain_validity() {
    let blockchain = crate::chain::blockchain::Blockchain::new();
    assert!(blockchain.is_valid());
}
EOL

# Cargo.toml
cat <<EOL > Cargo.toml
[package]
name = "blockchain-rust"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
sha2 = "0.10"
hex = "0.4"
chrono = "0.4"
clap = { version = "4.0", features = ["derive"] }
tokio = { version = "1", features = ["full"] }
actix-web = "4"
secp256k1 = "0.27"
libp2p = { version = "0.43", default-features = false, features = ["tcp", "websocket", "dns"] }
rand = "0.8"
EOL

echo "Folder structure and boilerplate code created!"