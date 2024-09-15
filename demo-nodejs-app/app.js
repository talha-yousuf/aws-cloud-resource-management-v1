// app.js
const http = require("http");
const port = 3000;

const requestHandler = (request, response) => {
  response.end("Hello, this is a demo Node.js app deployed with CodeDeploy!");
};

const server = http.createServer(requestHandler);

server.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
