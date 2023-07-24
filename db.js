import { config } from 'dotenv';
import { createConnection } from 'mysql2/promise';

config();

const connection = await createConnection({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_DATABASE,
});

export { connection };
