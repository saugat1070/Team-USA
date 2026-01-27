import { NextFunction, Request, Response } from "express";

const logger = (req: Request, res: Response, next: NextFunction) => {
    const start = Date.now();

    res.on("finish", () => {
        const durationMs = Date.now() - start;
        const { method, originalUrl } = req;
        const { statusCode } = res;
        console.log(`${method} ${originalUrl} ${statusCode} - ${durationMs}ms`);
    });

    next();
};

export default logger;
