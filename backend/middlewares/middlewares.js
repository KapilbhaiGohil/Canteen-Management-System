import { User } from "../models/models";

export const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Unauthorized request' });
        }

        const token = authHeader.split(' ')[1];
        const decoded = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);
        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({error:"User not found."})
        req.user = user;
        next();
    } catch (err) {
        return res.status(403).json({ error: 'Forbidden' });
    }
};

export const authorize = (roles) => (req, res, next) => {
    if (!roles.includes(req.user.role)) {
        return res.status(403).json({ error: 'Access denied' });
    }
    next();
};