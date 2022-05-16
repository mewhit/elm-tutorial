FROM node:16-alpine as builder
WORKDIR /app
ENV NODE_ENV=build

COPY package.json yarn.lock ./
RUN yarn install

COPY . .
RUN yarn build

FROM node:16-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY package.json .env tsconfig.build.json ./
COPY ./template ./template/
COPY --from=builder /app/dist/ ./dist/
COPY --from=builder /app/node_modules/ ./node_modules/

CMD ["npm", "run", "start"]
