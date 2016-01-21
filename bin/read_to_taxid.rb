#!/usr/bin/ruby

USAGE = "Usage: #{$0} dataset.fasta taxid_map.txt"

def parse_carma(fasta, id_to_read_hash)
  fasta.each_line do |line|
    if line.match(/^>/)
      line_new=line.chomp!
      read=line_new.match(/^>(r\d+().\d)/)
      if read.nil?
        STDERR.puts "No Match for #{read} found"
        exit 1
      end 
      s = line.match (/=(\d+)/)
      if s.nil?
        STDERR.puts "No Match for #{s} found"
        exit 1
      end 
      r=read[1]
      gi= s[1]
      if not id_to_read_hash.has_key?(gi)
        id_to_read_hash[gi]= Array.new
      end
      id_to_read_hash[gi].push(r)
    end
  end
end

def parse_phym(fasta, id_to_read_hash)
  fasta.each_line do |line|
    if line.match(/^>/)
      line_new=line.chomp!
      read=line_new.match(/^>(r\d+)/)
      if read.nil?
        STDERR.puts "No Match for #{read} found"
        exit 1
      end 
      s=line_new.split(" ")
      #Fur phymmbl s = s[1].split(".")
      r=read[1]
      ident= s[1]
     #puts ident, r
      if not id_to_read_hash.has_key?(ident)
        id_to_read_hash[ident]= Array.new
      end
      id_to_read_hash[ident].push(r)
    end
  end
end

def parse_met(fasta, id_to_read_hash)
  fasta.each_line do |line|
    if line.match(/^>/)
      line_new=line.chomp!
      read=line_new.match(/^>(r\d+)/)
      if read.nil?
        STDERR.puts "No Match for #{read} found"
        exit 1
      end 
      s=line_new.match(/\s((\wP_\d+)|(d+)|(\w{4}\d+)|(\w{4}_\w_\d))/)
      #Fur phymmbl s = s[1].split(".")
      if s.nil?
        STDERR.puts "No Match for #{s} found in \n #{line_new}"
        exit 1
      end 
      r=read[1]
      ident= s[1]
      #puts ident, r
      if not id_to_read_hash.has_key?(ident)
        id_to_read_hash[ident]= Array.new
      end
      id_to_read_hash[ident].push(r)
    end
  end
end


def parse_rai(fasta, id_to_read_hash)
  fasta.each_line do |line|
    if line.match(/^>/)
      line_new=line.chomp!
      read=line_new.match(/^>(r\d+)/)
      if read.nil?
        STDERR.puts "No Match for #{read} found"
        exit 1
      end 
      s=line_new.split("|")
      r=read[1]
      ident= s[1]
      #puts ident, r
      if not id_to_read_hash.has_key?(ident)
        id_to_read_hash[ident]= Array.new
      end
      id_to_read_hash[ident].push(r)
    end
  end
end


if ARGV.length != 2
  STDERR.puts USAGE
  exit 1
  
else

 read_to_id_hash = Hash.new
 id_to_read_hash = Hash.new() 
 no_match= Array.new
 id=nil
 count=0
 path = ARGV[0].to_s
  begin
    fasta = File.open(ARGV[0],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[0]}."
    exit 1
  end
  
  if path.match(/(Carma)|(FACS)/)
    parse_carma(fasta,id_to_read_hash)
    
  elsif path.match(/(PhymmBL)|(PhyloPythia)/)
    parse_phym(fasta, id_to_read_hash)
    #Phym_id_taxid.txt muss noch ueberarbeitet werden 
    #["NC_003212", "1"]      272626
  elsif path.match(/Metaphyler/)
    parse_met(fasta, id_to_read_hash) 
  elsif path.match(/RAIphy/)
    parse_rai(fasta, id_to_read_hash)  
  end

  begin
    info_file = File.open(ARGV[1],"r")
  rescue => err
    STDERR.puts "Cannot open file #{ARGV[1]}."
    exit 1
  end

    
  info_file.each_line do |line|
    line = line.chomp!
    s=line.split("\t") 
    id=s[0]
    if id_to_read_hash.has_key?(id)
      value = id_to_read_hash[id]
      value.each do |r| 
        count=count+1
        puts "#{r}\t#{s[1]}\t#{id}"
      end
     else
       no_match.push("#{id}\t#{s[1]}")
    end
  end
  STDERR.puts("\r #{count}")
=begin
no_match.each do |object|
    STDERR.puts(object)
  end
=end
end
  