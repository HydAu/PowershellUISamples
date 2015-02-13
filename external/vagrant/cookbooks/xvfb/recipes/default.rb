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
%w{selenium_hub selenium_node}.each do |init_script| 
template ("/etc/init.d/#{init_script}") do 
 source"#{init_script}.erb"
 variables(
   #TODO
 ) 
 owner 'root'
 group 'root'
 mode 00755
 Chef::Log.info('generate init script for #{init_script}')
end 
end
# create directory for selenium
# TODO: create a user (not really necessary with Xvfb)
directory '/root/selenium' do
  owner 'root'
  group 'root'
  mode  00755
  action :create
end
file '/root/selenium/selenium.jar' do
  owner 'root'
  content ::File.open("#{Chef::Config[:file_cache_path]}/selenium.jar").read
action :create
end

template '/root/selenium/node.json' do
  source 'node.json.erb'

  variables(
   # variable :platform will be provided by the runtime
   :my_platform => node['my_platform']
  )
  owner 'root'
  group 'root'
  mode 00644
  Chef::Log.info('configure node')
end 
# start X window server
%w{vncserver Xvfb}.each do |service_name|
  service service_name do
    # NOTE: Init replace with Upstart for 14.04
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
# http://www.apache.org/dyn/closer.cgi/logging/log4j/1.2.17/log4j-1.2.17.tar.gz
remote_file "#{Chef::Config[:file_cache_path]}/log4j.tar.gz" do
  source "#{node['log4j']['url']}"
# NOTE version !
 Chef::Log.info('downloaded selenium jar into: ' + Chef::Config[:file_cache_path])
end
# TODO  : expand the tar

# start Jenkins server and client

%w{selenium_hub selenium_node}.each do |service_name|
  service service_name do
    # NOTE: Init replace with Upstart for 14.04
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
# TODO: optionally start phantomJS



# ssh -o StrictHostKeyChecking=no username@hostname.com
