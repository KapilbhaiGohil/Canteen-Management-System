import express from 'express'; 
import { Order, Item, User } from '../models/models.js';
import { authenticate } from '../middlewares/middlewares.js';
import mongoose from 'mongoose';

const orderRouter = express.Router();

const generateUniqueOrderNumber = async (canteenId) => {
    let orderNumber;
    let exists = true;

    console.log('Generating unique order number for canteen:', canteenId);
    while (exists) {
        orderNumber = Math.floor(Math.random() * (999 - 100 + 1)) + 100;
        console.log(`Generated order number: ${orderNumber}`);
        exists = await Order.exists({ orderNumber, status: 'pending', canteenId });
        if (exists) console.log(`Order number ${orderNumber} already exists for canteen ${canteenId}. Generating again...`);
    }
    console.log(`Unique order number generated: ${orderNumber} for canteen ${canteenId}`);
    return orderNumber;
};


orderRouter.post('/createOrder', async (req, res) => {
    try {
        const { items, totalAmount, deviceId, canteenId } = req.body;
        console.log(req.body)
        const user = await User.findOne({ deviceId });
        if (!user) {
            return res.status(401).json({ error: 'Unauthorized request' });
        }
        const userId = user._id;

        if (!items || items.length === 0) {
            return res.status(400).json({ message: 'No items in the order' });
        }

        const orderNumber = await generateUniqueOrderNumber(canteenId);

        const newOrder = new Order({
            userId,
            canteenId:canteenId,  
            items,
            orderNumber,
            totalAmount,
            status: 'pending'
        });

        await newOrder.save();
        res.status(201).json({ message: 'Order placed successfully', order: newOrder });

    } catch (error) {
        res.status(500).json({ message: 'Error creating order', error: error.message });
    }
});

orderRouter.get('/getOrders', async (req, res) => {
    try {
        const { deviceId, canteenId } = req.query;
        console.log(deviceId,canteenId);
        const user = await User.findOne({ deviceId:deviceId });
        if (!user) {
            return res.status(401).json({ error: 'Unauthorized request' });
        }
        console.log(user._id);
        const orders = await Order.find({ userId: user._id, canteenId: new mongoose.Types.ObjectId(canteenId)  }) 
            .populate('items.itemId');
            console.log(orders)
        res.status(200).json({ orders });
    } catch (error) {
        res.status(500).json({ message: 'Error fetching orders', error: error.message });
    }
});

orderRouter.patch('/updateItemStatus', async (req, res) => {
    try {
        console.log("Received request to update item status:", req.body);

        const { orderId, itemId, status, canteenId } = req.body;

        if (!orderId || !itemId || !status || !canteenId) {
            console.log("Validation failed: Missing orderId, itemId, status, or canteenId");
            return res.status(400).json({ message: 'Order ID, Item ID, status, and canteenId are required' });
        }

        const order = await Order.findOne({ _id: orderId, canteenId }); // Filter by canteenId
        console.log("Order found:", order);

        if (!order) {
            console.log("Order not found for orderId:", orderId);
            return res.status(404).json({ message: 'Order not found' });
        }

        const item = order.items.find(i => i.itemId.toString() === itemId);
        if (item) {
            console.log("Updating item status:", { itemId, oldStatus: item.status, newStatus: status });
            item.status = status;
        } else {
            console.log("Item not found in order:", itemId);
            return res.status(404).json({ message: 'Item not found in order' });
        }

        const allCompleted = order.items.every(i => i.status === 'completed');
        const atLeastOneCompleted = order.items.some(i => i.status === 'completed');

        console.log("Status check:", { allCompleted, atLeastOneCompleted });

        if (allCompleted) {
            order.status = 'completed';
        } else if (atLeastOneCompleted) {
            order.status = 'Partial';
        } else {
            order.status = 'pending';
        }

        console.log("Final order status:", order.status);

        await order.save();
        console.log("Order updated successfully");
        res.status(200).json({ message: 'Order status updated', order });
    } catch (error) {
        console.error("Error updating order:", error);
        res.status(500).json({ message: 'Error updating order', error: error.message });
    }
});

orderRouter.get('/getPendingItems', async (req, res) => {
    try {
        console.log("Fetching orders with pending items...");
        const { canteenId } = req.query;

        let orders = await Order.find({ status: { $in: ['pending', 'Partial'] }, canteenId }) // Filter by canteenId
            .select('_id orderNumber items') 
            .populate('items.itemId', 'name imageUrl categoryId price canteenId isAvailable');

        orders = orders.map(order => {
            const filteredItems = order.items.filter(item => item.status === 'pending');
            return filteredItems.length > 0
                ? { _id: order._id, orderNumber: order.orderNumber, items: filteredItems } 
                : null;
        }).filter(order => order !== null); 

        console.log("Filtered orders ", orders);

        res.status(200).json({ orders });
    } catch (error) {
        console.error("Error fetching pending items:", error);
        res.status(500).json({ message: 'Error fetching pending items', error: error.message });
    }
});

orderRouter.get('/getCookedItems', async (req, res) => {
    try {
        console.log("Fetching orders with cooked items...");
        const { canteenId } = req.query;

        let orders = await Order.find({ status: { $in: ['pending', 'Partial'] }, canteenId }) // Filter by canteenId
            .select('_id orderNumber items') 
            .populate('items.itemId', 'name imageUrl categoryId price canteenId isAvailable');

        orders = orders.map(order => {
            const filteredItems = order.items.filter(item => item.status === 'cooked');
            return filteredItems.length > 0
                ? { _id: order._id, orderNumber: order.orderNumber, items: filteredItems } 
                : null;
        }).filter(order => order !== null); 

        console.log("Filtered orders ", orders);

        res.status(200).json({ orders });
    } catch (error) {
        console.error("Error fetching cooked items:", error);
        res.status(500).json({ message: 'Error fetching cooked items', error: error.message });
    }
});

export { orderRouter };
