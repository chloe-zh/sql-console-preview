FROM opendistroforelasticsearch/opendistroforelasticsearch-kibana:1.4.0

RUN \
  yum install nodejs \
  yum install yarn \
  cd /usr/share/kibana/plugins/ \
  git clone -b opendistro-7.4.2 git@github.com:opendistro-for-elasticsearch/sql-kibana-plugin.git \
  cd /sql-kibana-plugin \
  yarn kbn bootstrap \
  yarn kbn bootstarp \
  yarn build 

