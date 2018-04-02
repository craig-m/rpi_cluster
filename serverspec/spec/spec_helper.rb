require 'serverspec'
require 'net/ssh'
require 'yaml'

set :backend, :ssh

properties = YAML.load_file('inventory.yml')

host = ENV['TARGET_HOST']
set_property properties[host]

options = Net::SSH::Config.for(host)

options[:user] ||= Etc.getlogin

set :host,        options[:host_name] || host
set :ssh_options, options

# Don't Disable sudo
set :disable_sudo, false

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C'

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
