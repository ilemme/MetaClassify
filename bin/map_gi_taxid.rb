#!/usr/bin/ruby

require 'set'

USAGE = "Usage: #{$0} list_of_names.txt idmap.txt"

if ARGV.length != 2
  STDERR.puts USAGE
  exit 1
else

  gi_set = Set.new

  begin
    list_of_names = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}."
    exit 1
  end

  list_of_names.each_line do |line|
    line_new=line.chomp!
    s = line_new.split("\t")
    gi_set.add(s[0])
  end
 #puts gi_set.size
=begin
 gi_set.each do |i|
         puts i
       end
=end
  begin
    map = File.open(ARGV[1],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[1]}."
    exit 1
  end
  map.each_line do |line|
   # puts line
    c=line.chomp!
    s = c.split("\t")
=begin    
    if s.is_a?(Array)
      puts "ja"
    end
=ends.each
    if gi_set.member?(s[0])
      puts "#{s[0]}\t#{s[1]}"
    end
  end
end

