import mongoose from "mongoose";

const strikeMaintenanceSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },
    roomId: { type: mongoose.Schema.Types.ObjectId, ref: "Room", index: true },

    reason: { type: String, required: true, trim: true },
    points: { type: Number, default: 1, min: 0 },

    status: { type: String, enum: ["OPEN", "RESOLVED", "DISMISSED"], default: "OPEN" },
    issuedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },

    resolvedAt: { type: Date, default: null },
    maxPoint : { type: Number, default: 1,min:0 },
  },
  { timestamps: true }
);

strikeMaintenanceSchema.index({ userId: 1, createdAt: -1 });
strikeMaintenanceSchema.index({ roomId: 1, createdAt: -1 });

const StrikeMaintenanceModel = mongoose.model("StrikeMaintenance", strikeMaintenanceSchema);
export default StrikeMaintenanceModel;