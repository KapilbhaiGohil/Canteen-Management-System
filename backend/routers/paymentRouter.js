import express from 'express';
import { Order, Payment } from '../models/models.js';

const paymentRouter = express.Router();

paymentRouter.post('/initiate', async (req, res) => {
    try {
        const { orderId, amount } = req.body;
        console.log(`Initiating payment for Order ID: ${orderId}, Amount: ${amount}`);

        if (!orderId || !amount) {
            console.log('Missing Order ID or amount.');
            return res.status(400).json({ error: 'Order ID and amount are required' });
        }

        const payment = new Payment({
            orderId,
            amount,
            status: 'pending',
            paymentMethod: 'google_pay'
        });

        await payment.save();
        console.log('Payment initiated:', payment);
        res.status(201).json({ message: 'Payment initiated', payment });

    } catch (err) {
        console.error("Error initiating payment:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

paymentRouter.post('/successfull', async (req, res) => {
    try {
        const { orderId, transactionId } = req.body;
        console.log(`Processing successful payment for Order ID: ${orderId}, Transaction ID: ${transactionId}`);

        if (!orderId || !transactionId) {
            console.log('Missing Order ID or transaction ID.');
            return res.status(400).json({ error: 'Order ID and transaction ID are required' });
        }

        const payment = await Payment.findOneAndUpdate(
            { orderId },
            { status: 'completed', transactionId },
            { new: true }
        );

        if (!payment) {
            console.log(`No payment record found for Order ID: ${orderId}`);
            return res.status(404).json({ error: 'Payment record not found' });
        }

        await Order.findByIdAndUpdate(orderId, { status: 'completed' });
        console.log('Payment marked as completed for Order ID:', orderId);

        res.status(200).json({ message: 'Payment successful' });

    } catch (err) {
        console.error("Error processing successful payment:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

paymentRouter.post('/failed', async (req, res) => {
    try {
        const { orderId } = req.body;
        console.log(`Processing failed payment for Order ID: ${orderId}`);

        if (!orderId) {
            console.log('Missing Order ID.');
            return res.status(400).json({ error: 'Order ID is required' });
        }

        await Payment.findOneAndUpdate(
            { orderId },
            { status: 'failed' },
            { new: true }
        );

        await Order.findByIdAndUpdate(orderId, { status: 'cancelled' });
        console.log(`Payment failed and order cancelled for Order ID: ${orderId}`);

        res.status(200).json({ message: 'Payment failed' });

    } catch (err) {
        console.error("Error handling failed payment:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

paymentRouter.post('/refund', async (req, res) => {
    try {
        const { orderId } = req.body;
        console.log(`Processing refund for Order ID: ${orderId}`);

        if (!orderId) {
            console.log('Missing Order ID.');
            return res.status(400).json({ error: 'Order ID is required' });
        }

        const payment = await Payment.findOne({ orderId });
        console.log('Payment record found:', payment);

        if (!payment || payment.status !== 'completed') {
            console.log(`Refund not possible for Order ID: ${orderId}`);
            return res.status(400).json({ error: 'Refund not possible for this order' });
        }

        await Payment.findOneAndUpdate({ orderId }, { status: 'refunded' });
        console.log(`Refund processed successfully for Order ID: ${orderId}`);

        res.status(200).json({ message: 'Refund processed' });

    } catch (err) {
        console.error("Error processing refund:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

export { paymentRouter };
