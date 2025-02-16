FROM node:16.17.0-alpine as builder
WORKDIR /app

# Copy package.json and yarn.lock first to leverage Docker's cache
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install

# Copy the rest of the files
COPY . .

# Ensure dependencies are up-to-date after copying files
RUN yarn install

ARG TMDB_V3_API_KEY
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the project
RUN yarn build

FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY --from=builder /app/dist .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
