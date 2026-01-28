import dotenv from "dotenv";
dotenv.config();

import { Redis } from "ioredis";

const retryStrategy = (times: number) => Math.min(times * 50, 2000);

const redis = process.env.REDIS_URL
  ? new Redis(process.env.REDIS_URL, {
      maxRetriesPerRequest: null,
      enableReadyCheck: true,
      retryStrategy,
    })
  : new Redis({
      host: process.env.REDIS_HOST ?? "127.0.0.1",
      port: Number(process.env.REDIS_PORT ?? 6379),
      username: process.env.REDIS_USERNAME ?? "default",
      password: process.env.REDIS_PASSWORD ?? "",
      maxRetriesPerRequest: null,
      enableReadyCheck: true,
      retryStrategy,
    });

redis.on("connect", () => {
  console.log("Redis connected");
});

redis.on("ready", () => {
  console.log("Redis ready");
});

redis.on("error", (err:any) => {
  console.error("Redis error", err);
});

redis.on("close", () => {
  console.warn("Redis connection closed");
});

export default redis;
