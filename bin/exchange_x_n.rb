#!/usr/bin/ruby


begin
  f = File.open("/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/data/combined.fna", "r")
rescue => err
  STDERR.puts "Cannot open File"
  exit 1
end

newfile = File.open("/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/data/phylophytia_exchanged_x.fna", "w")

f.each_line do |line|
  if line.match(/^>/)
    newfile.write(line)
  else 
    newfile.write(line.gsub("X","N"))
  end
end
f.close
newfile.close




                  
