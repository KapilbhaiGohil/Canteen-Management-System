import express from 'express'; 
import './env.js'

const app = express();
const port = process.env.PORT

app.listen(port,(e)=>{
    if(e)console.log(e);
    else console.log("Server is running on port : ",port);
})