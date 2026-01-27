import express from "express";
import connectDb from "./Config/dbConnect.js";
import cors from "cors";
import userRoutes from "./Routes/auth.route.js";
import logger from "./utils/logger.js";

export const app = express();
app.use(express.json());
app.use(logger);
app.use(cors({
    origin : "*",
    credentials : true
}));

app.use("/api/v1",userRoutes);


connectDb(); // Database Connection