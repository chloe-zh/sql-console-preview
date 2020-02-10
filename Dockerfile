FROM node:10.15.2 as build-env
WORKDIR /kibana/plugins/sql-kibana-plugin/
COPY ["package.json", "yarn.lock", "./"]
RUN yarn
COPY . ./
RUN yarn build

EXPOSE 5601
CMD ["yarn start"]