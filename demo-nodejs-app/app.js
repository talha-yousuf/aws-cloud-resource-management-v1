require("dotenv").config();

const http = require("http");
const mysql = require("mysql");
const redis = require("redis");

const port = 3000;

const dbClient = mysql.createConnection({
  host: process.env.RDS_ENDPOINT,
  // todo: pull following from aws secrets manager
  user: "adminUsername",
  password: "adminPassword",
  database: "demoDatabase",
});

const redisClient = redis.createClient({
  host: process.env.REDIS_ENDPOINT,
  port: 6379,
});

dbClient.connect((error) => {
  if (error) {
    console.error("Error connecting to RDS MySQL database:", error);
  } else {
    console.log("Connected to RDS MySQL database.");
  }
});

redisClient.on("connect", () => {
  console.log("Connected to ElastiCache Redis cluster.");
});

redisClient.on("error", (error) => {
  console.error("Error connecting to ElastiCache Redis cluster:", error);
});

const routes = {
  "/": "Hello world from a demo Node.js app deployed with AWS",
};

const requestHandler = (request, response) => {
  const url = request.url;

  if (routes[url]) {
    response.end(routes[url]);
  } else {
    response.statusCode = 404;
    response.end("Page not found!");
  }
};

const server = http.createServer(requestHandler);

server.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
