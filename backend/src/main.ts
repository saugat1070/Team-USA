import express from "express";
import connectDb from "./Config/dbConnect.js";
import cors from "cors";
import logger from "./utils/logger.js";
import userRoutes from "./Routes/auth.routes.js";
import mapRoutes from "./Routes/map.routes.js";
import { leaderRoute } from "./Routes/userWalk.routes.js";
import blogRoutes from "./Routes/blog.routes.js";

export const app = express();
app.use(express.json());
app.use(logger);
app.use(cors({
    origin : "*",
    credentials : true
}));
app.use("/uploads", express.static("uploads"));

app.use("/api/v1",userRoutes);
app.use("/api/v1",mapRoutes);
app.use("/api/v1",leaderRoute);
app.use("/api/v1",blogRoutes);


connectDb(); // Database Connection