import mongoose from "mongoose";

const GeoLineStringSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: ["LineString"],
      default: "LineString",
    },
    coordinates: {
      type: [[Number]], // [ [lng, lat], ... ]
      default: [],
    },
  },
  { _id: false }
);

const GeoPolygonSchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: ["Polygon"],
      default: "Polygon",
    },
    coordinates: {
      type: [[[Number]]], // [ [ [lng, lat], ... ] ]
      default: [],
    },
  },
  { _id: false }
);

const UserLocationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    roomId: { type: mongoose.Schema.Types.ObjectId, ref: "Room", index: true },

    activityType: { type: String, enum: ["walking", "running"], required: true },

    startedAt: { type: Date, required: true },
    endedAt: { type: Date },
    durationSec: { type: Number, default: 0 },

    track: { type: GeoLineStringSchema, default: () => ({ type: "LineString", coordinates: [] }) },

    polygon: { type: GeoPolygonSchema, default: () => ({ type: "Polygon", coordinates: [] }) },
    areaM2: { type: Number, default: 0 },

    metrics: {
      distanceM: { type: Number, default: 0 },
      avgSpeedMps: { type: Number, default: 0 },
      maxSpeedMps: { type: Number, default: 0 },
      totalAscentM: { type: Number, default: 0 },
      totalDescentM: { type: Number, default: 0 },
    },

    rawMeta: {
      pointsCount: { type: Number, default: 0 },
      avgAccuracyM: { type: Number, default: 0 },
    },

    status: { type: String, enum: ["active", "completed", "invalid"], default: "active" },
  },
  { timestamps: true }
);

UserLocationSchema.index({ userId: 1, createdAt: -1 });
UserLocationSchema.index({ roomId: 1, createdAt: -1 });
UserLocationSchema.index({ track: "2dsphere" });
UserLocationSchema.index({ polygon: "2dsphere" });

const UserLocation = mongoose.model("UserLocation", UserLocationSchema);
export default UserLocation;
