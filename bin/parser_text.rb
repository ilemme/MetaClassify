#!/usr/bin/ruby

require 'set'

id_set = Set.new
#id_map = Hash.new

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
  map = File.open(ARGV[1],"r")
rescue => err
  STDERR.puts "Cannot open map #{ARGV[1]}"
  exit 1
end

map.each_line do |line| 
  s = line.split("\t")
  #puts s[0]
  if (id_set.member?(s[0]))
    puts line
  #id_map[s[0]] = s[1]
  end
end

#id_map.each {|key,value|   
 #            puts "#{key}\t#{value}"}




  
