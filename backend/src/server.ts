
import { app } from "./main.js";
import Env from "./Config/envConfig.js";


function ServerRunner(portNumber: number = 3000) {
    app.listen(portNumber,"0.0.0.0",()=>{
        console.log("Server Running at:", portNumber)
    })
};

ServerRunner(Env.portNumber)
