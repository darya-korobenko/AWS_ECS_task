# use the official node.js image
FROM node:16

# set the working directory
WORKDIR /app

# copy package.json and package-lock.json to the container
COPY application/package*.json ./

# install application dependencies
RUN npm install

# copy the rest of the application code
COPY application/ .

# expose the port
EXPOSE 3000

# start the application
CMD ["npm", "run", "start:dev"]
