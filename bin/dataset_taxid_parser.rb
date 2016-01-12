#!/usr/bin/ruby

require 'set'

prev_swissid = nil
curr_swissid = nil
giset = Set.new
refseqset = Set.new
taxid = nil

begin
  idmapping = File.open(ARGV[0],"r")
rescue => err
  STDERR.puts "Cannot open file #{ARGV[0]}."
  exit 1
end
  
def printdata(giset, refseqset, taxid)
  print "#{taxid}\t"
    giset.each do |ginr| 
      print "GI_#{ginr}\t"
    end
    refseqset.each do |refnr| 
      print "#{refnr}\t"
    end
    print "\n"
end

idmapping.each_line do |line|
  s = line.split("\t")
  curr_swissid = s[0]
  if prev_swissid.nil?
    prev_swissid = curr_swissid
  end  
  if prev_swissid == curr_swissid
    if s[1].match(/GI/)
      giset.add(s[2].gsub(/\n/,''))
    elsif s[1].match(/NCBI_TaxID/)
      taxid = s[2].gsub(/\n/,'')
    elsif s[1].match(/RefSeq/)
      refseqset.add(s[2].gsub(/\n/,''))
    end
  elsif prev_swissid != curr_swissid
    if not taxid.nil?
      printdata(giset, refseqset, taxid)
    end
    giset.clear
    refseqset.clear
    taxid = nil
    prev_swissid = curr_swissid
  else 
    STDERR.puts "Fehler"
    exit 1
  end
end
