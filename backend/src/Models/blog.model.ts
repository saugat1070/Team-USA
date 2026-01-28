import mongoose from "mongoose";

const blogSchema = new mongoose.Schema(
	{
		name: { type: String, required: true, trim: true },
		distance: { type: String, default: "", trim: true },
		difficulty: { type: String, default: "", trim: true },
		owner: { type: String, default: "", trim: true },
		description: { type: String, required: true },
		estimatedTime: { type: String, default: "", trim: true },
		elevation: { type: String, default: "", trim: true },
		tags: [{ type: String, trim: true, lowercase: true }],
		images: [{ type: String, trim: true }],
		highlights: [{ type: String, trim: true }],
		terrain: { type: String, default: "", trim: true },
		bestTime: { type: String, default: "", trim: true },
		createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
	},
	{ timestamps: true }
);

const Blog = mongoose.model("Blog", blogSchema);
export default Blog;
