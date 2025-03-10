FROM grafana/mimir:2.15.0

COPY ./config.yaml /mnt/config/

USER root

CMD ["-config.file=/mnt/config/config.yaml", "-config.expand-env=true"]
