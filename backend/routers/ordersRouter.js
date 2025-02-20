import express from 'express'; 
import { Order, Item } from '../models/models.js';

const orderRouter = express.Router();

const generateUniqueOrderNumber = async () => {
    let orderNumber;
    let exists = true;

    console.log('Generating unique order number...');
    while (exists) {
        orderNumber = Math.floor(Math.random() * (999 - 100 + 1)) + 100;
        console.log(`Generated order number: ${orderNumber}`);
        exists = await Order.exists({ orderNumber, status: 'pending' });
        if (exists) console.log(`Order number ${orderNumber} already exists. Generating again...`);
    }
    console.log(`Unique order number generated: ${orderNumber}`);
    return orderNumber;
};

orderRouter.post('/placeOrder', async (req, res) => {
    try {
        const { items } = req.body;
        console.log('Place order request received:', items);

        if (!items || !items.length) {
            console.log('Items array is empty or not provided.');
            return res.status(400).json({ error: 'Items are required' });
        }

        // Calculate total amount
        let totalAmount = 0;
        for (const item of items) {
            console.log(`Fetching item details for ID: ${item.itemId}`);
            const product = await Item.findById(item.itemId);
            if (!product) {
                console.log(`Item with ID ${item.itemId} not found.`);
                return res.status(404).json({ error: `Item with ID ${item.itemId} not found` });
            }
            totalAmount += product.price * item.quantity;
        }

        console.log(`Total amount calculated: ${totalAmount}`);

        const orderNumber = await generateUniqueOrderNumber();

        const newOrder = new Order({
            items,
            orderNumber,
            totalAmount
        });

        await newOrder.save();
        console.log('Order placed successfully:', newOrder);
        res.status(201).json({ message: 'Order placed successfully', order: newOrder });

    } catch (err) {
        console.error("Error placing order:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

orderRouter.post('/updateOrder', async (req, res) => {
    try {
        const { orderId, status } = req.body;
        console.log(`Update order request received: Order ID - ${orderId}, Status - ${status}`);

        if (!orderId || !status) {
            console.log('Order ID or status is missing.');
            return res.status(400).json({ error: 'Order ID and status are required' });
        }

        const order = await Order.findByIdAndUpdate(orderId, { status }, { new: true });

        if (!order) {
            console.log(`Order with ID ${orderId} not found.`);
            return res.status(404).json({ error: 'Order not found' });
        }

        console.log('Order updated successfully:', order);
        res.status(200).json({ message: 'Order updated successfully', order });

    } catch (err) {
        console.error("Error updating order:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

orderRouter.post('/deleteOrder', async (req, res) => {
    try {
        const { orderId } = req.body;
        console.log(`Delete order request received: Order ID - ${orderId}`);

        if (!orderId) {
            console.log('Order ID is missing.');
            return res.status(400).json({ error: 'Order ID is required' });
        }

        const order = await Order.findByIdAndDelete(orderId);

        if (!order) {
            console.log(`Order with ID ${orderId} not found.`);
            return res.status(404).json({ error: 'Order not found' });
        }

        console.log('Order deleted successfully.');
        res.status(200).json({ message: 'Order deleted successfully' });

    } catch (err) {
        console.error("Error deleting order:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

export { orderRouter };
