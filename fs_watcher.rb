#!/usr/bin/ruby
#
# fs_watcher.rb - runs every 30 minutes on sbjenkins, reports via Slack
#                 notifier if jenkins-root filesystem is at or above
#                 THRESHHOLD.
#
# cron entry (zadmin account on sbjenkins host):
#*/30 * * * *  /home/zadmin/bin/fs_watcher.rb > /dev/null &
#
#

gem 'slack-notifier'

require 'slack-notifier'

@notifier = Slack::Notifier.new("https://hooks.slack.com/services/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", channel: '#devops')

inuse = %x[df -h|awk '/jenkins/ {print \$5}' | sed 's/%//g'].to_i

# initial threshhold of 95%
THRESHHOLD = 77.to_i;

if inuse >= THRESHHOLD
    @notifier.ping "SBJENKINS FS FULL: jenkins-root filesystem at #{inuse} percent. Please cleanup old builds."
end
