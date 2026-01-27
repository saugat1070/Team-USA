import { Router } from "express";
import { registerUser } from "../Controller/auth.controller.js";
import { loginUser } from "../Controller/auth.controller.js";
import AsyncWrapper from "../utils/errorHanler.js";
import { profile } from "../Controller/auth.controller.js";
import { validateToken } from "../middleware/auth.middleware.js";

const userRoutes = Router();


userRoutes.route("/register").post(AsyncWrapper(registerUser)); // http://localhost:3000/api/v1/register
userRoutes.route("/login").post(AsyncWrapper(loginUser));
userRoutes.route("/profile").get(validateToken,profile);


export default userRoutes;
