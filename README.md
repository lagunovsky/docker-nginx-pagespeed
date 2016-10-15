# 🏂 Nginx with PageSpeed module [dev]
 [![Build Status](https://travis-ci.org/lagun4ik/docker-nginx-pagespeed.svg)](https://travis-ci.org/lagun4ik/docker-nginx-pagespeed)

## Snippets
```nginx
  include snippets/pagespeed.conf;
  include snippets/php.conf;
  include snippets/proxy.conf;
  include snippets/static.conf;
```

### pagespeed.conf
```nginx
pagespeed RewriteLevel CoreFilters;
pagespeed EnableFilters remove_comments,collapse_whitespace,rewrite_images,resize_images,resize_rendered_image_dimensions,prioritize_critical_css,insert_dns_prefetch,combine_css,rewrite_css,combine_javascript,rewrite_javascript;
```

### php.conf
```nginx
location / {
  try_files $uri $uri/ /index.php$args;
}

location ~ \.php$ {
  fastcgi_index index.php;
  fastcgi_split_path_info ^(.+\.php)(/.*)$;
  fastcgi_pass php:9000;
  include /etc/nginx/fastcgi_params;
  fastcgi_param  SCRIPT_FILENAME  $realpath_root$fastcgi_script_name;
  fastcgi_param DOCUMENT_ROOT $realpath_root;
}

```

### proxy.conf
```nginx
proxy_set_header Host $http_host;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Port $server_port;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_read_timeout 900;
```

### static.conf
```nginx
location = /favicon.ico {
  log_not_found off;
  access_log off;
}

location = /robots.txt {
  allow all;
  log_not_found off;
  access_log off;
}

location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
  expires max;
  log_not_found off;
}

error_page 500 502 503 504 /50x.html;

location = /50x.html {
  root /usr/share/nginx/html;
}
```
