#!/usr/bin/env ruby

USAGE = "ruby #{$0} dataset_path output"
#ERROR = "No Fasta-File found"

if ARGV.length != 1
  puts USAGE
else
path  = ARGV[0].to_s


names=Array.new
n=0
fascount = 0

begin
  Dir.foreach(path) do |fasdata|
    if fasdata.match(/(fna$|fasta$|fas$|faa$)/)
      fascount += 1
      begin
        data = File.open(path+"/"+fasdata, "r")
      rescue => err
        STDERR.puts "Cannot open file #{fasdata}: #{err}"
        exit 1
      end
        data.each_line do |line|
          if line.match (/^>/)
            name = line.match (/[^\"]\w+\s\w+[^\"]*/)    # von " (w+ = jedes word, s leerzeichen, w+) bis " 
            if !names.include? name
              names[n]= name
              n= n+1
            end
          end
        end
      end
      data.close
  end
  
  if fascount == 0
    puts "No fasta-file found"
    exit 1
  end
rescue => err
    STDERR.puts "Error accessing directory: #{err}"
    exit 1    
end

puts names
        
end
