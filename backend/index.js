import express from 'express'; 
import bodyParser from 'body-parser';
import './env.js'
import {connect} from './config/conn.js';
import { authRouter } from './routers/authRouter.js';
import { menuRouter } from './routers/menuRouter.js';
import { orderRouter } from './routers/ordersRouter.js';
import { canteenRouter } from './routers/canteenRouter.js';

const app = express();
await connect();
app.use(bodyParser.json())
app.use('/auth',authRouter);
app.use('/canteen',canteenRouter);
app.use('/menu',menuRouter);
app.use('/orders',orderRouter);

const port = process.env.PORT
app.listen(port,(e)=>{
    if(e)console.log(e);
    else console.log("Server is running on port : ",port);
})