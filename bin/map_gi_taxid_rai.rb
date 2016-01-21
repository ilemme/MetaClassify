#!/usr/bin/ruby

require 'set'

USAGE = "Usage: #{$0} list_of_names.txt idmap.txt"

if ARGV.length != 2
  STDERR.puts USAGE
  exit 1
else

  gi_set = Set.new
  tax_id_hash = Hash.new

  begin
    fasta = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}."
    exit 1
  end

  fasta.each_line do |line|
    if line.match(/^>/)
      s = line.split("|")
      gi_set.add?(s[1])
    end
  end

  begin
    map = File.open(ARGV[1],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[1]}."
    exit 1
  end
  
=begin
  found_taxs_RAI = File.new("/work/gi/studprj/metaclassify/list_of_names/tax_ids/RAI_id_taxid.txt","w+")
  missing_taxs_RAI = File.new("missing_taxs_RAI.txt","w")
=end
  
  map.each_line do |line|
    c = line.chomp!
    s = c.split("\t")    
    if gi_set.member?(s[0])
      f = File.open("/work/gi/studprj/metaclassify/list_of_names/tax_ids/RAI_id_taxid.txt","a")
      #f.write("#{s[0]}\t#{s[1]}")
      puts "#{s[0]}\t#{s[1]}"
    end
  end  
=begin  
  f = File.open("/work/gi/studprj/metaclassify/list_of_names/tax_ids/RAI_id_taxid.txt","r")
  
  missing = File.open("missing_taxs_RAI.txt","w")
  
  f.each_line do |line|
    s = line.split("\t")
    if gi_set.include?(s[0])
      #do nothing
    else
      missing.write(s[0])
    end
  end
=end   
end
