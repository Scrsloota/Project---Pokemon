use axum::extract::ws::{Message, WebSocket};
use rand::{distributions::Uniform, prelude::*};
use std::collections::VecDeque;
use tokio;
use tokio::sync::mpsc::Receiver;
use tracing::{debug, info, warn};

async fn relay_handshake(
    mut client1: WebSocket,
    mut client2: WebSocket,
    id1: u32,
    id2: u32,
) -> Result<(), axum::Error> {
    client1.send(Message::Text(format!("init {}", id1))).await?;
    client2.send(Message::Text(format!("init {}", id2))).await?;
    client1.send(Message::Text(format!("peer {}", id2))).await?;
    client2.send(Message::Text(format!("peer {}", id1))).await?;

    loop {
        let (flag, msg) = tokio::select! {
            Some(Ok(msg)) = client1.recv() => (true, msg),
            Some(Ok(msg)) = client2.recv() => (false, msg),
            else => {
                warn!("unexpected handshake end");
                break;
            }
        };
        match msg {
            Message::Close(_) => {
                debug!("handshake end");
                client1.close().await?;
                client2.close().await?;
                return Ok(());
            }
            _ => {
                debug!("{}\n{:#?}", flag, msg);
                if flag {
                    client2.send(msg).await?
                } else {
                    client1.send(msg).await?
                }
            }
        }
    }

    Ok(())
}

fn generate_id_pair(rng: &mut StdRng, sampler: &mut Uniform<u32>) -> (u32, u32) {
    let (id1, id2) = (1, sampler.sample(rng));
    info!("{} {}", id1, id2);
    if id1 < id2 {
        (id1, id2)
    } else if id1 > id2 {
        (id2, id1)
    } else {
        (id1, id1 + 1)
    }
}

async fn test_client_alive(client: &mut WebSocket) -> bool {
    if client.send(Message::Ping(Vec::new())).await.is_err() {
        return false
    }
    match client.recv().await {
        Some(Ok(Message::Pong(_))) => return true,
        _ => return false
    }
}

pub async fn match_queue(mut queue: Receiver<WebSocket>) -> ! {
    let mut rng = StdRng::from_entropy();
    let mut sampler = Uniform::new_inclusive(0, 2147483647);
    let mut clients = VecDeque::new();
    loop {
        let mut idx = 0;
        while clients.len() >= 2 {
            if test_client_alive(&mut clients[idx]).await {
                idx += 1;

                if idx >= 2 {
                    let client1 = clients.pop_front().unwrap();
                    let client2 = clients.pop_front().unwrap();
                    info!("Match found");
                    let (id1, id2) = generate_id_pair(&mut rng, &mut sampler);
                    tokio::spawn(async move {
                        relay_handshake(client1, client2, id1, id2)
                            .await
                            .unwrap_or_else(|e| {
                                warn!("{}", e);
                            });
                    });
                    idx = 0
                }
            }
            else {
                // pop dead clients
                warn!("Dead client kicked");
                clients.remove(idx).unwrap();
            }
        }

        clients.push_back(queue.recv().await.unwrap())
    }
}
