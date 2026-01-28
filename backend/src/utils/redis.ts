import { Redis } from "ioredis";

const redisClient = new Redis({
  host: process.env.REDIS_HOST || "localhost",
  port: parseInt(process.env.REDIS_PORT || "6379"),
});

// Connection event listeners
redisClient.on("connect", () => {
  console.log(" Redis client connected");
});

redisClient.on("error", (error) => {
  console.error(" Redis client error:", error);
});

redisClient.on("reconnecting", () => {
  console.log("Redis client reconnecting...");
});

export default redisClient;