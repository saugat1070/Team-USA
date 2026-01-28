import { Router } from "express";
import { validateToken } from "../middleware/auth.middleware.js";
import { getLeaderboard } from "../Controller/userWalk.controller.js";


export const leaderRoute = Router();

leaderRoute.route("/leaderboard/:roomId").get(validateToken, getLeaderboard); // http://localhost:3000/api/v1/leaderboard