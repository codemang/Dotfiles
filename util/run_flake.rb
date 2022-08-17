#!/usr/bin/env ruby

num_times = ARGV[0].to_i
command = ARGV[1]

if num_times.nil? || command.nil?
  puts "Invalid arguments supplied. Must run as follows - run_flake 10 ls"
  exit 1
end

print "Num times run: "

(1..num_times).each_with_index do |index|
  print "#{index} "
  response = `#{command} 2>&1`
  did_pass = $?.success?

  unless did_pass
    puts "\nReceived non-zero response."
    puts response
    exit 1
  end
end

puts "\nAll commands completed successfully!"
