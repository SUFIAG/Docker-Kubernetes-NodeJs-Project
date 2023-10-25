FROM node:lts-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install
# RUN npm ci --only=production

COPY . .

EXPOSE 3000

RUN npm run build

CMD [ "node", "dist/index.js" ]
