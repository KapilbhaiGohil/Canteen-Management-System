import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    deviceId: { type: String, unique: true }, 
    role: { type: String, enum: ['foodProvider', 'manager', 'admin', 'foodMaker','user'], required: true },
    canteenId: { type: mongoose.Schema.Types.ObjectId, ref: 'Canteen' },
    refreshTokens: [{ type: String }]
}, { timestamps: true });

const canteenSchema = new mongoose.Schema({
    name: { type: String, required: true },
    collegeName: { type: String },
    imageUrl: { type: String },
    state: { type: String, required: true },
    district: { type: String, required: true },
    pinCode: { type: Number, required: true }
}, { timestamps: true });

const itemSchema = new mongoose.Schema({
    name: { type: String, required: true },
    imageUrl: { type: String },
    categoryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
    price: { type: Number, required: true },
    canteenId: { type: mongoose.Schema.Types.ObjectId, ref: 'Canteen', required: true },
    isAvailable: { type: Boolean, default: true }
}, { timestamps: true });

const categorySchema = new mongoose.Schema({
    name: { type: String, required: true },
    canteenId: { type: mongoose.Schema.Types.ObjectId, ref: 'Canteen', required: true },
    items: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Item' }],
    desc: { type: String, required: true }
}, { timestamps: true });

const orderSchema = new mongoose.Schema({
    deviceId: { type: String, required: true }, 
    items: [
        {
            itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Item', required: true },
            quantity: { type: Number, required: true },
            status: { type: String, enum: ['pending', 'completed', 'cancelled'], default: 'pending' }
        }
    ],
    orderNumber: { type: Number, required: true },
    status: { type: String, enum: ['pending', 'completed', 'cancelled'], default: 'pending' },
    totalAmount: { type: Number, required: true }
}, { timestamps: true });

const paymentSchema = new mongoose.Schema({
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    amount: { type: Number, required: true },
    status: { type: String, enum: ['pending', 'completed', 'failed', 'refunded'], default: 'pending' },
    paymentMethod: { type: String, enum: ['google_pay'], required: true },
    transactionId: { type: String }
}, { timestamps: true });

const User = mongoose.model('User', userSchema);
const Canteen = mongoose.model('Canteen', canteenSchema);
const Item = mongoose.model('Item', itemSchema);
const Order = mongoose.model('Order', orderSchema);
const Category = mongoose.model('Category', categorySchema);
const Payment = mongoose.model('Payment', paymentSchema);

export { User, Canteen, Item, Order, Category, Payment };
