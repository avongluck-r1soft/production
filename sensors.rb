#!/usr/bin/ruby

require 'rubygems'
require 'net/ssh'

def get_password()
  pass = ''
  File.open("/home/scott/scripts/.pass/list", "r").each do |line|
    pass = line.split[1]
  end
  return pass
end

user = 'continuum'
pass = get_password()

@cmd = "sensors -f"

def cleanup_ufw_rules(host, user, pass)
  puts host.chomp + " " + user + " " +pass
  hn = host.chomp
  Net::SSH.start(hn, user, :password => pass) do |ssh|
    result = ssh.exec!(@cmd)
    puts result
  end
end


HOSTS = '/home/scott/scripts/hosts'

File.open("#{HOSTS}", "r").each do |host|
  cleanup_ufw_rules(host, user, pass)
end
