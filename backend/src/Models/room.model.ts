import mongoose from "mongoose";

const roomSchema = new mongoose.Schema({
  districtId : {
    type : mongoose.Schema.Types.ObjectId,
    ref : "District",
    required : true
  },
  rules : {
    requiredInsideDistrict : {
      type : Boolean,
      default : true
    },
    minLoopArea : Number,
    minDistance : Number,

  },
  season : {
    weekStart : Date,
    weekEnd : Date
  },
  participants : [
    {
      type : mongoose.Schema.Types.ObjectId,
      ref : "User"
    }
  ],
  participantsCount : Number,
  isActive : Boolean
},{
  timestamps : true
});

const Room = mongoose.model("Room",roomSchema);
export default Room;