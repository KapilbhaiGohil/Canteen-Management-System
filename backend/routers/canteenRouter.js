import express from 'express'; 
import { Canteen } from '../models/models.js';
import { authenticate, authorize } from '../middlewares/middlewares.js';
import { upload } from '../utils/upload.js';

const canteenRouter = express.Router();

canteenRouter.post('/create', authenticate, authorize(['admin']), upload.single('image'), async (req, res) => {
    try {
        console.log("Received request to create canteen");

        const { name, collegeName, district, state, pincode } = req.body;
        console.log("Request body:", req.body);

        if (!name || !collegeName || !district || !state || !pincode) {
            console.log("Validation failed: Missing required fields");
            return res.status(400).json({ error: 'All fields are required' });
        }

        const imageUrl = req.file ? req.file.path : null;
        console.log("Uploaded Image URL:", imageUrl);

        const newCanteen = new Canteen({
            collegeName,
            district,
            name,
            pinCode: pincode,
            imageUrl,
            state
        });

        await newCanteen.save();
        console.log("Canteen created successfully:", newCanteen);

        res.status(201).json({ message: 'Canteen created successfully', canteen: newCanteen });

    } catch (err) {
        console.error("Error creating canteen:", err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

canteenRouter.get('/get', authenticate, authorize(['admin']), async (req, res) => {
    try {
        console.log("Received request to get all canteens");

        const canteens = await Canteen.find();
        console.log("Fetched canteens:", canteens);

        return res.json(canteens);
    } catch (err) {
        console.error("Error fetching canteens:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

canteenRouter.post('/', async (req, res) => {
    try {
        console.log("Received an empty POST request to /canteen");
        const {} = req.body;

    } catch (err) {
        console.error("Error handling request:", err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});

export { canteenRouter };
