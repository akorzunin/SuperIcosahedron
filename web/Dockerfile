
FROM --platform=$BUILDPLATFORM node:21.7.1-alpine AS frontend
WORKDIR /usr/src/app

RUN --mount=type=bind,source=./web/package.json,target=package.json \
    --mount=type=cache,target=/root/.npm \
    npm i

COPY ./web .

RUN npm run build


FROM caddy:2-alpine AS frontend-final

EXPOSE 8282

COPY --from=frontend /usr/src/app/dist /srv/dist

COPY --from=frontend /usr/src/app/caddy_template/template.html /srv/template.html
