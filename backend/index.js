import express from 'express'; 
import './env.js'
import {connect} from './config/conn.js';

const app = express();

await connect();

const port = process.env.PORT
app.listen(port,(e)=>{
    if(e)console.log(e);
    else console.log("Server is running on port : ",port);
})