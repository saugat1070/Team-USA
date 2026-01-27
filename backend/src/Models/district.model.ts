import mongoose from "mongoose";

const geometrySchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: ["Polygon", "MultiPolygon"],
      required: true,
    },
    coordinates: {
      type: [[[Number]]],
      required: true,
    },
  },
  { _id: false }
);

const DistrictSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  geometry: { type: geometrySchema, required: true },
});

DistrictSchema.index({ geometry: "2dsphere" });
const DistrictModel = mongoose.model("District", DistrictSchema);
export default DistrictModel;

