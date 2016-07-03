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

# get sizes for /storage01-/storage09, print host, %used, filesystem.
@cmd = "for i in {1..9}; do df -h /storage0$i|awk -v MYHOST=$(hostname) '/storage/ {print MYHOST\" \"$5\" \"$6}'; done"

def get_fs_usage(host, user, pass)
  puts host.chomp + " " + user + " " +pass
  hn = host.chomp
  Net::SSH.start(hn, user, :password => pass) do |ssh|
    result = ssh.exec!(@cmd)
    puts result
  end
end


HOSTS = '/home/scott/production/hosts'

File.open("#{HOSTS}", "r").each do |host|
  get_fs_usage(host, user, pass)
end
