#!/usr/bin/ruby

def get_cpu
	# Average over n seconds
	pollwait = 2
	poll0 = File.readlines('/proc/stat').grep(/^cpu\s/).first.gsub(/\s{2,}/," ").split(" ")
	sleep pollwait
	poll1 = File.readlines('/proc/stat').grep(/^cpu\s/).first.gsub(/\s{2,}/," ").split(" ")

	user = ((poll1[1].to_i + poll1[2].to_i) - (poll0[1].to_i + poll1[2].to_i)) / pollwait
	system = (poll1[3].to_i - poll0[3].to_i) / pollwait
	idle = (poll1[4].to_i - poll0[4].to_i) / pollwait
	wait = (poll1[5].to_i - poll0[5].to_i) / pollwait
	total = user + system + idle + wait

	{
	'total' => {
	 	'user' => ((user.to_f / total.to_f) * 100).round(2),
	 	'system' => ((system.to_f / total.to_f) * 100).round(2),
	 	'wait' => ((wait.to_f / total.to_f) * 100).round(2),
	 	'idle' => ((idle.to_f / total.to_f) * 100).round(2)
		}
	}
end

vals = get_cpu
puts vals
