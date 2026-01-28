import { app } from "./main.js";
import Env from "./Config/envConfig.js";
import { createServer } from "http";
import { Server } from "socket.io";
import setupSocketHandlers from "./socket/socketHandlers.js";
import { socketAuthMiddleware } from "./middleware/socket.middleware.js";

function ServerRunner(portNumber: number = 3000) {
    const httpServer = createServer(app);
    const io = new Server(httpServer, {
        cors: {
            origin: "*",
            credentials: true
        }
    });

    // Socket.IO middleware for authentication
    io.use(socketAuthMiddleware);

    // Setup socket handlers
    setupSocketHandlers(io);

    httpServer.listen(portNumber,"0.0.0.0",()=>{
        console.log("Server Running at:", portNumber)
    })
};

ServerRunner(Env.portNumber)
