#!/usr/bin/ruby

USAGE = "Usage: #{$0} megan_output.txt"

write = false


if ARGV.length != 1
  STDERR.puts USAGE
  exit 1
else

 id_hash = Hash.new
 id=nil
  begin
    megan = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}."
    exit 1
  end

  megan.each_line do |line|
    if line.match(/-2/)
      write = true
    else 
      write = false
      puts "#{line}"
    end
  end
end

megan.close