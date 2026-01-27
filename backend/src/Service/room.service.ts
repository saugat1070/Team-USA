import mongoose from "mongoose";
import Room from "../Models/room.model.js";
import RoomMembership from "../Models/RoomMemberShip.model.js";

export type ObjectIdLike = string | mongoose.Types.ObjectId;

const toObjectId = (id: ObjectIdLike) =>
  typeof id === "string" ? new mongoose.Types.ObjectId(id) : id;

async function findOrCreateActiveRoomForDistrict(districtId: ObjectIdLike) {
  const dId = toObjectId(districtId);

  let room = await Room.findOne({ districtId: dId, isActive: true });
  if (!room) {
    room = await Room.create({
      districtId: dId,
      isActive: true,
      participants: [],
      participantsCount: 0,
    });
  }
  return room;
}

async function addUserToRoom(userId: ObjectIdLike, roomId: ObjectIdLike) {
  const uId = toObjectId(userId);
  const rId = toObjectId(roomId);

  // Upsert membership and activate
  await RoomMembership.findOneAndUpdate(
    { roomId: rId, userId: uId },
    {
      $set: { status: "ACTIVE", leftAt: null },
      $setOnInsert: { joinedAt: new Date() },
    },
    { upsert: true, new: true }
  );

  // Ensure user is listed in room participants
  await Room.updateOne({ _id: rId }, { $addToSet: { participants: uId }, $set: { isActive: true } });

  // Recalculate participantsCount from active memberships
  const activeCount = await RoomMembership.countDocuments({ roomId: rId, status: "ACTIVE" });
  await Room.updateOne({ _id: rId }, { $set: { participantsCount: activeCount } });

  return { participantsCount: activeCount };
}

async function leaveUserFromRoom(userId: ObjectIdLike, roomId: ObjectIdLike) {
  const uId = toObjectId(userId);
  const rId = toObjectId(roomId);

  await RoomMembership.updateOne(
    { roomId: rId, userId: uId, status: "ACTIVE" },
    { $set: { status: "LEFT", leftAt: new Date() } }
  );

  // Optionally remove from participants list
  await Room.updateOne({ _id: rId }, { $pull: { participants: uId } });

  const activeCount = await RoomMembership.countDocuments({ roomId: rId, status: "ACTIVE" });
  await Room.updateOne({ _id: rId }, { $set: { participantsCount: activeCount } });

  return { participantsCount: activeCount };
}

const RoomService = {
  findOrCreateActiveRoomForDistrict,
  addUserToRoom,
  leaveUserFromRoom,
};

export default RoomService;
