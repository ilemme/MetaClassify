#!/usr/bin/ruby

require 'set'

USAGE = "Usage: #{$0} list_of_names.txt idmap.txt"

if ARGV.length != 2
  STDERR.puts USAGE
  exit 1
else

  set = Set.new
  id_tax = Hash.new
  begin
    list_of_names = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}\n=> #{err}."
    exit 1
  end

  list_of_names.each_line do |line|
    line_new=line.chomp!
    s = line_new.split("\t")
    #puts s[0]
    set.add(s[0])
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
    STDERR.puts "Cannot open file #{ARGV[1]} \n=> #{err}."
    exit 1
  end
  map.each_line do |line|
    #puts line
    c=line.chomp!
    s = c.split("\t")
    s.each do |object|
      if object.match(/^NC_/)
        object= object.split(".")
        #puts object[0]
        if set.member?(object[0])
          id_tax[object[0]] = s[0]
          #puts object[0]
          #puts "#{object[0]}\t#{s[0]}"
          set.delete(object[0])
        end
      end
    end
  end
end
if not set.empty?
  begin
    log = File.open("logfilephym.txt","w")
  rescue => err
    STDERR.puts "Cannot open file #{log}\n=> #{err}."
    exit 1
  end
  set.each do |id|
    log.puts id
  end
  STDERR.puts " set not empty"
end
id_tax.each {|key, value|
             puts "#{key}\t#{value}"
            }


