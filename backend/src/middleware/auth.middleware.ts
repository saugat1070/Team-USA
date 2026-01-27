import { NextFunction,Request,Response } from "express";
import jwt from "jsonwebtoken";
import Env from "../Config/envConfig.js";
import { IRequest } from "../Controller/auth.controller.js";
import { UserfindById } from "../Service/user.service.js";
const TakenFromCookie = function (req:IRequest){
    const jwtToken = req.cookies?.jwt;
    return jwtToken || null;
}
const TakenFromHeader = function (req:IRequest){
    const tokenwithBearer = req.headers.authorization;
    const jwtToken = tokenwithBearer?.startsWith("Bearer ") ? tokenwithBearer.split(" ")[1] : tokenwithBearer;
    return jwtToken || null
}

export const validateToken = async (req:IRequest,res:Response,next:NextFunction)=>{
    const token = TakenFromCookie(req) || TakenFromHeader(req);
    if(!token){
        return res.status(401).json({message:"Token is not found"});
    }
    try {
        const userPayload : any = jwt.verify(token,Env.jwtSecret);
        const user = await UserfindById(userPayload?._id);
        req.user = user;
        next();
    } catch (error) {
        return res.status(401).json({message:"Invalid token"});
    }
}