import mongoose from 'mongoose';
import bcrypt from 'bcrypt'

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['foodProvider','manager', 'admin', 'foodMaker'], required: true },
    canteenId: { type: mongoose.Schema.Types.ObjectId, ref: 'Canteen'},
    refreshTokens: [{ type: String }],
}, { timestamps: true });

userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) return next();
    this.password = await bcrypt.hash(this.password, 10);
    next();
})
userSchema.methods.comparePassword = function (password) {
    return bcrypt.compare(password, this.password);
};
const canteenSchema = new mongoose.Schema({
    name: { type: String, required: true },
    collegeName: { type: String },
    imageUrl: { type: String },
    address: { type: String, required: true }
}, { timestamps: true });

const menuSchema = new mongoose.Schema({
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
            itemId: { type: mongoose.Schema.Types.ObjectId, ref: 'Menu', required: true },
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
const Menu = mongoose.model('Menu', menuSchema);
const Order = mongoose.model('Order', orderSchema);

export { User, Canteen, Menu, Order };