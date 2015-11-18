# nginx
default["nginx_passenger"]["nginx"]["version"] = "1.6.3"
default["nginx_passenger"]["nginx"]["conf"] = {
  "path"              => "/opt/nginx/conf/nginx.conf",
  "worker_processes"  => "2",
  "relative_pid_file" => "logs/nginx.pid",
  "pid_file"          => "/opt/nginx/logs/nginx.pid",
  "error_log"         => "logs/error.log"
}

# nginx modules
default["nginx_passenger"]["nginx"]["modules"] = {
  "withs" =>  [
                "http_stub_status_module",
                "http_gzip_static_module",
                "http_ssl_module",
                "http_spdy_module"
              ],
  "withouts" => [
                  "http_autoindex_module",
                  "http_ssi_module",
                  "http_browser_module",
                  "http_empty_gif_module",
                  "http_limit_req_module",
                  "http_limit_conn_module",
                  "http_memcached_module",
                  "http_proxy_module",
                  "http_referer_module",
                  "http_scgi_module",
                  "http_split_clients_module",
                  "http_upstream_ip_hash_module",
                  "http_userid_module",
                  "http_fastcgi_module",
                  "http_uwsgi_module"
                ]
}

# headers-more-nginx-module
default["nginx_passenger"]["headers-more-nginx-module"]["enabled"] = true

# ngx_pagespeed
default["nginx_passenger"]["ngx_pagespeed"]["enabled"] = true
default["nginx_passenger"]["ngx_pagespeed"]["version"] = "1.9.32.10"

# passenger
default["nginx_passenger"]["passenger"]["version"] = "5.0.21"
default["nginx_passenger"]["passenger"]["conf"] = {
  "passenger_max_pool_size" => "3",
  "passenger_min_instances" => "2"
}

# application
default["nginx_passenger"]["application"]["name"] = node["application"]["name"] || ""
default["nginx_passenger"]["application"]["deploy_dir"] = node["application"]["deploy_dir"] || "/var/www"
default["nginx_passenger"]["application"]["user"] = node["application"]["user"] || "nobody"
default["nginx_passenger"]["application"]["url_for_pre_start"] = node["application"]["url_for_pre_start"] || ""
default["nginx_passenger"]["application"]["domain"] = node["application"]["domain"] || ""
