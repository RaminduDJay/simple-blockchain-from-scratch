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