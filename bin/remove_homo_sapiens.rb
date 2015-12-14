#!/usr/bin/env ruby

remove_block = Array.new

begin
    file = File.open(ARGV[0], "r")
  rescue => err
    STDERR.puts "Cannot open File #{ARGV[0]}"
    exit 1
  end
file.each_line do |line|
  if line.match(/^>/)
    if line.match(/Homo sapiens/)
      until line.match(/^>/)
        remove_block.push(line)
      end
      remove_block.clear 
    end
  end
end

file.close


