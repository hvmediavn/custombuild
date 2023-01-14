#!/bin/sh

PHP_VER=`echo $0 | grep -o '[0-9]*'`

OPTIONS=
if [ "$1" != "" ]; then
        if [ -s "$1" ]; then
                OPTIONS=" -c ${1} ${OPTIONS}"
        fi
        shift
fi

if [ "$#" -gt 0 ]; then
        SENDMAIL_FROM="`echo $@ | grep -o 'sendmail_from=[^ ]*' | cut -d'\"' -f2`"
        if [ "${SENDMAIL_FROM}" != "" ]; then
                SENDMAIL_ADD="-f ${SENDMAIL_FROM}"
        fi
else
        SENDMAIL_ADD="-f admin@`hostname`"
fi

# http://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html
# Set desired PHP_FCGI_* environment variables.
# Example:
# PHP FastCGI processes exit after 500 requests by default.
# JE: Do not limit it to facilitate XCache (or set it really high, like 10000)
PHP_FCGI_MAX_REQUESTS=0
export PHP_FCGI_MAX_REQUESTS

# See http://www.webhostingtalk.com/archive/index.php/t-1165678.html
PHP_FCGI_CHILDREN=0
export PHP_FCGI_CHILDREN
exec /usr/local/php${PHP_VER}/bin/php-cgi${PHP_VER} ${OPTIONS} -d sendmail_path="/usr/sbin/sendmail -t -i ${SENDMAIL_ADD}" $@
