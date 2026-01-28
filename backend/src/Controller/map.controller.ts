import { Request, Response } from "express";
import DistrictModel from "../Models/district.model.js";
import districtGeoJson from "../disrict_all_cord.json" with { type: "json" };
import MapService from "../Service/map.service.js";
import { IRequest } from "./auth.controller.js";
import RoomService from "../Service/room.service.js";

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
      return res
        .status(404)
        .json({ message: "No district found for the given coordinates" });
    }

    const room = await RoomService.findOrCreateActiveRoomForDistrict(district._id);

    return res.status(200).json({
      success: true,
      district,
      room: {
        roomId: room._id,
        districtId: room.districtId,
        participantsCount: room.participantsCount ?? 0,
        message: "Room ready. Join via socket join-room with roomId.",
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



