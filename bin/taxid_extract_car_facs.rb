#!/usr/bin/ruby

require 'set'

USAGE = "Usage: #{$0} datei.txt idmap.txt"

ginum = nil
if ARGV.length != 2
  STDERR.puts USAGE
  exit 1
else

  gi_set = Set.new
  
  #var = ARGV[1].to_i

  begin
    list_of_names = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}."
    exit 1
  end

  list_of_names.each_line do |line|
    s = line.split("\t")
    gi_set.add?(s[0])
  end
  
  begin
    map = File.open(ARGV[1],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[1]}."
    exit 1
  end
  
  map.each_line do |line|
    s = line.split("\t")
    s.each {|l|
    ginum = l.gsub(/(^...)/, '')
    
      if gi_set.member?(ginum)
        puts "#{s[0]}\t#{ginum}"
      end
           }
  end
end
