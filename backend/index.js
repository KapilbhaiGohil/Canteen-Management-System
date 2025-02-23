import express from 'express';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import { Order } from './models/models.js';
import { connect } from './config/conn.js';
import { authRouter } from './routers/authRouter.js';
import { itemRouter } from './routers/itemRouter.js';
import { orderRouter } from './routers/ordersRouter.js';
import { canteenRouter } from './routers/canteenRouter.js';
import { paymentRouter } from './routers/paymentRouter.js';
import { WebSocketServer } from 'ws';
import http from 'http';

const app = express();
await connect();

// Create HTTP Server for WebSocket
const server = http.createServer(app);
const wss = new WebSocketServer({ server });

const WS_PORT = 8081;
const orderStreams = {};

server.listen(WS_PORT, () => {
    console.log(`✅ WebSocket server running on port ${WS_PORT}`);
});

wss.on("connection", (ws) => {
    console.log("🔗 New WebSocket Client Connected");

    ws.on("message", async (message) => {
        try {
            const { event, canteenId } = JSON.parse(message);
            console.log(`📌 Received event: ${event}, Canteen ID: ${canteenId}`);

            if (event === "watchOrders") {
                if (!mongoose.Types.ObjectId.isValid(canteenId)) {
                    console.log(`❌ Invalid canteenId: ${canteenId}`);
                    ws.send(JSON.stringify({ error: "Invalid canteenId" }));
                    return;
                }

                if (!orderStreams[canteenId]) {
                    console.log(`🔍 Starting order watch for canteen: ${canteenId}`);

                    const orderChangeStream = Order.watch([
                        { $match: { "fullDocument.canteenId": new mongoose.Types.ObjectId(canteenId) } }
                    ]);

                    orderChangeStream.on("change", (change) => {
                        console.log(`✅ Order updated for canteen: ${canteenId}`);
                        ws.send(JSON.stringify(change.fullDocument));
                    });

                    orderStreams[canteenId] = orderChangeStream;
                }
            }
        } catch (error) {
            console.error(`🚨 Error in WebSocket message:`, error);
            ws.send(JSON.stringify({ error: "Invalid request" }));
        }
    });

    ws.on("close", () => {
        console.log("❌ WebSocket Client Disconnected");
    });
});

// Middleware for Express Routes
app.use(bodyParser.json());
app.use('/auth', authRouter);
app.use('/canteen', canteenRouter);
app.use('/item', itemRouter);
app.use('/order', orderRouter);
app.use('/payment', paymentRouter);

const port = process.env.PORT || 5000;
app.listen(port, () => {
    console.log("🚀 HTTP Server running on port:", port);
});
