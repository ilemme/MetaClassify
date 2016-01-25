#!/usr/bin/ruby

USAGE = "Usage: #{$0} taxtree_meg_dataset_prog.txt"

diff_hash= Hash.new

if ARGV.length != 1
  STDERR.puts USAGE
  exit 1
else
  
  begin
    megan = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]} #{err}."
    exit 1
  end
  
  megan.each_line do |line|
    s= line.split("\t")
    diff= s[3].to_i + s[4].to_i
    #puts diff
    if diff_hash.has_key?(diff)
      diff_hash[diff]= diff_hash[diff]+1
    else
      diff_hash[diff] = 1
    end    
    #puts "#{diff}"
  end
end
count = 0


diff_hash.each_pair do |key, value|
  puts "#{key}\t#{value}"
  count = count + value

end
puts count
