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