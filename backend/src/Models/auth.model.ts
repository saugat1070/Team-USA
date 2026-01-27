
import mongoose from "mongoose";
export interface IUser extends mongoose.Document{
    _id : mongoose.Types.ObjectId;
    fullName : {
        firstName : string;
        lastName : string;
    };
    email : string;
    password : string;
    socketId ?: string | null;
    createdAt ?: Date;
    updatedAt ?: Date;
}

const userSchema : mongoose.Schema = new mongoose.Schema<IUser>({
    fullName : {
        firstName : String,
        lastName : String,
    },
    email : {
        type : String,
        required : true,
        unique : true
    },
    password : {
        type : String,
        required : true,
        minlength : [6,"Password must be at least 6 characters"]
    },
    socketId : {
        type : String,
        default : null
    }
},{
    timestamps : true
});

const UserModel = mongoose.model<IUser>("user",userSchema);
export default UserModel;
