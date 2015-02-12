#package 'firefox' do
#  action :install
#end

package 'linuxvnc' do
  action :install
end

puts  \
node['display_driver']['install_flavor']

remote_file "#{Chef::Config[:file_cache_path]}/selenium.jar" do
  source "#{node['selenium']['url']}"
# NOTE version !
 Chef::Log.info('downloaded selenium jar into: ' + Chef::Config[:file_cache_path])
end

# http://www.abdevelopment.ca/blog/start-vnc-server-ubuntu-boot
cookbook_file '/etc/init.d/vncserver' do 
 source 'vncserver'
 owner 'root'
 group 'root'
 mode 00755
 Chef::Log.info('generate init script for linuxvnc servr')
end 

package 'xvfb' do
  action :install
end

# https://gist.github.com/dmitriy-kiriyenko/974392
# TODO: merge run_xvnc.sh
# that is available for Debian
# and my earlier custom shell script 
cookbook_file '/etc/init.d/Xvfb' do 
 source 'xvfb'
 owner 'root'
 group 'root'
 mode 00755
 Chef::Log.info('generate init script for xvfb servr')
end 


# TODO: create user to run Vnc
# TODO: create a .vnc directory for that user

# Create init script for selenium hub and node
# https://github.com/esycat/selenium-grid-init

# start Jenkins server

# start Jenkins client

# TODO: optionally start phantomJS

service 'vncserver' do
 # NOTE: replace with Upstart for 14.04
 unless node[:platform_version].match( /14\./).nil?
   provider Chef::Provider::Service::Upstart
 else
   provider Chef::Provider::Service::Debian
 end
  action [:enable, :start]
  supports :status => true, :restart => true
  Chef::Log.info('istarted vncserver')
end

service 'Xvfb' do
 # NOTE: replace with Upstart for 14.04
 unless node[:platform_version].match( /14\./).nil?
   provider Chef::Provider::Service::Upstart
 else
   provider Chef::Provider::Service::Debian
 end
  action [:enable, :start]
  supports :status => true, :restart => true
  Chef::Log.info('started Xvfb')
end

# use http://serverfault.com/questions/132970/can-i-automatically-add-a-new-host-to-known-hosts
# ssh -o StrictHostKeyChecking=no username@hostname.com
