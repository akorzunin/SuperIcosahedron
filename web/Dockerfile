
FROM --platform=$BUILDPLATFORM node:21.7.1-alpine AS frontend
WORKDIR /usr/src/app

RUN --mount=type=bind,source=./web/package.json,target=package.json \
    --mount=type=cache,target=/root/.npm \
    npm i

COPY ./web .

RUN npm run build


FROM alpine:latest AS frontend-final
WORKDIR /src

# Copy the executable from the "build" stage.
COPY --from=frontend /usr/src/app/dist ./web/dist
