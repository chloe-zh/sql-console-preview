FROM centos:7 AS prep_files

RUN curl https://d3g5vo6xdbdb9a.cloudfront.net/downloads/tarball/opendistroforelasticsearch-kibana/opendistroforelasticsearch-kibana-1.4.0.tar.gz -o /opt/opendistroforelasticsearch-kibana-1.4.0.tar.gz

RUN mkdir /usr/share/kibana
WORKDIR /usr/share/kibana

RUN tar --strip-components=1 -zxf /opt/opendistroforelasticsearch-kibana-1.4.0.tar.gz
RUN rm -rf /usr/share/kibana/plugins/opendistro-alerting
RUN rm -rf /usr/share/kibana/plugins/opendistro_security
RUN rm -rf /usr/share/kibana/plugins/opendistro_index_management_kibana

RUN chmod -R g=u /usr/share/kibana
RUN find /usr/share/kibana -type d -exec chmod g+s {} \;



FROM centos:7

ENV ELASTIC_CONTAINER true

RUN yum update -y && yum install -y fontconfig freetype && yum clean all
COPY --from=prep_files --chown=1000:0 /usr/share/kibana /usr/share/kibana

WORKDIR /usr/share/kibana
ENV PATH=/usr/share/kibana/bin:$PATH
 
RUN kibana-plugin install "https://s3-us-west-2.amazonaws.com/swift-us-west-2-dev.sql-workbench/sql-kibana-plugin/sql-kibana-1.4.0.0.zip" --allow-root && \
    ln -s /usr/share/kibana /opt/kibana && \
    chown -R 1000:0 . && \
    chmod -R g=u /usr/share/kibana && \
    find /usr/share/kibana -type d -exec chmod g+s {} \;

# Set some Kibana configuration defaults.
COPY --chown=1000:0 kibana.yml /usr/share/kibana/config/kibana.yml

# Add the launcher/wrapper script. It knows how to interpret environment
# variables and translate them to Kibana CLI options.
COPY --chown=1000:0 kibana-docker /usr/local/bin/

RUN chmod g+ws /usr/share/kibana && \
    find /usr/share/kibana -gid 0 -and -not -perm /g+w -exec chmod g+w {} \;

RUN find /usr/share/kibana -gid 0 -and -not -perm /g+w -exec chmod g+w {} \; && \
    groupadd --gid 1000 kibana && \
      useradd --uid 1000 --gid 1000 \
      --home-dir /usr/share/kibana --no-create-home kibana && \
      echo $'= CentOS Licensing and Source Code =\n\nThis image is built from CentOS and DockerHub\'s official build of CentOS (https://hub.docker.com/_/centos). Their image contains various Open Source licensed packages and their DockerHub home page provides information on licensing.\n\nYou can list the packages installed in the image by running \'rpm -qa\', and you can download the source code for the packages CentOS and DockerHub provide via the yumdownloader tool.' > /root/CENTOS_LICENSING.txt

USER 1000


LABEL org.label-schema.schema-version="1.0" \
  org.label-schema.vendor="Amazon" \
  org.label-schema.name="opendistroforelasticsearch-kibana" \
  org.label-schema.version="{{ version_tag }}" \
  org.label-schema.url="https://opendistroforelasticsearch.github.io" \
  org.label-schema.vcs-url="https://github.com/mauve-hedgehog/kibana-oss-distro" \
  org.label-schema.license="Apache-2.0" \
  org.label-schema.build-date="{{ build_date }}"


RUN chmod +x /usr/local/bin/kibana-docker
RUN export NODE_OPTIONS="--max-old-space-size=4096"
RUN /usr/local/bin/kibana-docker --optimize
CMD ["/usr/local/bin/kibana-docker"]


