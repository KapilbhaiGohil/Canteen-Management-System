import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ['foodProvider', 'admin', 'foodMaker'], required: true },
    canteenId: { type: mongoose.Schema.Types.ObjectId, ref: 'Canteen', required: true }
}, { timestamps: true });

const canteenSchema = new mongoose.Schema({
    name: { type: String, required: true },
    collegeName: { type: String },
    address: { type: String, required: true }
}, { timestamps: true });

const menuItemSchema = new mongoose.Schema({
    name: { type: String, required: true },
    imageUrl: { type: String },
    category: { type: String, required: true },
    price: { type: Number, required: true },
    canteenId: { type: mongoose.Schema.Types.ObjectId, ref: 'Canteen', required: true },
    isAvailable: { type: Boolean, default: true }
}, { timestamps: true });

const orderSchema = new mongoose.Schema({
    items: [
        {
            itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'MenuItem', required: true },
            quantity: { type: Number, required: true },
            status: { type: String, enum: ['pending', 'completed', 'cancelled'], default: 'pending' }
        }
    ],
    orderNumber: { type: Number, required: true },
    status: { type: String, enum: ['pending', 'completed', 'cancelled'], default: 'pending' },
    totalAmount: { type: Number, required: true }
    
}, { timestamps: true });

const User = mongoose.model('User', userSchema);
const Canteen = mongoose.model('Canteen', canteenSchema);
const MenuItem = mongoose.model('MenuItem', menuItemSchema);
const Order = mongoose.model('Order', orderSchema);

export { User, Canteen, MenuItem, Order };