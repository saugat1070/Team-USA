# Paila Backend API

Welcome to the Paila backend. This service powers realtime walking/running, district rooms, territory calculation, leaderboards, blogs, rewards, and streaks.

## Table of Contents
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [HTTP API](#http-api)
- [Socket Events](#socket-events)
- [Contributing](#contributing)
- [License](#license)

## Project Structure
```
backend/
├── package.json
├── README.md
├── src/
│   ├── Config/
│   ├── Controller/
│   ├── DTO/
│   ├── Models/
│   ├── Routes/
│   ├── Service/
│   ├── middleware/
│   ├── socket/
│   ├── utils/
│   ├── main.ts
│   └── server.ts
└── uploads/
```

## Installation
1. Install dependencies:
   ```bash
   npm install
   ```

2. Configure environment variables in your `.env` (example):
   ```env
   PORT=3000
   MONGO_URI=your_mongodb_connection
   JWT_SECRET=your_secret
   REDIS_URL=your_redis_connection
   ```

## Running the Application
```bash
npm run dev
```
Server runs on http://localhost:3000

## HTTP API
Base path: `/api/v1`

### Auth
- **POST** `/register`
  - Body: `{ firstName, lastName, email, password }`
- **POST** `/login`
  - Body: `{ email, password }`
- **GET** `/profile`
  - Auth: `Authorization: Bearer <token>`

### Map / District
- **POST** `/seed-districts`
  - Seeds district data from GeoJSON.
- **POST** `/get-district`
  - Auth: `Authorization: Bearer <token>`
  - Body: `{ latitude, longitude }`
  - Response: `{ success, district, room }`

### Leaderboard
- **GET** `/leaderboard/:roomId`

### Blog / Routes
- **POST** `/blogs`
  - Auth: `Authorization: Bearer <token>`
  - multipart field: `images`
- **GET** `/blogs`
- **GET** `/blogs/:id`
- **PUT** `/blogs/:id`
  - Auth: `Authorization: Bearer <token>`
  - multipart field: `images`
- **DELETE** `/blogs/:id`
  - Auth: `Authorization: Bearer <token>`

## Socket Events

### Client → Server
- `join-room` — `{ roomId }`
- `walk:start` — `{ latitude, longitude }`
- `walk:end` — `{ activityType?: "walking" | "running" }`
- `leave-room` — no payload

### Server → Client
- `user-joined`
- `location-update`
- `walk:result`
- `user-left`
- `user-disconnected`
- `error`

## Contributing
1. Fork the repo
2. Create a branch (`git checkout -b feature-branch`)
3. Commit your changes
4. Push the branch and open a PR

## License
MIT
