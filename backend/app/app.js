/**
 * Author:Diego Casallas
 * Date: 2025-05-27
 * Description: 
*/
import express from 'express';
import cors from 'cors';
import { verifyToken } from "../middleware/authMiddleware.js";
/* The routers are imported to handle specific routes in the application.*/
import uploadFile from '../routers/uploadFile.router.js';
import documentTypeRouter from '../routers/documentType.router.js';
import roleRouter from '../routers/role.router.js';
import userStatusRouter from '../routers/userStatus.router.js';
import userRouter from '../routers/user.router.js';
import profileRouter from '../routers/profile.router.js';
import tokenRouter from '../routers/token.router.js';
import apiUserRouter from '../routers/apiUser.router.js';
import webUserRouter from '../routers/webUser.router.js'



const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rutas públicas
//app.use('/api', apiUserRouter); // No requiere token
app.use('/web', webUserRouter); // No requiere token

// Rutas protegidas API (requiere token de api_user)
app.use('/api', verifyToken('api_user'), uploadFile);
app.use('/api', verifyToken('api_user'), documentTypeRouter);
app.use('/api', verifyToken('api_user'), roleRouter);
app.use('/api', verifyToken('api_user'), userStatusRouter);
app.use('/api', verifyToken('api_user'), userRouter);
app.use('/api', verifyToken('api_user'), profileRouter);
app.use('/api', verifyToken('api_user'), tokenRouter);
// Rutas protegidas WEB (requiere token de web_user)
app.use('/web', verifyToken('web_user'), uploadFile);
app.use('/web', verifyToken('web_user'), documentTypeRouter);
app.use('/web', verifyToken('web_user'), roleRouter);
app.use('/web', verifyToken('web_user'), userStatusRouter);
app.use('/web', verifyToken('web_user'), userRouter);
app.use('/web', verifyToken('web_user'), profileRouter);
app.use('/web', verifyToken('web_user'), tokenRouter);

app.use((rep, res, nex) => {
  res.status(404).json({
    message: 'Endpoint losses'
  });
});

export default app;