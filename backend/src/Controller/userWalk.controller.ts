
import { Request,Response } from "express";
import { IRequest } from "./auth.controller.js";
import UserLocation from "../Models/userLocation.model.js";
import mongoose from "mongoose";


export const getLeaderboard = async (req: IRequest, res: Response) => {
    try {
        const roomId = (req.user?.roomId || req.query.roomId) as string | undefined;
        if (!roomId) {
            return res.status(400).json({ message: "roomId is required" });
        }

        const roomObjectId = new mongoose.Types.ObjectId(roomId);

        const leaderboard = await UserLocation.aggregate([
            {
                $match: {
                    roomId: roomObjectId,
                    status: "completed",
                },
            },
            {
                $group: {
                    _id: "$userId",
                    totalDistanceM: { $sum: "$metrics.distanceM" },
                    totalDurationSec: { $sum: "$durationSec" },
                    sessions: { $sum: 1 },
                },
            },
            { $sort: { totalDistanceM: -1 } },
            {
                $lookup: {
                    from: "users",
                    localField: "_id",
                    foreignField: "_id",
                    as: "user",
                },
            },
            { $unwind: { path: "$user", preserveNullAndEmptyArrays: true } },
            {
                $project: {
                    _id: 0,
                    userId: "$_id",
                    totalDistanceM: 1,
                    totalDurationSec: 1,
                    sessions: 1,
                    user: {
                        _id: "$user._id",
                        fullName: "$user.fullName",
                        email: "$user.email",
                    },
                },
            },
        ]);

        return res.status(200).json({ roomId, leaderboard });
    } catch (error) {
        console.error("Error in getLeaderboard:", error);
        return res.status(500).json({ message: "Failed to fetch leaderboard" });
    }
};
