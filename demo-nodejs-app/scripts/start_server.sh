#!/bin/bash
cd /home/ec2-user/demo-nodejs-app
node app.js >app.log 2>&1 &
