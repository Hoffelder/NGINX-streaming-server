	FROM buildpack-deps:bullseye

	LABEL maintainer="Vinicius Hoffelder <vinicius.hoffelder1@gmail.com>"

	# Versions of NGINX and NGINX-rtmp-module to use
	ENV NGINX_VERSION nginx-1.23.2
	ENV NGINX_RTMP_MODULE_VERSION 1.2.2

	#Install Dependencies
	RUN apt-get update && \
	    apt-get install -y ca-certificates openssl libssl-dev && \
	    rm-rf /var/lib/apt/lists/*

	#Download and decompress Nginx

	RUN mkdir -p /tmp/build/nginx && \
	    cd /tmp/build/nginx && \
	    wget -O ${NGINX_VERSION} && \
	    ./configure \
	    	--sbin-path=usr/local/sbin/nginx \
	    	--conf-path=/etc/nginx/nginx.conf \
	    	--error-log-path=/var/log/nginx.pid \
	    	--lock-path=/var/lock/nginx/access.log \
	    	--http-client-body-temp-path=/tmp/nginx-client-body \
	    	--with-http_ssl_module \
	    	--with-threads \
	    	--with-ipv6 \
	    	--add-module=/tmp/build/nginx-rtmp-module/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION} -with-debug && \
	    make  -j $(getconf _NPROCESSORS_ONLN) && \
	    make install && \
	    mkdir /var/lock/nginx && \
	    rm -rf /tmp/build

	#Forward logs to Docker
	RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
	    ln -sf /dev/stderr /var/log/nginx/error.log

	#Set up config file 
	COPY nginx.conf /etc/nginx/nginx.conf

	EXPOSE 1935
	CMD ["nginx", "-g", "daemon off;"]


