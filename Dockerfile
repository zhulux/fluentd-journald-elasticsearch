# or v1.0-debian-onbuild
# FROM fluent/fluentd:v1.1.0-debian
FROM fluent/fluentd:v1.2-debian

ENV FLUENT_ELASTICSEARCH_HOST elasticsearch-logging
ENV FLUENT_ELASTICSEARCH_PORT 9200
ENV FLUENT_ELASTICSEARCH_USER ''
ENV FLUENT_ELASTICSEARCH_PASSWORD ''
ENV FLUENTD_CONF="main.conf"
ENV FLUENTD_OUTPUT="output_es.conf"

# below RUN includes plugin as examples elasticsearch is not required
# you may customize including plugins as you wish
RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo gem install \
        fluent-plugin-elasticsearch \
        fluent-plugin-record-reformer \
        fluent-plugin-kubernetes_metadata_filter \
        fluent-plugin-rewrite-tag-filter \
        fluent-plugin-systemd:0.3.1 \
 && sudo gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem \
 && mkdir -p /fluentd/etc/config.d \
 && mkdir -p /data/var/lib/docker/containers \
VOLUME /fluentd/etc/

COPY main.conf /fluentd/etc/
COPY fluent.conf /fluentd/etc/conf.d/
COPY output_es.conf /fluentd/etc/conf.d/
COPY entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh
CMD exec fluentd -c /fluentd/etc/${FLUENTD_CONF} -p /fluentd/plugins $FLUENTD_OPT
