import { Router } from "express";
import { validateToken } from "../middleware/auth.middleware.js";
import { getLeaderboard } from "../Controller/userWalk.controller.js";
import { getUserTeritory } from "../Controller/userWalk.controller.js";
import { strikeMaintaince } from "../Controller/userWalk.controller.js";
import AsyncWrapper from "../utils/errorHanler.js";

export const leaderRoute = Router();

leaderRoute.route("/leaderboard/:roomId").get(validateToken, AsyncWrapper(getLeaderboard)); // http://localhost:3000/api/v1/leaderboard
leaderRoute.route("/user/teritory").get(validateToken, AsyncWrapper(getUserTeritory)); // http://localhost:3000/api/v1/user/teritory
leaderRoute.route("/user/strike").get(validateToken, AsyncWrapper(strikeMaintaince));