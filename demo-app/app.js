const express = require("express");
const mysql = require("mysql");
const redis = require("redis");
const path = require("path");

const app = express();
const port = process.env.PORT || 3000;

// MySQL connection config
const db = mysql.createConnection({
  host: process.env.RDS_HOSTNAME,
  user: process.env.RDS_USERNAME,
  password: process.env.RDS_PASSWORD,
  database: process.env.RDS_DBNAME,
});

// Redis connection config
const redisClient = redis.createClient({
  host: process.env.REDIS_HOSTNAME,
  port: 6379,
});

// Connect to RDS MySQL
db.connect((err) => {
  if (err) console.log("Error connecting to MySQL: ", err);
  else console.log("Connected to MySQL!");
});

redisClient.on("error", (err) => {
  console.log("Error connecting to Redis: ", err);
});

redisClient.on("connect", () => {
  console.log("Connected to Redis!");
});

app.use(express.static(path.join(__dirname, "public")));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
