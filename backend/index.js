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
import { createServer } from 'http';
import { Server } from 'socket.io';

const app = express();
await connect();
// 👉 WebSocket server on port 8081
const wsServer = createServer();
const io = new Server(wsServer, {
    cors: { origin: "*", methods: ["GET", "POST"] }
});

const WS_PORT = 8081;
wsServer.listen(WS_PORT, () => {
    console.log(`✅ WebSocket server running on port ${WS_PORT}`);
});

const orderStreams = {};

io.on("connection", (socket) => {
    console.log("🔗 WebSocket Client connected:", socket.id);

    socket.on("watchOrders", async (data) => {
        try {
            const { canteenId } = JSON.parse(data);
            console.log(`📌 watchOrders event from ${socket.id} for canteenId: ${canteenId}`);

            if (!mongoose.Types.ObjectId.isValid(canteenId)) {
                console.log(`❌ Invalid canteenId from ${socket.id}`);
                socket.emit("error", { message: "Invalid canteenId" });
                return;
            }

            if (!orderStreams[canteenId]) {
                console.log(`🔍 Starting new order watch for canteen: ${canteenId}`);

                const orderChangeStream = Order.watch([
                    { $match: { "fullDocument.canteenId": new mongoose.Types.ObjectId(canteenId) } }
                ]);

                orderChangeStream.on("change", (change) => {
                    console.log(`✅ Order updated for canteen: ${canteenId}`);
                    io.emit("orderUpdated", change.fullDocument);
                });

                orderStreams[canteenId] = orderChangeStream;
            }

            socket.on("disconnect", () => {
                console.log(`❌ Client disconnected: ${socket.id}`);
            });

        } catch (error) {
            console.error(`🚨 Error in watchOrders from ${socket.id}:`, error);
            socket.emit("error", { message: "Invalid request" });
        }
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
    console.log("Server is running on port:", port);
});
