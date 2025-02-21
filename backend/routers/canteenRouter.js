import express from 'express'; 
import { Canteen,User,Item,Category } from '../models/models.js';
import { authenticate, authorize } from '../middlewares/middlewares.js';
import { upload,deleteImageFromCloudinary } from '../utils/upload.js';

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

canteenRouter.delete('/delete', authenticate, authorize(['admin']), async (req, res) => {
    try {
        const { canteenId } = req.body;
        console.log(`Received request to delete canteen with ID: ${canteenId}`);

        const canteen = await Canteen.findById(canteenId);
        if (!canteen) {
            console.log("Canteen not found");
            return res.status(404).json({ error: "Canteen not found" });
        }

        if (canteen.imageUrl) {
            const imageId = canteen.imageUrl.split('/').pop().split('.')[0];
            await deleteImageFromCloudinary(imageId);
            console.log("Image deleted from Cloudinary:", imageId);
        }

        const deletedUsers = await User.deleteMany({ canteenId });
        console.log("Deleted users:", deletedUsers.deletedCount);

        const deletedItems = await Item.deleteMany({ canteenId });
        console.log("Deleted items:", deletedItems.deletedCount);

        const deletedCategories = await Category.deleteMany({ canteenId });
        console.log("Deleted categories:", deletedCategories.deletedCount);

        await Canteen.findByIdAndDelete(canteenId);
        console.log("Canteen deleted successfully");

        res.status(200).json({ message: "Canteen and associated data deleted successfully" });

    } catch (err) {
        console.error("Error deleting canteen:", err);
        res.status(500).json({ error: "Internal server error" });
    }
});
canteenRouter.put('/update', authenticate, authorize(['admin']), upload.single('image'), async (req, res) => {
    try {
        console.log("Received request to update canteen");

        const { canteenId, name, collegeName, district, state, pincode } = req.body;
        console.log("Request body:", req.body);

        if (!canteenId) {
            console.log("Validation failed: Missing canteenId");
            return res.status(400).json({ error: 'Canteen ID is required' });
        }

        const canteen = await Canteen.findById(canteenId);
        if (!canteen) {
            console.log("Canteen not found");
            return res.status(404).json({ error: "Canteen not found" });
        }

        let imageUrl = canteen.imageUrl;
        if (req.file) {
            if (canteen.imageUrl) {
                const imageId = canteen.imageUrl.split('/').pop().split('.')[0];
                await deleteImageFromCloudinary(imageId);
                console.log("Old image deleted from Cloudinary:", imageId);
            }
            imageUrl = req.file.path;
            console.log("New image uploaded:", imageUrl);
        }

        const updatedCanteen = await Canteen.findByIdAndUpdate(
            canteenId,
            {
                name: name || canteen.name,
                collegeName: collegeName || canteen.collegeName,
                district: district || canteen.district,
                state: state || canteen.state,
                pinCode: pincode || canteen.pinCode,
                imageUrl: imageUrl
            },
            { new: true }
        );

        console.log("Canteen updated successfully:", updatedCanteen);
        res.status(200).json({ message: "Canteen updated successfully", canteen: updatedCanteen });

    } catch (err) {
        console.error("Error updating canteen:", err);
        res.status(500).json({ error: "Internal server error" });
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
