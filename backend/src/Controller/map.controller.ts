import { Request, Response } from "express";
import DistrictModel from "../Models/district.model.js";
import districtGeoJson from "../disrict_all_cord.json" with { type: "json" };
import MapService from "../Service/map.service.js";
import { IRequest } from "./auth.controller.js";
import UserModel from "../Models/auth.model.js";
import mongoose from "mongoose";
import Room from "../Models/room.model.js";
import RoomMembership from "../Models/RoomMemberShip.model.js";

export const seedingDistricts = async (req: Request, res: Response) => {
  try {
    const filterData = (districtGeoJson as any).features.map(
      (feature: any) => ({
        name: feature.properties.adm2_name,
        geometry: feature.geometry,
      }),
    );

    // Insert data into database
    const result = await DistrictModel.insertMany(filterData);

    console.log("Districts seeded:", result.length);
    return res.status(201).json({
      success: true,
      message: `${result.length} districts added`,
    });
  } catch (error) {
    console.error("Seeding error:", error);
    return res.status(500).json({
      success: false,
      message: "Error seeding districts",
      error: error instanceof Error ? error.message : "Unknown error",
    });
  }
};

export const getUserCooridnate = async (req: IRequest, res: Response) => {
  try {
    const { latitude, longitude } = req.body;
    if (!latitude || !longitude) {
      return res
        .status(400)
        .json({ message: "Latitude and Longitude are required" });
    }

    const district = await MapService.findDistrictByCoordinates(latitude, longitude);
    if (!district) {
      return res.status(404).json({ message: "No district found for the given coordinates" });
    }

    // Get the authenticated user
    const userId = req.user?._id;
    if (!userId) {
      return res.status(401).json({ message: "User not authenticated" });
    }

    // Find or create a room for this district
    let room = await Room.findOne({ districtId: district._id, isActive: true });
    
    if (!room) {
      // Create a new room for this district
      room = await Room.create({
        districtId: district._id,
        isActive: true,
        participantsCount: 1,
        participants: [userId],
      });
    }

    // Check if user is already a member of this room
    const existingMembership = await RoomMembership.findOne({
      roomId: room._id,
      userId: userId,
      status: "ACTIVE",
    });

    if (!existingMembership) {
      // Add user to room membership
      await RoomMembership.create({
        roomId: room._id,
        userId: userId,
        status: "ACTIVE",
      });

      // Update room's participants if not already present
      if (!room.participants.includes(userId)) {
        room.participants.push(userId);
        room.participantsCount = (room.participantsCount || 0) + 1;
        await room.save();
      }
    }

    return res.status(200).json({
      success: true,
      district,
      room: {
        roomId: room._id,
        districtId: room.districtId,
        participantsCount: room.participantsCount,
        message: "User successfully entered the room",
      },
    });
  } catch (error) {
    console.error("Error in getUserCooridnate:", error);
    return res.status(500).json({
      success: false,
      message: "Error processing coordinates",
      error: error instanceof Error ? error.message : "Unknown error",
    });
  }
};



