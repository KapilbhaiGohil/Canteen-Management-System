import express from 'express'; 
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { User, Canteen } from '../models/models.js';

const authRouter = express.Router();

const ACCESS_SECRET = process.env.ACCESS_SECRET;
const REFRESH_SECRET = process.env.REFRESH_SECRET;
const ACCESS_TOKEN_EXPIRY = process.env.ACCESS_TOKEN_EXPIRY || '15m';
const REFRESH_TOKEN_EXPIRY = process.env.REFRESH_TOKEN_EXPIRY || '7d';

const generateTokens = (user) => {
    const accessToken = jwt.sign({ id: user._id }, ACCESS_SECRET, { expiresIn: ACCESS_TOKEN_EXPIRY });
    const refreshToken = jwt.sign({ id: user._id }, REFRESH_SECRET, { expiresIn: REFRESH_TOKEN_EXPIRY });
    return { accessToken, refreshToken };
};

authRouter.post('/register', async (req, res) => {
    try {
        const { name, email, password, role, canteenId } = req.body;
        if (!name || !email || !password || !role) {
            return res.status(400).json({ error: 'All fields are required!' });
        }
        if (canteenId) {
            const canteen = await Canteen.findById(canteenId);
            if (!canteen) return res.status(404).json({ error: "Invalid canteen ID." });
        }
        const existingUser = await User.findOne({ email });
        if (existingUser) return res.status(409).json({ error: 'User with this email already exists.' });

        const hashedPassword = await bcrypt.hash(password, 10);
        const user = new User({ name, email, password: hashedPassword, role, canteenId, refreshTokens: [] });
        await user.save();

        return res.status(201).json({ message: "User registered successfully!" });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required.' });
        }

        const user = await User.findOne({ email });
        if (!user) return res.status(401).json({ error: 'Invalid email or password.' });

        const match = await bcrypt.compare(password, user.password);
        if (!match) return res.status(401).json({ error: 'Invalid email or password.' });

        const tokens = generateTokens(user);
        user.refreshTokens.push(tokens.refreshToken);
        await user.save();

        return res.status(200).json(tokens);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/refreshTokens', async (req, res) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) return res.status(400).json({ error: "Refresh token required." });

        let decoded;
        try {
            decoded = jwt.verify(refreshToken, REFRESH_SECRET);
        } catch (err) {
            return res.status(403).json({ error: "Invalid or expired refresh token." });
        }

        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({ error: "User not found." });

        if (!user.refreshTokens.includes(refreshToken)) {
            return res.status(403).json({ error: "Refresh token not recognized." });
        }

        const newTokens = generateTokens(user);
        user.refreshTokens = user.refreshTokens.filter(token => token !== refreshToken);
        user.refreshTokens.push(newTokens.refreshToken);
        await user.save();

        return res.status(200).json(newTokens);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/logout', async (req, res) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) return res.status(400).json({ error: "Refresh token required." });

        let decoded;
        try {
            decoded = jwt.verify(refreshToken, REFRESH_SECRET);
        } catch (err) {
            return res.status(403).json({ error: "Invalid or expired refresh token." });
        }

        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({ error: "User not found." });

        if (!user.refreshTokens.includes(refreshToken)) {
            return res.status(403).json({ error: "Refresh token not recognized." });
        }

        user.refreshTokens = user.refreshTokens.filter(token => token !== refreshToken);
        await user.save();

        return res.status(200).json({ message: "Successfully logged out." });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/logout-from-all', async (req, res) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) return res.status(400).json({ error: "Refresh token required." });

        let decoded;
        try {
            decoded = jwt.verify(refreshToken, REFRESH_SECRET);
        } catch (err) {
            return res.status(403).json({ error: "Invalid or expired refresh token." });
        }

        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({ error: "User not found." });

        if (!user.refreshTokens.includes(refreshToken)) {
            return res.status(403).json({ error: "Refresh token not recognized or already logged out from all devices." });
        }

        user.refreshTokens = [];
        await user.save();

        return res.status(200).json({ message: "Successfully logged out from all devices." });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});


export { authRouter };