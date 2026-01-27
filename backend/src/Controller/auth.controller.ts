import {validationResult} from "express-validator";
import { Request,Response } from "express";

import { RegisterDto } from "../DTO/user.dto.js";
import { comparePassword, createUser, generateAuthToken, hashedPassword, UserfindByEmail } from "../Service/user.service.js";
import Env from "../Config/envConfig.js";

export interface IRequest extends Request{
    user ?: any
}

export const registerUser = async(req:Request,res:Response)=>{
    const erros = validationResult(req);
    if(!erros.isEmpty()){
        return res.status(400).json({
            error : erros.array()
        });
    }
    const {firstName,lastName,email,password} : RegisterDto = req.body;
    const isUserExist = await UserfindByEmail(email);
    if(isUserExist){
        return res.status(200).json({
            message :"User with this email is already created"
        });
    }
    const hashedPass = hashedPassword(password);
    const user = await createUser(firstName,lastName,email,hashedPass);
    if(!user){
        return res.status(403).json({
            message:"Request failed at Database creation"
        });
    }
    const token = generateAuthToken(user._id);
    return res.status(200).json({
        message : "User Register successfully",
        token : token,
        user : user
    })
}

export const loginUser = async function(req:Request,res:Response){
    const error = validationResult(req);
    if(!error.isEmpty()){
        return res.status(400).json({error:error.array()});
    }
    const {email,password} = req.body;
    if(!email || !password){
        return res.status(400).json({message:"email and password must be provided"});
    }
    const user = await UserfindByEmail(email);
    if(!user){
        return res.status(404).json({message:"user with this email is not found"});
    }
    const isPasswordTrue = comparePassword(password,user?.password);
    if(!isPasswordTrue){
        res.status(401).json({message:"Incorrect password"});
    }
    const token = generateAuthToken(user._id)
    res.cookie("jwt",token,{
        maxAge : 24*60*60*1000,
        secure : true,
        httpOnly : Env.nodeEnv === "development" ? true : false
    });
    return res.status(200).json({message:"User login successfully",token:token})
}

export const profile = (req:IRequest,res:Response)=>{
    if(!req.user){
        return res.status(401).json({
            message:"unauthorized user"
        });
    }
    return res.status(200).json({
        message:"profile fetched successfully",
        data : req?.user
    })
}

export const logoutUser = (req:IRequest,res:Response)=>{
    res.clearCookie("jwt");
    return res.status(200).json({
        message:"User logged out successfully"
    });
}