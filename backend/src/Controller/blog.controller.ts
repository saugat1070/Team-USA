import { Request, Response } from "express";
import { IRequest } from "./auth.controller.js";
import Blog from "../Models/blog.model.js";

const parseStringArray = (input: unknown): string[] => {
	if (!input) return [];
	if (Array.isArray(input)) return input.map((v) => String(v).trim()).filter(Boolean);
	if (typeof input === "string") {
		try {
			const parsed = JSON.parse(input);
			if (Array.isArray(parsed)) {
				return parsed.map((v) => String(v).trim()).filter(Boolean);
			}
		} catch {
		}
		return input.split(",").map((v) => v.trim()).filter(Boolean);
	}
	return [];
};

const filesToImages = (files?: Express.Multer.File[] | undefined): string[] => {
	if (!files || files.length === 0) return [];
	return files.map((f) => `/uploads/blog/${f.filename}`);
};
/*
@user must be authenticated
 - req.body : name, description, distance?, difficulty?, owner?,
   estimatedTime?, elevation?, tags?, images?, highlights?, terrain?, bestTime?
 - images can be uploaded as multipart field "images" or provided as URLs
*/
export const createBlog = async (req: IRequest, res: Response) => {
		const {
			name,
			description,
			distance,
			difficulty,
			owner,
			estimatedTime,
			elevation,
			terrain,
			bestTime,
		} = req.body;
		if (!name || !description) {
			return res.status(400).json({ message: "name and description are required" });
		}

		const tags = parseStringArray(req.body.tags);
		const highlights = parseStringArray(req.body.highlights);
		const bodyImages = parseStringArray(req.body.images);
		const uploadedImages = filesToImages(req.files as Express.Multer.File[] | undefined);
		const images = [...bodyImages, ...uploadedImages];

		const blog = await Blog.create({
			name,
			description,
			distance,
			difficulty,
			owner,
			estimatedTime,
			elevation,
			terrain,
			bestTime,
			tags,
			highlights,
			images,
			createdBy: req.user?._id,
		});

		return res.status(201).json({ ok: true, blog });

};

export const getBlogs = async (_req: Request, res: Response) => {
		const blogs = await Blog.find().sort({ createdAt: -1 });
		return res.status(200).json({ ok: true, blogs });
};

export const getBlogById = async (req: Request, res: Response) => {
		const blog = await Blog.findById(req.params.id);
		if (!blog) return res.status(404).json({ message: "Blog not found" });
		return res.status(200).json({ ok: true, blog });
};

export const updateBlog = async (req: IRequest, res: Response) => {
		const blog = await Blog.findById(req.params.id);
		if (!blog) return res.status(404).json({ message: "Blog not found" });

		const {
			name,
			description,
			distance,
			difficulty,
			owner,
			estimatedTime,
			elevation,
			terrain,
			bestTime,
		} = req.body;
		if (name !== undefined) blog.name = name;
		if (description !== undefined) blog.description = description;
		if (distance !== undefined) blog.distance = distance;
		if (difficulty !== undefined) blog.difficulty = difficulty;
		if (owner !== undefined) blog.owner = owner;
		if (estimatedTime !== undefined) blog.estimatedTime = estimatedTime;
		if (elevation !== undefined) blog.elevation = elevation;
		if (terrain !== undefined) blog.terrain = terrain;
		if (bestTime !== undefined) blog.bestTime = bestTime;

		const tags = parseStringArray(req.body.tags);
		if (tags.length > 0 || req.body.tags === "") blog.tags = tags;

		const highlights = parseStringArray(req.body.highlights);
		if (highlights.length > 0 || req.body.highlights === "") blog.highlights = highlights;

		const bodyImages = parseStringArray(req.body.images);
		const uploadedImages = filesToImages(req.files as Express.Multer.File[] | undefined);
		if (bodyImages.length > 0 || uploadedImages.length > 0 || req.body.images === "") {
			blog.images = [...bodyImages, ...uploadedImages];
		}

		await blog.save();
		return res.status(200).json({ ok: true, blog });
};

export const deleteBlog = async (req: Request, res: Response) => {
		const blog = await Blog.findByIdAndDelete(req.params.id);
		if (!blog) return res.status(404).json({ message: "Blog not found" });
		return res.status(200).json({ ok: true, blogId: blog._id });
};
