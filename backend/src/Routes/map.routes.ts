import { Router } from "express";
import { validateToken } from "../middleware/auth.middleware.js";
import { getUserCooridnate, seedingDistricts } from "../Controller/map.controller.js";


const mapRoutes = Router();

mapRoutes.route("/seed-districts").post(seedingDistricts); // http://localhost:3000/api/v1/seed-districts
mapRoutes.route("/get-district").post(validateToken, getUserCooridnate); // http://localhost:3000/api/v1/get-district
export default mapRoutes;