use serde::{Serialize, Deserialize};
use sha2::{Sha256, Digest};
use chrono::Utc;
use crate::utils::hashing::hash_block;

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
            let hash = hash_block(&payload);
            
            if hash.starts_with("0000") {
                return (hash, nonce);
            }
            nonce += 1;
        }
    }

    pub fn calculate_hash(&self) -> String {
        hash_block(&format!(
            "{}{}{}{}{}",
            self.index, self.timestamp, self.data, self.previous_hash, self.nonce
        ))
    }
}