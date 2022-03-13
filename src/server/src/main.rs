use axum::{
    extract::{
        ws::{WebSocket, WebSocketUpgrade},
        Extension
    },
    response::IntoResponse,
    routing::{get},
    AddExtensionLayer, Router,
};
use std::net::SocketAddr;
use tokio::sync::mpsc;
use tower_http::trace::{DefaultMakeSpan, TraceLayer};
use tracing::{debug, error, info, Level};
use tracing_subscriber::FmtSubscriber;
mod match_system;

#[tokio::main]
async fn main() {
    let (send, recv) = mpsc::channel(16);
    tokio::spawn(async move {
        match_system::match_queue(recv).await;
    });

    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();

    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

    // build our application with some routes
    let app = Router::new()
        .route("/pinp", get(ws_handler))
        .layer(AddExtensionLayer::new(send))
        .layer(
            TraceLayer::new_for_http()
                .make_span_with(DefaultMakeSpan::default().include_headers(true)),
        );

    // run it with hyper
    let addr = SocketAddr::from(([0, 0, 0, 0], 8000));
    info!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn ws_handler(
    Extension(queue): Extension<mpsc::Sender<WebSocket>>,
    ws: WebSocketUpgrade
) -> impl IntoResponse {
    ws.on_upgrade(|socket| handle_socket(queue, socket))
}

async fn handle_socket(queue: mpsc::Sender<WebSocket>, socket: WebSocket) {
    debug!("Client connected");
    queue.send(socket).await.unwrap_or_else(|e| {
        error!("can't join match making queue, reason: {}", e);
    });
}
