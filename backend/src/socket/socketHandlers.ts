import { Server, Socket } from "socket.io";
import Room from "../Models/room.model.js";
import RoomService from "../Service/room.service.js";
import redisClient from "../utils/redis.js";
import UserLocation from "../Models/userLocation.model.js";

interface CustomSocket extends Socket {
  userId?: string;
  roomId?: string;
  _id?: string;
  user?: any;
}

const KEY = (roomId: string, userId: string) =>
  `walk:locations:${roomId}:${userId}`;

const setupSocketHandlers = (io: Server) => {
  io.on("connection", (socket: CustomSocket) => {
    console.log("New client connected:", socket.id);
    console.log(`User: ${socket.user?.fullName?.firstName} connected with ID: ${socket._id}`);

    // User joins a room
    socket.on("join-room", async () => {
      try {
        console.log("join-room event received");
        const userId = socket._id || socket.user?._id?.toString();
        const roomId = socket.user?.roomId?.toString();
        if (!userId || !roomId) {
          socket.emit("error", { message: "User or room not set" });
          return;
        }
        socket.userId = userId;
        socket.roomId = roomId;

        if (socket.rooms.has(roomId)) {
          console.log(`User ${userId} already in room ${roomId}`);
          socket.emit("joined-room", { roomId });
          return;
        }

        // Join the socket to the room
        socket.join(roomId);

        // Centralized membership update (upsert + count sync)
        const { participantsCount } = await RoomService.addUserToRoom(
          userId,
          roomId,
        );
        // Get room details (optional populate if needed)
        const room = await Room.findById(roomId);

        // Notify room members
        io.to(roomId).emit("user-joined", {
          userId,
          message: `User ${userId} joined the room`,
          participantsCount: participantsCount ?? room?.participantsCount ?? 1,
          timestamp: new Date(),
        });

        console.log(`User ${userId} joined room ${roomId}`);
      } catch (error) {
        console.error("Error in join-room:", error);
        socket.emit("error", { message: "Failed to join room" });
      }
    });

    // User sends location update
    socket.on(
      "walk:start",
      async (data: {
        latitude: number;
        longitude: number;
      }) => {
        try {
          const { latitude, longitude } = data;
          console.log(`Walk started by ${socket.user?.fullName?.firstName} at:${latitude},${longitude}`);
          if (!socket.userId || !socket.roomId) {
            socket.emit("error", { message: "User or room not set" });
            return;
          }
          await redisClient.rpush(
            KEY(socket.roomId, socket.userId),
            JSON.stringify({ lng: longitude, lat: latitude, ts: Date.now() }),
          );
          // Broadcast location to all users in the room
          io.to(socket.roomId).emit("location-update", {
            userId: socket.userId,
            latitude,
            longitude,
            timestamp: new Date(),
          });
          console.log(`Location update from ${socket.userId}:`, {
            latitude,
            longitude,
          });
        } catch (error) {
          console.error("Error in location-update:", error);
          socket.emit("error", { message: "Failed to update location" });
        }
      },
    );
    // User leaves a room
    socket.on("leave-room", async () => {
      try {
        if (socket.userId && socket.roomId) {
          // Centralized leave logic
          const { participantsCount } = await RoomService.leaveUserFromRoom(
            socket.userId,
            socket.roomId,
          );

          // Notify room members
          io.to(socket.roomId).emit("user-left", {
            userId: socket.userId,
            message: `User ${socket.userId} left the room`,
            participantsCount,
            timestamp: new Date(),
          });

          socket.leave(socket.roomId);
          console.log(`User ${socket.userId} left room ${socket.roomId}`);
        }
      } catch (error) {
        console.error("Error in leave-room:", error);
        socket.emit("error", { message: "Failed to leave room" });
      }
    });

    socket.on(
      "walk:end",
      async (data: { activityType?: "walking" | "running" }) => {
      try {
        if (!socket.userId || !socket.roomId) {
          socket.emit("walk:result", { ok: false, message: "User or room not set" });
          return;
        }

        const { activityType } = data;
        const rawStrings = await redisClient.lrange(KEY(socket.roomId, socket.userId), 0, -1);
        await redisClient.del(KEY(socket.roomId, socket.userId));

        const rawPoints = rawStrings.map((s) => JSON.parse(s));
        if (rawPoints.length === 0) {
          socket.emit("walk:result", {
            ok: false,
            message: "No points found",
          });
          return;
        }

        const coordinates = rawPoints.map((p) => [p.lng, p.lat]);
        const startedAt = new Date(rawPoints[0].ts);
        const endedAt = new Date(rawPoints[rawPoints.length - 1].ts);
        const durationSec = Math.max(0, Math.floor((endedAt.getTime() - startedAt.getTime()) / 1000));

        const status = rawPoints.length < 2 ? "invalid" : "completed";

        const locationDoc = await UserLocation.create({
          userId: socket.userId,
          roomId: socket.roomId,
          activityType: activityType ?? "walking",
          startedAt,
          endedAt,
          durationSec,
          track: { type: "LineString", coordinates },
          rawMeta: {
            pointsCount: rawPoints.length,
            avgAccuracyM: 0,
          },
          status,
        });

        socket.emit("walk:result", {
          ok: true,
          locationId: locationDoc._id,
          pointsCount: rawPoints.length,
          status,
        });
      } catch (error) {
        console.error("Error in walk:end:", error);
        socket.emit("walk:result", { ok: false, message: "Failed to save walk" });
      }
    });

    // Disconnect
    socket.on("disconnect", async () => {
      try {
        if (socket.userId && socket.roomId) {
          const { participantsCount } = await RoomService.leaveUserFromRoom(
            socket.userId,
            socket.roomId,
          );

          io.to(socket.roomId).emit("user-disconnected", {
            userId: socket.userId,
            message: `User ${socket.userId} disconnected`,
            participantsCount,
            timestamp: new Date(),
          });
        }

        console.log("Client disconnected:", socket.id);
      } catch (error) {
        console.error("Error in disconnect:", error);
      }
    });

    // Handle errors
    socket.on("error", (error) => {
      console.error("Socket error:", error);
    });
  });
};

export default setupSocketHandlers;
