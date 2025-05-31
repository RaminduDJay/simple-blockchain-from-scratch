mod chain;
mod network;

use chain::blockchain::Blockchain;
use clap::{Parser, Subcommand};
use std::sync::Mutex;
use actix_web::web;

#[derive(Parser)]
#[clap(name = "Rust Blockchain CLI")]
struct Cli {
    #[clap(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Start { port: u16 },
    Print,
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let cli = Cli::parse();
    let mut blockchain = Blockchain::new();

    match cli.command {
        Commands::Start { port } => {
            let blockchain_data = web::Data::new(Mutex::new(blockchain));
            network::api::start_server(port, blockchain_data).await
        }
        Commands::Print => {
            for block in blockchain.chain {
                println!("Block {}: {:?}", block.index, block.hash);
            }
            Ok(())
        }
    }
}