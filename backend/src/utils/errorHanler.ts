
import { Request, Response } from "express"

type AsyncHandler<T = unknown> = (req: Request, res: Response) => Promise<T>

const AsyncWrapper = function <T>(fn: AsyncHandler<T>) {
    return (req: Request, res: Response) => {
        Promise.resolve(fn(req, res)).catch((err: Error) => {
            return res.status(500).json({
                message: "Internal Server Error",
                error: err.message
            })
        })
    }
}

export default AsyncWrapper;