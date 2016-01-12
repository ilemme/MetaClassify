#!/usr/bin/ruby

require 'set'

id_set = Set.new
id_map = Set.new

begin
  text = File.open(ARGV[0],"r")
rescue => err
  STDERR.puts "Cannot open file #{ARGV[0]}."
  exit 1
end
  
text.each_line do |line|
  s = line.split("|")
  id = s[1]
  id_set.add?(id)
end

begin
  map = File.open(ARGV[1],"r").read
rescue => err
  STDERR.puts "Cannot open map #{ARGV[1]}"
  exit 1
end

#not_added = 0
id_set.each_with_index do |member, idx|
  #last_map_line_count = 0
  #found = false
  map.each_line do |line|
    #last_map_line_count += 1
    if line.match(/#{member}/)
      #found = true
      id_map.add?(line)
      break
    end
  end
  #STDOUT.write "Searched: #{idx + 1} /#{id_set.size}\tAdded: #{id_map.size}\tLast map line count checked: #{last_map_line_count}\n"
  #not_added += 1 unless found
end

id_map.each do |line|
  puts "#{line}"
end
      



  
