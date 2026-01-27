# HackNova Backend

## Overview
Express + MongoDB backend with Socket.IO for realtime features. Base API path is `/api/v1`.

## HTTP API Routes

### Auth
- **POST** `/api/v1/register`
  - Body: `{ firstName, lastName, email, password }`
  - Response: `{ message, token, user }`

- **POST** `/api/v1/login`
  - Body: `{ email, password }`
  - Response: `{ message, token }`

- **GET** `/api/v1/profile`
  - Auth: `Authorization: Bearer <token>`
  - Response: `{ message, data }`

### Map
- **POST** `/api/v1/seed-districts`
  - Seeds district data from GeoJSON.
  - Response: `{ success, message }`

- **POST** `/api/v1/get-district`
  - Auth: `Authorization: Bearer <token>`
  - Body: `{ latitude, longitude }`
  - Response: `{ success, district, room }`
  - Behavior: Finds district + creates/joins room for the user.

## Socket Events

### Client → Server
- `join-room`
  - Payload: `{ userId, roomId }`
  - Joins room and activates membership.

- `walk:start`
  - Payload: `{ roomId, userId, latitude, longitude }`
  - Pushes point to Redis list and broadcasts location.

- `walk:end`
  - Payload: `{ roomId, userId, activityType?: "walking" | "running" }`
  - Reads points from Redis, stores GeoJSON LineString to MongoDB, returns `walk:result`.

- `leave-room`
  - Payload: none
  - Leaves room and deactivates membership.

### Server → Client
- `user-joined`
  - Payload: `{ userId, message, participantsCount, timestamp }`

- `location-update`
  - Payload: `{ userId, latitude, longitude, timestamp }`

- `walk:result`
  - Payload on success: `{ ok: true, locationId, pointsCount, status }`
  - Payload on failure: `{ ok: false, message }`

- `user-left`
  - Payload: `{ userId, message, participantsCount, timestamp }`

- `user-disconnected`
  - Payload: `{ userId, message, participantsCount, timestamp }`

- `error`
  - Payload: `{ message }`

## Development

```bash
cd backend
npm install
npm run dev
```
