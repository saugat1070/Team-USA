
import { Request,Response } from "express";
import { IRequest } from "./auth.controller.js";
import UserLocation from "../Models/userLocation.model.js";
import mongoose from "mongoose";


export const getLeaderboard = async (req: IRequest, res: Response) => {
    try {
        const roomId = (req.user?.roomId || req.params.roomId) as string | undefined;
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
                    totalDistanceM: { $sum: { $ifNull: ["$metrics.distanceM", 0] } },
                    totalDurationSec: { $sum: { $ifNull: ["$durationSec", 0] } },
                    totalAreaM2: { $sum: { $ifNull: ["$areaM2", 0] } },
                    maxSpeedMps: { $max: { $ifNull: ["$metrics.maxSpeedMps", 0] } },
                    sessions: { $sum: 1 },
                },
            },
            {
                $addFields: {
                    avgSpeedMps: {
                        $cond: [
                            { $gt: ["$totalDurationSec", 0] },
                            { $divide: ["$totalDistanceM", "$totalDurationSec"] },
                            0,
                        ],
                    },
                    paceSecPerKm: {
                        $cond: [
                            { $gt: ["$totalDistanceM", 0] },
                            { $divide: ["$totalDurationSec", { $divide: ["$totalDistanceM", 1000] }] },
                            0,
                        ],
                    },
                },
            },
            {
                $addFields: {
                    score: {
                        $add: [
                            "$totalDistanceM",
                            { $divide: ["$totalAreaM2", 10] },
                        ],
                    },
                },
            },
            { $sort: { score: -1, totalDistanceM: -1, totalAreaM2: -1 } },
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
                    score: 1,
                    totalDistanceM: 1,
                    totalDurationSec: 1,
                    totalAreaM2: 1,
                    avgSpeedMps: 1,
                    maxSpeedMps: 1,
                    paceSecPerKm: 1,
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
