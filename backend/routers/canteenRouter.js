import express from 'express'; 
const canteenRouter = express.Router();
import {Canteen} from '../models/models.js';
import { authenticate, authorize } from '../middlewares/middlewares.js';

canteenRouter.post('/create', authenticate,authorize(['admin']),async (req, res) => {
    try {
        const {} = req.body;
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});
canteenRouter.post('/', async (req, res) => {
    try {
        const {} = req.body;
        
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: 'Internal server error.' });
    }
});
export {canteenRouter};