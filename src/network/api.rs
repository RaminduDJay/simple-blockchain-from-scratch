use actix_web::{web, HttpResponse, Responder};
use std::sync::{Arc, Mutex};
use crate::chain::blockchain::Blockchain;

pub async fn get_chain(data: web::Data<Arc<Mutex<Blockchain>>>) -> impl Responder {
    let blockchain = data.lock().unwrap();
    HttpResponse::Ok().json(&blockchain.chain)
}

pub async fn add_transaction(data: web::Data<Arc<Mutex<Blockchain>>>, transaction: web::Json<String>) -> impl Responder {
    let mut blockchain = data.lock().unwrap();
    let new_block = crate::chain::block::Block::new(
        blockchain.chain.len() as u64,
        transaction.into_inner(),
        blockchain.latest_block().hash.clone(),
    );
    blockchain.add_block(new_block);
    HttpResponse::Ok().body("Transaction added")
}

pub async fn start_server(port: u16, data: web::Data<Arc<Mutex<Blockchain>>>) -> std::io::Result<()> {
    HttpServer::new(move || {
        App::new()
            .app_data(data.clone())
            .route("/chain", web::get().to(get_chain))
            .route("/transaction", web::post().to(add_transaction))
    })
    .bind(("127.0.0.1", port))?
    .run()
    .await
}