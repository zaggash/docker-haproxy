FROM linuxserver/baseimage
MAINTAINER zaggash <zaggash@users.noreply.github.com>
ENV APTLIST="libxslt1-dev libffi-dev libffi6 libpython-dev libssl-dev python2.7 python-virtualenv python-urllib3 python-requests python-cherrypy python-lxml python-pip python2.7-dev bc inotify-tools haproxy "

#Applying stuff
RUN     add-apt-repository ppa:fkrull/deadsnakes-python2.7 && \
	add-apt-repository ppa:vbernat/haproxy-1.6 && \
	apt-get update -q && \
	apt-get install -yq $APTLIST && \
	
	#install pip packages
	pip install pip-review && \
	pip install -U pip pyopenssl ndg-httpsclient virtualenv && \
	
	#cleaunp
	apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
	
#Update any packages now
RUN pip-review --local --auto 

#Adding Custom files
COPY defaults/ /defaults/
COPY init/ /etc/my_init.d/
COPY services/ /etc/service/

RUN chmod -v +x /etc/service/*/run && chmod -v +x /etc/my_init.d/*.sh

# Volumes and Ports
VOLUME /config
EXPOSE 80 443
