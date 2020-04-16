FROM centos:7 AS prep_files

RUN curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-7.6.1-linux-x86_64.tar.gz -o /opt/elasticsearch-oss-7.6.1-linux-x86_64.tar.gz

RUN mkdir /usr/share/elasticsearch
WORKDIR /usr/share/elasticsearch

RUN tar --strip-components=1 -zxf /opt/elasticsearch-oss-7.6.1-linux-x86_64.tar.gz



FROM centos:7

ENV ELSTIC_CONTAINER true

RUN yum update -y && yum install -y fontconfig freetype && yum clean all
COPY --from=prep_files /usr/share/elasticsearch /usr/share/elasticsearch

WORKDIR /usr/share/elasticsearch
ENV PATH=/usr/share/elasticsearch/bin:$PATH

RUN elasticsearch-plugin install "https://s3-us-west-2.amazonaws.com/swift-us-west-2-dev.sql-workbench/sql-plugin/opendistro-sql-1.6.0.0.zip"

COPY elasticsearch.yml log4j2.properties /usr/share/elasticsearch/config/
RUN mkdir -p config data logs
RUN chmod 0775 config data logs

COPY --chown=1000:0 docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Openshift overrides USER and uses ones with randomly uid>1024 and gid=0
# Allow ENTRYPOINT (and ES) to run even with a different user
RUN chgrp 0 /usr/local/bin/docker-entrypoint.sh && \
    chmod g=u /etc/passwd && \
    chmod 0775 /usr/local/bin/docker-entrypoint.sh

EXPOSE 9200

RUN echo $'= CentOS Licensing and Source Code =\n\nThis image is built from CentOS and DockerHub\'s official build of CentOS (https://hub.docker.com/_/centos). Their image contains various Open Source licensed packages and their DockerHub home page provides information on licensing.\n\nYou can list the packages installed in the image by running \'rpm -qa\', and you can download the source code for the packages CentOS and DockerHub provide via the yumdownloader tool.' > /root/CENTOS_LICENSING.txt


LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Amazon" \
  org.label-schema.name="opendistroforelasticsearch" \
  org.label-schema.version="{{ version_tag }}" \
  org.label-schema.url="https://opendistroforelasticsearch.github.io" \
  org.label-schema.vcs-url="https://github.com/mauve-hedgehog/kibana-oss-distro" \
  org.label-schema.license="Apache-2.0" \
  org.label-schema.build-date="{{ build_date }}"

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["eswrapper"]
