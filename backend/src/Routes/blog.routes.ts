import { Router } from "express";
import multer from "multer";
import path from "path";
import {
  createBlog,
  deleteBlog,
  getBlogById,
  getBlogs,
  updateBlog,
} from "../Controller/blog.controller.js";
import AsyncWrapper from "../utils/errorHanler.js";
import { validateToken } from "../middleware/auth.middleware.js";

const blogRoutes = Router();

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, path.resolve("uploads/blog"));
  },
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);
    const name = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, name);
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
});

blogRoutes.post("/blogs", validateToken, upload.array("images", 10), AsyncWrapper(createBlog));
blogRoutes.get("/blogs", AsyncWrapper(getBlogs));
blogRoutes.get("/blogs/:id", AsyncWrapper(getBlogById));
blogRoutes.patch("/blogs/:id", validateToken, upload.array("images", 10), AsyncWrapper(updateBlog));
blogRoutes.delete("/blogs/:id", validateToken, AsyncWrapper(deleteBlog));
export default blogRoutes;
