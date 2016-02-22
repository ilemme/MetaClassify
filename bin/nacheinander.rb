#!/usr/bin/ruby
require 'set'


def parse_carma_facs(fasta, id_to_read_hash)
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
      s = s[1].split(".")
      r=read[1]
      ident= s[0]
      if not id_to_read_hash.has_key?(ident)
        id_to_read_hash[ident]= Array.new
      end
      id_to_read_hash[ident].push(r)
    end
  end
end

def parse_phyl(fasta, id_to_read_hash)
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
      puts ident, r
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
      puts ident, r
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

def open_file(x)
  begin
    text = File.open(x,"r")
    yield text
  rescue => err
    STDERR.puts "Cannot open file #{x} #{err}"
    exit 1
  end
end

def check_fasta(filename)
  if filename.match(/\.f(na|asta|as|aa)$/) # extend possible suffixes
    yield filename
  end
end

def first_step(paths)
  gi_mapfile= "/scratch/gi/studprj/metaclassify/data_base/gi_taxid_nucl_ncbi.dmp"
  map_file="/scratch/gi/studprj/metaclassify/data_base/idmap.txt"
  id_to_read = Hash.new()
  
  
  paths.each do |path|
    Dir.entries(path).each do |file|
      #enum_files_in_subtree(path) do |file|
      check_fasta(path + "/"+ file) do |fastafile|
        open_file(fastafile) do |fasta|
          if path.match(/(Carma)/)
            parse_carma_facs(fasta,id_to_read)
            search_gi_num(gi_mapfile, id_to_read)
            
          elsif path.match(/(FACS)/)
            parse_carma_facs(fasta,id_to_read) 
            search_gi_num(gi_mapfile, id_to_read)
            
          elsif path.match(/PhymmBL/)
            parse_phym(fasta, id_to_read)
            search_gi_num(map_file, id_to_read)
            
          elsif path.match(/PhyloPythia/)  
            parse_phyl(fasta, id_to_read)
            open_extern(id_to_read, "/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/res/readsInfo.tab", 2)
                       
          elsif path.match(/Metaphyler/)
            parse_met(fasta, id_to_read)
            open_extern(id_to_read, "/scratch/gi/studprj/metaclassify/data_sets/Metaphyler/res/markerstax.tab", 1)
            
          elsif path.match(/RAIphy/)
            parse_rai(fasta, id_to_read)
            search_gi_num(gi_mapfile, id_to_read)
            
          end
        end
      end
    end
  end
end

def  hash_empty(hash, no_match)
  count=0 
  if not hash.empty?
    STDERR.puts "Some Seqs aus Fastafile wurden nicht zugeordnet"
    puts " Seq aus Fasta: "
    hash.each_pair do |key, value|
      value.each do |read|
        puts "#{read}\t#{key}"
      end
    end
  end
  hash.clear
  puts("\r Zugeordnet #{count}")
  count = 0
  puts("Nicht zugeordnet wurden:")
  no_match.each do |object|
    count = count+1
    puts(object)
  end
  puts("\r Nicht zugeordnet #{count}")
end

def open_extern(hash, map, var)
  id=nil 
  no_match= Set.new()
  open_file(map.to_s) do |text|
    text.each_line do |line|
      line = line.chomp!
      s=line.split("\t")
      if var == 1
        if s[3].match(/genus/)
          id = s[0]
          #id_tax.add("#{s[0]}\t#{s[var]}\t#{s[2]}") #id tax name
        end
      elsif var == 2
        #id_tax.add("#{s[3]}\t#{s[var]}\t#{s[10]}")
        id=s[3]
        puts id
      else       
        STDERR.puts "Error wrong input"
        exit 1
      end      
      
      if hash.has_key?(id)
        value = hash[id]
        value.each do |r| 
          count=count+1
          puts "#{r}\t#{s[var]}\t#{id}" #r tax gi
        end
        hash.delete(id)  
      else
        no_match.add("#{id}\t#{s[1]}")
      end
    end
  end    
  hash_empty(hash, no_match)
end

def search_gi_num(map, hash)
  id=nil 
  no_match= Set.new()
  open_file(map) do |text|
    text.each_line do |line|
      line = line.chomp!
      s=line.split("\t") 
      id=s[0]
      if hash.has_key?(id)
        value = hash[id]
        value.each do |r| 
          count=count+1
          puts "#{r}\t#{s[1]}\t#{id}"
        end
        hash.delete(id)
      else
        no_match.add("#{id}\t#{s[1]}")
      end
    end
  end
  hash_empty(hash, no_match)
end



testsets = ["/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/data","/scratch/gi/studprj/metaclassify/data_sets/FACS/data"]#,"/scratch/gi/studprj/metaclassify/data_sets/RAIphy/data","/scratch/gi/studprj/metaclassify/data_sets/Metaphyler/data","/scratch/gi/studprj/metaclassify/data_sets/PhymmBL/data","/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/data"]
database = ["/scratch/gi/studprj/metaclassify/data_base/database_SwissProt"]


first_step(testsets)# + database)
