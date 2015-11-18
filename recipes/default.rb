#
# Cookbook Name:: nginx_passenger
# Recipe:: default
#
# Copyright 2015, Simone Dall Angelo
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# Install passenger gem
gem_package 'passenger' do
  action :install
  gem_binary '/usr/local/bin/gem'
  version node["nginx_passenger"]["passenger"]["version"]
end

# Download nginx source
remote_file "#{Chef::Config[:file_cache_path]}/nginx-#{node["nginx_passenger"]["nginx"]["version"]}.tar.gz" do
  source "http://nginx.org/download/nginx-#{node["nginx_passenger"]["nginx"]["version"]}.tar.gz"
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  not_if do ::File.exists?("#{Chef::Config[:file_cache_path]}/nginx-#{node["nginx_passenger"]["nginx"]["version"]}") end
end

# Extract nginx
execute 'Extracting nginx' do
  cwd Chef::Config[:file_cache_path]
  command "tar xzf nginx-#{node["nginx_passenger"]["nginx"]["version"]}.tar.gz"
  creates "#{Chef::Config[:file_cache_path]}/nginx-#{node["nginx_passenger"]["nginx"]["version"]}"
end

if node["nginx_passenger"]["headers-more-nginx-module"]["enabled"]
  # Download headers-more-nginx-module
  execute 'Cloning headers-more-nginx-module from GitHub' do
    cwd Chef::Config[:file_cache_path]
    command "git clone git://github.com/agentzh/headers-more-nginx-module.git"
    creates "#{Chef::Config[:file_cache_path]}/headers-more-nginx-module"
  end
end

if node["nginx_passenger"]["ngx_pagespeed"]["enabled"]
  # Download ngx_pagespeed
  remote_file "#{Chef::Config[:file_cache_path]}/release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta.zip" do
    source "https://github.com/pagespeed/ngx_pagespeed/archive/release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta.zip"
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    not_if do ::File.exists?("#{Chef::Config[:file_cache_path]}/release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta") end
  end

  # Unzip ngx_pagespeed
  execute 'Unzips ngx_pagespeed' do
    cwd Chef::Config[:file_cache_path]
    command "unzip release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta.zip"
    creates "#{Chef::Config[:file_cache_path]}/ngx_pagespeed-release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta"
  end

  # Cd ngx_pagespeed + Download psol
  remote_file "#{Chef::Config[:file_cache_path]}/ngx_pagespeed-release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta/#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}.tar.gz" do
    source "https://dl.google.com/dl/page-speed/psol/#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}.tar.gz"
    owner 'root'
    group 'root'
    mode '0644'
    action :create
    not_if do ::File.exists?("#{Chef::Config[:file_cache_path]}/ngx_pagespeed-release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta/#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}") end
  end

  # Extract psol
  execute 'Extracting psol' do
    cwd "#{Chef::Config[:file_cache_path]}/ngx_pagespeed-release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta/"
    command "tar xzf #{Chef::Config[:file_cache_path]}/ngx_pagespeed-release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta/#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}.tar.gz"
    creates "#{Chef::Config[:file_cache_path]}/ngx_pagespeed-release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta/#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}"
  end

  # Mkdir /var/ngx_pagespeed_cache
  directory '/var/ngx_pagespeed_cache' do
    owner 'root'
    group 'root'
    mode '777'
    action :create
  end
end


# Execute passenger-install-nginx-module
bash 'Compiles nginx with all required modules' do
  user 'root'
  extra = []

  if node["nginx_passenger"]["headers-more-nginx-module"]["enabled"]
    extra << "--add-module=#{Chef::Config[:file_cache_path]}/headers-more-nginx-module"
  end

  if node["nginx_passenger"]["ngx_pagespeed"]["enabled"]
    extra << "--add-module=#{Chef::Config[:file_cache_path]}/ngx_pagespeed-release-#{node["nginx_passenger"]["ngx_pagespeed"]["version"]}-beta"
  end
  
  # Modules to --with
  node["nginx_passenger"]["nginx"]["modules"]["withs"].each do |w_mod|
    extra << "--with-#{w_mod}"
  end
  
  # Modules to --without
  node["nginx_passenger"]["nginx"]["modules"]["withouts"].each do |w_mod|
    extra << "--without-#{w_mod}"
  end

  code <<-END
    /usr/local/bin/passenger-install-nginx-module --auto --prefix=/opt/nginx --languages=ruby --nginx-source-dir=#{Chef::Config[:file_cache_path]}/nginx-#{node["nginx_passenger"]["nginx"]["version"]} --extra-configure-flags=\"#{extra.join(' ')}\"
  END
end

# Setup nginx init file
cookbook_file "/etc/init.d/nginx" do
  source "nginx_init"
  owner "root"
  group "root"
  mode 0755
  action :create
end

# Setup nginx conf file
template node["nginx_passenger"]["nginx"]["conf"]["path"] do
  source 'nginx.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
end

# Create deploy dir
directory node["nginx_passenger"]["application"]["deploy_dir"] do
  owner node["nginx_passenger"]["application"]["user"]
  group node["nginx_passenger"]["application"]["user"]
  mode 0755
  action :create
end

execute 'Configtest' do
  command "service nginx configtest"
end

# Enable nginx on boot
service 'nginx' do
  action [:enable, :restart]
end
