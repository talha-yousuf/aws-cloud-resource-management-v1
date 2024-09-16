const http = require("http");
const port = 3000;

const routes = {
  "/": "Hello world form a demo Node.js app deployed with AWS",
  "/status": "The is the status page!",
  "/info": "This is the info page!",
  "/health": "Health check passed!",
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
