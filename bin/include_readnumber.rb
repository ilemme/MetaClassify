#!/usr/bin/ruby


var = 1
begin
  text = File.open(ARGV[0],"r")
rescue => err
  STDERR.puts "Cannot open file #{ARGV[0]}."
  exit 1
end

begin
  out = File.open(ARGV[1],"w")
rescue => err
  STDERR.puts "Cannot open file #{ARGV[1]}."
  exit 1
end

text.each_line do |line|
  if line.match(/^>/)
    line[0] = ""
    if line[0]== ">"
      line[0]= ""
    end
    out.print(">r", var, "\s" , line)
    var = var+1
    STDOUT.write "\r Reads: #{var-1} \t"
  else
    out.write(line)
  end
end