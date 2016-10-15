#!/bin/bash

set -e

if [[ "$1" == -* ]]; then
    set -- nginx -g daemon off; "$@"
fi

if [ -n "$PAGESPEED_ENABLE" ]
then
    sed -i 's|pagespeed on;|pagespeed '"$PAGESPEED_ENABLE"';|g' /etc/nginx/conf.d/pagespeed.conf
fi

exec "$@"
