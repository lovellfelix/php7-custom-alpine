#!/bin/sh

# Set the timezone. Base image does not contain the setup-timezone script, so an alternate way is used.
if [ "$CONTAINER_TIMEZONE" ]; then
    cp /usr/share/zoneinfo/${CONTAINER_TIMEZONE} /etc/localtime && \
	echo "${CONTAINER_TIMEZONE}" >  /etc/timezone && \
	echo "Container timezone set to: $CONTAINER_TIMEZONE"
fi

# Apache server name change
if [ ! -z "$APACHE_SERVER_NAME" ]
	then
		sed -i "s/#ServerName www.example.com:80/ServerName $APACHE_SERVER_NAME/" /etc/apache2/httpd.conf
		echo "Changed server name to '$APACHE_SERVER_NAME'..."
	else
		echo "NOTICE: Change 'ServerName' globally and hide server message by setting environment variable >> 'APACHE_SERVER_NAME=your.server.name' in docker command or docker-compose file"
fi

# Set group id
if [ "$PGID" ]; then
    groupmod -g ${PGID} apache
fi

# Set user id
if [ "$PUID" ]; then
    usermod -u ${PUID} apache
fi

# Start (ensure apache2 PID not left behind first) to stop auto start crashes if didn't shut down properly
echo "Clearing any old processes..."
rm -f /run/apache2/apache2.pid
rm -f /run/apache2/httpd.pid

echo "Starting apache..."
httpd -D FOREGROUND