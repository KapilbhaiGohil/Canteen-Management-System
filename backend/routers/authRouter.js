import express from 'express'; 
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { User, Canteen } from '../models/models.js';
import { authenticate, authorize } from '../middlewares/middlewares.js';

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

authRouter.post('/register',async (req, res) => {
    try {
        console.log("Register request received:", req.body);
        
        const { name, email, password, role, canteenId } = req.body;
        if (!name || !email || !password || !role) {
            console.log("Missing fields in registration");
            return res.status(400).json({ error: 'All fields are required!' });
        }

        if (canteenId) {
            const canteen = await Canteen.findById(canteenId);
            if (!canteen) {
                console.log("Invalid canteen ID");
                return res.status(404).json({ error: "Invalid canteen ID." });
            }
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            console.log("User already exists:", email);
            return res.status(409).json({ error: 'User with this email already exists.' });
        }
        const user = new User({ name, email, password, role, canteenId, refreshTokens: [] });
        await user.save();

        console.log("User registered successfully:", user._id);
        return res.status(201).json({ message: "User registered successfully!" });
    } catch (err) {
        console.error("Register error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/login', async (req, res) => {
    try {
        console.log("Login request received:", req.body);

        const { email, password } = req.body;
        if (!email || !password) {
            console.log("Missing email or password");
            return res.status(400).json({ error: 'Email and password are required.' });
        }

        const user = await User.findOne({ email });
        if (!user) {
            console.log("User not found:", email);
            return res.status(401).json({ error: 'Invalid email or password.' });
        }

        const match = await bcrypt.compare(password, user.password);
        if (!match) {
            console.log("Invalid password attempt for user:", email);
            return res.status(401).json({ error: 'Invalid email or password.' });
        }

        const tokens = generateTokens(user);
        user.refreshTokens.push(tokens.refreshToken);
        await user.save();

        console.log("Login successful for user:", user._id);
        return res.status(200).json(tokens);
    } catch (err) {
        console.error("Login error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/validateToken', async (req, res) => {
    try {
        console.log("Token validation request received. Checking headers...");
        
        const authHeader = req.headers.authorization;
        const accessToken = authHeader && authHeader.split(' ')[1];

        if (!accessToken) {
            console.log("No access token provided.");
            return res.status(400).json({ error: "Access token required." });
        }

        jwt.verify(accessToken, ACCESS_SECRET, async (err, decoded) => {
            if (err) {
                console.log("Token validation failed:", err.message);
                return res.status(403).json({ error: "Invalid or expired access token." });
            }
            
            const user = await User.findById(decoded.id);
            if (!user) {
                console.log("User not found for this token.");
                return res.status(404).json({ error: "User not found." });
            }

            console.log("Access token is valid for user:", user._id);
            return res.status(200).json({ message: "Access token is valid." });
        });
    } catch (err) {
        console.error("Token validation error:", err);
        return res.status(500).json({ error: "Internal server error." });
    }
});


authRouter.post('/refreshTokens', async (req, res) => {
    try {
        console.log("Refresh token request received:", req.body);

        const { refreshToken } = req.body;
        if (!refreshToken) return res.status(400).json({ error: "Refresh token required." });

        let decoded;
        try {
            decoded = jwt.verify(refreshToken, REFRESH_SECRET);
        } catch (err) {
            console.log("Invalid or expired refresh token");
            return res.status(403).json({ error: "Invalid or expired refresh token." });
        }

        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({ error: "User not found." });

        if (!user.refreshTokens.includes(refreshToken)) {
            console.log("Refresh token not recognized for user:", user._id);
            return res.status(403).json({ error: "Refresh token not recognized." });
        }

        const newTokens = generateTokens(user);
        user.refreshTokens = user.refreshTokens.filter(token => token !== refreshToken);
        user.refreshTokens.push(newTokens.refreshToken);
        await user.save();

        console.log("New tokens generated for user:", user._id);
        return res.status(200).json(newTokens);
    } catch (err) {
        console.error("Refresh token error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/logout', async (req, res) => {
    try {
        console.log("Logout request received:", req.body);

        const { refreshToken } = req.body;
        if (!refreshToken) return res.status(400).json({ error: "Refresh token required." });

        let decoded;
        try {
            decoded = jwt.verify(refreshToken, REFRESH_SECRET);
        } catch (err) {
            console.log("Invalid or expired refresh token");
            return res.status(403).json({ error: "Invalid or expired refresh token." });
        }

        const user = await User.findById(decoded.id);
        if (!user) return res.status(404).json({ error: "User not found." });

        user.refreshTokens = user.refreshTokens.filter(token => token !== refreshToken);
        await user.save();

        console.log("User logged out successfully:", user._id);
        return res.status(200).json({ message: "Successfully logged out." });
    } catch (err) {
        console.error("Logout error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});
authRouter.post('/userLogin', async (req, res) => {
    try {
        console.log("UserLogin request received:", req.body);

        const { deviceId } = req.body;
        if (!deviceId) {
            console.log("Missing device ID");
            return res.status(400).json({ error: 'Device ID is required.' });
        }

        let user = await User.findOne({ deviceId });

        if (!user) {
            console.log("Device ID not recognized, creating new user...");
            user = new User({ deviceId ,role:'user'});
            await user.save();
            console.log("New user created with device ID:", deviceId);
        }

        console.log("User login successful with device ID:", deviceId);
        return res.status(200).json({ message: "Login successful", userId: user._id });
    } catch (err) {
        console.error("UserLogin error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.get('/managers',authenticate,authorize(['admin']), async (req, res) => {
    try {
        console.log("Fetching managers with their canteen names...");

        const managers = await User.find({ role: 'manager' }).populate('canteenId', 'name');

        const managerList = managers.map(manager => ({
            id: manager._id,
            name: manager.name,
            email: manager.email,
            canteenName: manager.canteenId ? manager.canteenId.name : 'Not Assigned',
            canteenId:manager.canteenId._id
        }));

        console.log("Managers fetched successfully:", managerList);
        return res.status(200).json(managerList);
    } catch (err) {
        console.error("Error fetching managers:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.post('/registerUser',authenticate,authorize(['admin']),async (req, res) => {
    try {
        console.log("Register request received:", req.body);
        
        const { name, email, password, role, canteenId } = req.body;
        if (!name || !email || !password || !role) {
            console.log("Missing fields in registration");
            return res.status(400).json({ error: 'All fields are required!' });
        }

        if (canteenId) {
            const canteen = await Canteen.findById(canteenId);
            if (!canteen) {
                console.log("Invalid canteen ID");
                return res.status(404).json({ error: "Invalid canteen ID." });
            }
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            console.log("User already exists:", email);
            return res.status(409).json({ error: 'User with this email already exists.' });
        }
 
        const user = new User({ name, email, password, role, canteenId, refreshTokens: [] });
        console.log(user)
        await user.save();

        console.log("User registered successfully:", user._id);
        return res.status(201).json({ message: "User registered successfully!" });
    } catch (err) {
        console.error("Register error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.put('/updateUser', authenticate, authorize(['admin']), async (req, res) => {
    try {
        console.log("Update manager request received:", req.body);

        const { managerId, name, email, role, canteenId } = req.body;
        if (!managerId || !name || !email || !role) {
            console.log("Missing fields in update request");
            return res.status(400).json({ error: 'All fields are required!' });
        }

        const manager = await User.findById(managerId);
        if (!manager) {
            console.log("Manager not found");
            return res.status(404).json({ error: 'Manager not found.' });
        }

        if (canteenId) {
            const canteen = await Canteen.findById(canteenId);
            if (!canteen) {
                console.log("Invalid canteen ID");
                return res.status(404).json({ error: "Invalid canteen ID." });
            }
        }

        manager.name = name;
        manager.email = email;
        manager.role = role;
        manager.canteenId = canteenId;

        await manager.save();

        console.log("Manager updated successfully:", manager._id);
        return res.status(200).json({ message: "Manager updated successfully!" });
    } catch (err) {
        console.error("Update error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

authRouter.delete('/deleteUser', authenticate, authorize(['admin']), async (req, res) => {
    try {
        console.log("Delete manager request received:", req.body);

        const { managerId } = req.body;
        if (!managerId) {
            console.log("Manager ID is required");
            return res.status(400).json({ error: 'Manager ID is required!' });
        }

        const manager = await User.findById(managerId);
        if (!manager) {
            console.log("Manager not found");
            return res.status(404).json({ error: 'Manager not found.' });
        }

        await User.findByIdAndDelete(managerId);

        console.log("Manager deleted successfully:", managerId);
        return res.status(200).json({ message: "Manager deleted successfully!" });
    } catch (err) {
        console.error("Delete error:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

export { authRouter };