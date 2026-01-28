import mongoose from "mongoose";

const roomMembershipSchema = new mongoose.Schema(
  {
    roomId: { type: mongoose.Schema.Types.ObjectId, ref: "Room", required: true, index: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true, index: true },

    joinedAt: { type: Date, default: Date.now },
    leftAt: { type: Date, default: null },

    status: { type: String, enum: ["ACTIVE", "LEFT"], default: "ACTIVE" },
  },
  { timestamps: true }
);



const RoomMembership = mongoose.model("RoomMembership", roomMembershipSchema);
export default RoomMembership;
