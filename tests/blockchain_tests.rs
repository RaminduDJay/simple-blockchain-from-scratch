use crate::chain::blockchain::Blockchain;

#[test]
fn test_blockchain_validity() {
    let mut blockchain = Blockchain::new();
    blockchain.add_block(crate::chain::block::Block::new(
        1,
        "Alice sends 5 BTC to Bob".to_string(),
        blockchain.chain[0].hash.clone(),
    ));
    assert!(blockchain.is_valid());
}

#[test]
fn test_blockchain_tampering() {
    let mut blockchain = Blockchain::new();
    blockchain.add_block(crate::chain::block::Block::new(
        1,
        "Test".to_string(),
        blockchain.chain[0].hash.clone(),
    ));
    blockchain.chain[1].data = "Modified Data".to_string();
    assert!(!blockchain.is_valid());
}