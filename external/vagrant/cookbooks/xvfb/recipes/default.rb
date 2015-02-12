package 'firefox' do
  action :install
end
# TODO : the suggeston did not help:
# http://stackoverflow.com/questions/12644001/how-to-add-the-missing-randr-extension


# TODO - generate profile directories
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
%w{hub node}.each do |init_script| 
cookbook_file ("/etc/init.d/#{init_script}") do 
 source 'xvfb'
 owner 'root'
 group 'root'
 mode 00755
 Chef::Log.info('generate init script for #{init_script}')
end 
end
# start Jenkins server

# start Jenkins client

# TODO: optionally start phantomJS
%w{vncserver Xvfb}.each do |service_name|
service service_name do
 # NOTE: replace with Upstart for 14.04
 unless node[:platform_version].match( /14\./).nil?
   provider Chef::Provider::Service::Upstart
 else
   provider Chef::Provider::Service::Debian
 end
  action [:enable, :start]
  supports :status => true, :restart => true
  Chef::Log.info("started #{service_name}")
end
end
# ssh -o StrictHostKeyChecking=no username@hostname.com
