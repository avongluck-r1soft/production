#!/usr/bin/ruby

gem 'slack-notifier'

require 'slack-notifier'

@notifier = Slack::Notifier.new("https://hooks.slack.com/services/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", channel: '#devops')

inuse = %x[df -h|awk '/jenkins/ {print \$5}' | sed 's/%//g'].to_i

# initial threshhold of 95%
threshhold = 95.to_i;

if inuse >= threshhold
    @notifier.ping "SBJENKINS FS FULL: jenkins-root filesystem at #{inuse} percent. Please cleanup old builds."
end

