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
            let previous = &self.chain[i - 1];

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