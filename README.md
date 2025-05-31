# 🧊 Rust Blockchain – Educational Project

A simple blockchain implementation in Rust for learning purposes. This project demonstrates the core concepts of blockchain technology, including blocks, chains, proof-of-work, transactions, and basic networking.

---

## 📁 Folder Structure

```
blockchain-rust/
├── src/
│   ├── main.rs              # CLI entry point
│   ├── lib.rs               # Module exports
│   ├── chain/               # Block and blockchain logic
│   ├── consensus/           # Consensus algorithms (e.g., Proof-of-Work)
│   ├── transactions/        # Transaction and wallet handling
│   ├── network/             # REST API and node communication
│   └── utils/               # Helper functions (hashing, etc.)
├── tests/                   # Integration and unit tests
├── Cargo.toml               # Project metadata and dependencies
└── README.md                # This file
```

---

## 🛠 Features Implemented

- ✅ Block structure with SHA-256 hashing
- ✅ Blockchain creation and validation
- ✅ Proof-of-Work (PoW) mining with difficulty
- ✅ Simple transaction system
- ✅ Wallet generation using `secp256k1`
- ✅ REST API with Actix Web for adding/viewing blocks
- ✅ CLI interface for interacting with the blockchain

---

## 🚀 Getting Started

### Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) installed (with `cargo`)
- Optional: `curl` for testing the API

### Build the Project

```bash
cargo build --release
```

### Run the Node Server

```bash
cargo run -- start 8080
```

This will start a local HTTP server on port `8080`.

### Add a Transaction via cURL

```bash
curl -X POST http://localhost:8080/transaction \
     -H "Content-Type: application/json" \
     -d '"Alice sends 5 BTC to Bob"'
```

### Print the Chain

```bash
cargo run -- print
```

---

## 🧪 Running Tests

```bash
cargo test
```

---

## 🧑‍💻 Contributing

Feel free to fork this project and expand it:
- Add peer-to-peer networking using `libp2p`
- Implement smart contracts or a VM
- Improve wallet and signing features
- Add Merkle trees for transactions

---
