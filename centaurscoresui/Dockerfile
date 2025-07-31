FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y apache2 systemctl curl tar && \
    rm -rf /var/lib/apt/lists/*

COPY init.sh /init.sh
RUN chmod +x /init.sh

CMD ["/init.sh"] 
