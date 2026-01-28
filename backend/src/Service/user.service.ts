
import UserModel from "../Models/auth.model.js";
import jwt from "jsonwebtoken";
import Env from "../Config/envConfig.js";
import bcrypt from "bcrypt";
export const createUser = async(firstName:string,lastName:string,email:string,password:string)=>{
    const user = await UserModel.create({
        fullName : {
            firstName:firstName,
            lastName:lastName
        },
        email : email,
        password : password
    }
    );
    return user;
}

export const UserfindById = async (_id:string)=>{
    if(!_id){
        throw new Error("Id must be provided");
    }
    const user = await UserModel.findById(_id).select("-password");
    return user;
}

export const UserfindByEmail = async (email:string)=>{
    if(!email){
        throw new Error("Id must be provided");
    }
    const user = await UserModel.findOne({email:email});
    return user;
}

export const generateAuthToken = function (id:any) {
    const token = jwt.sign({ _id:id  }, Env.jwtSecret, { expiresIn: '24h' });
    return token;
}

export const hashedPassword = function(password:string){
    return  bcrypt.hashSync(password,10)
}

export const comparePassword =  function(password:string,hashedPassword:string){
    return  bcrypt.compareSync(password,hashedPassword);
}
