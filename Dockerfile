FROM docker:23.0.4-dind as upstream

RUN \
    apk update \
    # install bash jq util-linux and openssh
    && apk add --update --no-cache bash jq util-linux \
    && which ssh-agent || ( apk add openssh-client ) \
    # cleanup
    && rm /var/cache/apk/* \
    && rm -rf /var/lib/apk/

# copy everything to a clean image, so we can change the exposed ports
# see https://gitlab.com/search?search=Service+docker+dind+probably+didn%27t+start+properly&nav_source=navbar&project_id=250833&group_id=9970&scope=issues&sort=updated_desc
FROM scratch

COPY --from=upstream / /

VOLUME /var/lib/docker

# EXPOSE 2375/tcp # is for insecure connections, and having both breaks Gitlab's "wait-for-it" service
EXPOSE 2376/tcp

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []

ENV DOCKER_VERSION=23.0.4
ENV DOCKER_TLS_CERTDIR='/certs'
