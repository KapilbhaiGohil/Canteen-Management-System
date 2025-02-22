import express from 'express';
import { Item, Category } from '../models/models.js';
import { authenticate, authorize } from '../middlewares/middlewares.js';
import { upload } from '../utils/upload.js';
import mongoose from 'mongoose';

const itemRouter = express.Router();

itemRouter.post('/createCategory', authenticate, authorize(['admin', 'manager']), async (req, res) => {
    console.log('Request to createCategory:', req.body);
    try {
        const { name, canteenId, desc } = req.body;
        if (!name || !canteenId || !desc) {
            console.log('Missing required fields for createCategory');
            return res.status(400).json({ error: 'All fields are required' });
        }
        const newCategory = new Category({ name, canteenId,desc});
        await newCategory.save();
        console.log('Category created:', newCategory);
        res.status(201).json({ message: 'Category created successfully', category: newCategory });
    } catch (err) {
        console.error('Error in createCategory:', err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

itemRouter.post('/createItem', authenticate, authorize(['admin', 'manager']), upload.single('image'), async (req, res) => {
    console.log('Request to createItem:', req.body);
    try {
        const { name, categoryId, price, canteenId } = req.body;
        if (!name || !categoryId || !price || !canteenId) {
            console.log('Missing required fields for createItem');
            return res.status(400).json({ error: 'All fields are required' });
        }
        const imageUrl = req.file ? req.file.path : null;
        console.log('Image uploaded:', imageUrl);
        const newItem = new Item({ name, categoryId, price, canteenId, imageUrl });
        await newItem.save();
        console.log('Item created:', newItem);

        await Category.findByIdAndUpdate(categoryId, { $push: { items: newItem._id } });
        console.log('Item added to category:', categoryId);

        res.status(201).json({ message: 'Item created successfully', item: newItem });
    } catch (err) {
        console.error('Error in createItem:', err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});
itemRouter.post('/updateCategory', authenticate, authorize(['admin', 'manager']), async (req, res) => {
    console.log('Request to updateCategory:', req.body);
    try {
        const { categoryId, name, desc } = req.body;

        if (!categoryId || (!name && !desc)) {
            console.log('Missing required fields for updateCategory');
            return res.status(400).json({ error: 'Category ID and at least one field (name or desc) are required' });
        }

        console.log('Updating category with ID:', categoryId);
        const updatedCategory = await Category.findByIdAndUpdate(
            categoryId, 
            { ...(name && { name }), ...(desc && { desc }) }, 
            { new: true }
        );

        if (!updatedCategory) {
            console.log('Category not found:', categoryId);
            return res.status(404).json({ error: 'Category not found' });
        }

        console.log('Category updated:', updatedCategory);
        res.status(200).json({ message: 'Category updated successfully', category: updatedCategory });
    } catch (err) {
        console.error('Error in updateCategory:', err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

itemRouter.post('/removeItem', authenticate, authorize(['admin', 'manager']), async (req, res) => {
    console.log('Request to removeItem:', req.body);
    try {
        const { itemId } = req.body;
        const item = await Item.findByIdAndDelete(itemId);
        if (item) {
            await Category.findByIdAndUpdate(item.categoryId, { $pull: { items: itemId } });
            console.log('Item removed from category:', item.categoryId);
        }
        res.status(200).json({ message: 'Item removed successfully' });
    } catch (err) {
        console.error('Error in removeItem:', err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

itemRouter.post('/removeCategory', authenticate, authorize(['admin', 'manager']), async (req, res) => {
    console.log('Request to removeCategory:', req.body);
    try {
        const { categoryId } = req.body;

        await Item.deleteMany({ categoryId });
        console.log('All items removed for category:', categoryId);

        await Category.findByIdAndDelete(categoryId);
        console.log('Category removed:', categoryId);

        res.status(200).json({ message: 'Category removed successfully' });
    } catch (err) {
        console.error('Error in removeCategory:', err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

itemRouter.post('/updateItem', authenticate, authorize(['admin', 'manager']), upload.single('image'), async (req, res) => {
    console.log('Request to updateItem:', req.body);

    try {
        const { itemId, name, categoryId, price, isAvailable } = req.body;
        const imageUrl = req.file ? req.file.path : undefined;

        const item = await Item.findById(itemId);
        if (!item) {
            return res.status(404).json({ error: 'Item not found' });
        }

        const oldCategoryId = item.categoryId.toString();

        const updatedItem = await Item.findByIdAndUpdate(
            itemId,
            { name, categoryId, price, isAvailable, ...(imageUrl && { imageUrl }) },
            { new: true }
        );

        if (!updatedItem) {
            return res.status(500).json({ error: 'Failed to update item' });
        }

        if (oldCategoryId !== categoryId) {
            await Category.findByIdAndUpdate(oldCategoryId, { $pull: { items: itemId } });
            await Category.findByIdAndUpdate(categoryId, { $push: { items: itemId } });
        }

        console.log('Item updated:', updatedItem);
        res.status(200).json({ message: 'Item updated successfully', item: updatedItem });

    } catch (err) {
        console.error('Error in updateItem:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});


itemRouter.get('/retriveItemsByCategory', async (req, res) => {
    console.log('Request to retrieve items by category');
    try {
        const {canteenId} = req.query;
        const categories = await Category.find({canteenId:canteenId}).populate('items');
        console.log('Categories with items retrieved:', categories.length);
        res.status(200).json(categories);
    } catch (err) {
        console.error('Error in retrieveItemsByCategory:', err);
        res.status(500).json({ error: 'Internal server error.' });
    }
});

export { itemRouter };