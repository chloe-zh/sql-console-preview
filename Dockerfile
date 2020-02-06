FROM ubuntu:latest

COPY kibana.zip /usr/share

RUN apt-get update && apt-get install -y unzip
RUN \
  cd /usr/share && \
  unzip kibana.zip && rm kibana.zip



FROM node:10.15.2
WORKDIR /usr/share/kibana/plugins/sql-kibana-plugin/

RUN yarn
RUN yarn build

