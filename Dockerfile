# Specify a base image
# As we need a NodeJS to run the npm command, we can use the Node image with tag alpine, that means you will download the strict vers
# https://hub.docker.com/_/node?tab=description&page=1&ordering=last_updated
# If you create a tag for this phase, you will not be able to build it on AWS (FROM node:alpine as builder)
FROM node:alpine

# https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/learn/lecture/11436998#questions/14297316
# We are specifying that the USER which will execute RUN, CMD, or ENTRYPOINT instructions will be the node user, as opposed to root (default).
USER node

# -p means to not print errors if exist and to create parent folder if neccessary
RUN mkdir -p /home/node/app

# Use this as working directory. Actually, new NodeJS forbids locating files in the root directory, so this command is neccessary
# We are then creating a directory of /home/node/app prior to the WORKDIR instruction. This will prevent a permissions issue since WORKDIR by default will create a directory if it does not exist and set ownership to root.
WORKDIR /home/node/app

# Copy only one file to the working folder in the container to make sure the next command will run from cashe if dockerfile for example will be changed
# The inline chown commands will set ownership of the files you are copying from your local environment to the node user in the container.
COPY --chown=node:node ./package.json ./

# Install some dependencies 
RUN npm install

# Copy all files from current folder to the working folder in the container
COPY --chown=node:node ./ ./

# Build the production build
RUN npm run build

# Does nothing for us automatically, but for elastic beanstalk it is automatically gets mapped for incomming traffic
EXPOSE 80

FROM nginx
COPY --from=0 /home/node/app/build /usr/share/nginx/html