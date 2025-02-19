import { User } from "../models/models.js";
import jwt from 'jsonwebtoken';
import '../env.js'

export const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Unauthorized request' });
        }

        const token = authHeader.split(' ')[1];
        console.log("Received Token:", token);

        const decoded = jwt.verify(token, process.env.ACCESS_SECRET);
        console.log("Decoded Token:", decoded);

        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({ error: "User not found." });

        console.log("Authenticated User:", user);
        req.user = user;
        next();
    } catch (err) {
        console.error("Authentication Error:", err);
        return res.status(403).json({ error: 'Forbidden' });
    }
};

export const authorize = (roles) => (req, res, next) => {
    if (!roles.includes(req.user.role)) {
        return res.status(403).json({ error: 'Access denied' });
    }
    next();
};