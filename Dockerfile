FROM balenalib/rpi-debian:buster

LABEL description="debian buster for Raspberry Pi (Zero) deploy with --privileged"

ENV UDEV=1

# Install packages
RUN install_packages apt-utils wget git

RUN wget -q http://flightaware.com/adsb/piaware/files/packages/pool/piaware/p/piaware-support/piaware-repository_3.8.0_all.deb

RUN dpkg -i piaware-repository_3.8.0_all.deb

RUN install_packages piaware dump1090-fa 

# openLayers
RUN git clone https://github.com/alkissack/Dump1090-OpenLayers3-html.git

# remove install tools
RUN apt-get -qq remove -y --purge \
    apt-utils \
    wget \
    git \
    && apt-get -qq autoremove -y
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir /run/dump1090-fa 
RUN mkdir /run/piaware 

COPY 90-Dump1090-OpenLayers3.conf /etc/lighttpd/conf-enabled
COPY config.js Dump1090-OpenLayers3-html/public_html

# startup script
COPY startPiaware.sh /root
RUN chmod +x /root/startPiaware.sh

CMD /root/startPiaware.sh

# PiAware Skyview web page:
EXPOSE 8080
# OpenLayers web page:
EXPOSE 8081

# for connections to other viewing tools, e.g. Virtual Radar:
# non-MLAT data in Beast format:
EXPOSE 30005
# MLAT data in Beast format:
EXPOSE 30105