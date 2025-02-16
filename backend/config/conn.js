import mongoose from 'mongoose';
import '../env.js'

const mode = process.env.MODE;
let uri = process.env.DB_URI_LOCAL;

if(mode == 'production'){
    uri = process.env.DB_URI_REMOTE
}

const connect = async()=>{
    mongoose.connect(uri).then(()=>{
        console.log("Successfully connected to %s mongodb server",mode);
    }).catch((e)=>{
        console.log("Error while connection to mongodb : ",e);
    })
}

export{connect};