import jwt from "jsonwebtoken";
import Env from "../Config/envConfig.js";
import UserModel from "../Models/auth.model.js";
import { Socket } from "socket.io";

interface ISocket extends Socket{
    _id? : string;
    user? : any;
    handshake : any
}

export const socketAuthMiddleware = async(socket: ISocket, next: (err?: Error) => void)=>{
try {
        const authHeader = socket.handshake.headers.authorization as string ;
        const cookieHeader = socket.handshake.headers.cookie;

        const bearerToken = authHeader?.startsWith("Bearer ")
            ? authHeader.replace("Bearer ", "")
            : undefined;

        const cookieToken = cookieHeader
            ?.split("; ")
            .find((row: any) => row.startsWith("jwt="))
            ?.split("=")[1];

        const handshakeToken = socket.handshake.auth?.token as string | undefined;

        const token = bearerToken || cookieToken || handshakeToken;

    if(!token){
        console.log("Socket connection rejected:No token provided");
        return next(new Error("Unauthorized - No token provided"));

    };

    //verify token
    const decoded : any= jwt.verify(token,Env.jwtSecret);
    if(!decoded) return next(new Error("Invalid token"));
    const user = await UserModel.findOne({_id:decoded?._id}).select("-password");
    if(!user) return next(new Error("user not found"));

    socket._id = decoded._id;
    socket.user = user;
    next();
} catch (error:any) {
    next(new Error("Error at Socket middleware:"+error?.message));
}


}