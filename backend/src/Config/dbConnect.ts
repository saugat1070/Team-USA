import mongoose from "mongoose";
import Env from "./envConfig.js";

const connectDb = async ()=>{
    await mongoose.connect(Env.dbUrl).then(()=>{
        console.log(`Database Connect at host:${mongoose.connection.host}`)
    })
}

export default connectDb;