import WebSocket from 'ws';

const socket = new WebSocket("ws://127.0.0.1:8081/");


socket.on("open", () => {
    console.log("✅ Connected to WebSocket server");
    socket.send(JSON.stringify({ event: "watchOrders", canteenId: "your-canteen-id" }));
});

socket.on("message", (data) => {
    console.log("📩 Message received:", data.toString());
});

socket.on("error", (err) => {
    console.error("🚨 WebSocket Error:", err);
});

socket.on("close", () => {
    console.log("❌ Connection closed");
});
