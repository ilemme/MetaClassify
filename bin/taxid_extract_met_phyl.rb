#!/usr/bin/ruby

require 'set'

USAGE = "Usage: #{$0} datei.txt var \n fuer Metaphyler var = 1 \n fuer PhloPythia var = 2"

if ARGV.length != 2
  STDERR.puts USAGE
  exit 1
else

  id_tax= Set.new
  var = ARGV[1].to_i

  begin
    info_file = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}."
    exit 1
  end

  info_file.each_line do |line|
    s = line.split("\t")
    if var== 1
      if s[3].match(/genus/)
        id_tax.add("#{s[0]}\t#{s[var]}\t#{s[2]}")
      end
    elsif var== 2
      id_tax.add("#{s[3]}\t#{s[var]}\t#{s[10]}")
    else
      STDERR.puts "Error wrong input", USAGE
      exit 1
    end
  end
end
id_tax.each do |line|
  puts line
  
end
