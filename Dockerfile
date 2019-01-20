FROM nextcloud
ENV SEAFILE_HOST=
ENV SEAFILE_USERNAME=
ENV SEAFILE_PASSWORD=
ENV SEAFILE_TOKEN=
ENV SEAFILE_IS_PRO=false

USER root
RUN apt-get update -y
RUN apt-get install -y gnupg2 jq sudo
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8756C4F765C9AC3CB6B85D62379CE192D401AB61
RUN echo deb http://deb.seadrive.org stretch main | tee /etc/apt/sources.list.d/seafile.list
RUN apt-get update -y
RUN apt-get install seadrive-daemon -y

VOLUME [ "/data" ]
WORKDIR /data
COPY ./entrypoint.sh /entrypoint.child.sh

ENTRYPOINT [ "/entrypoint.child.sh" ]