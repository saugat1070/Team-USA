import { Router } from "express";
import { validateToken } from "../middleware/auth.middleware.js";
import { getUserCooridnate } from "../Controller/map.controller.js";
import AsyncWrapper from "../utils/errorHanler.js";


const mapRoutes = Router();

mapRoutes.route("/get-district").post(validateToken, AsyncWrapper(getUserCooridnate)); // http://localhost:3000/api/v1/get-district
export default mapRoutes;