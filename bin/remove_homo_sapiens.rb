#!/usr/bin/env ruby

begin
    file = File.open(ARGV[0], "r")
  rescue => err
    STDERR.puts "Cannot open File #{ARGV[0]}"
    exit 1
  end

write = false
newfile = File.new("/scratch/gi/studprj/metaclassify/data_sets/FACS/data/FACS_dataset_WH.fna", "w")

file.each_line do |line|
  if line.match(/^>/)
    if line.match(/Homo sapiens/)
      write = true
    else 
      write = false
      newfile.write(line)
    end
  else
    if write == false
      newfile.write(line)
    end
  end
end

file.close
newfile.close


