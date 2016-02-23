#!/usr/bin/ruby

#programm kann nur im Ordner /work/gi/software/taxtree ausgefuehrt werden
require 'set'


def parse_carma_facs(fasta, id_to_read_hash, seq_count)
  fasta.each_line do |line|
    if line.match(/^>/)
      seq_count=seq_count+1
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
  return seq_count
end

def parse_phym(fasta, id_to_read_hash, seq_count)
  fasta.each_line do |line|
    if line.match(/^>/)
      seq_count=seq_count+1
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
  return seq_count
end

def parse_phyl(fasta, id_to_read_hash, seq_count)
  fasta.each_line do |line|
    if line.match(/^>/)
      seq_count=seq_count+1
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
  return seq_count
end

def parse_met(fasta, id_to_read_hash, seq_count)
  fasta.each_line do |line|
    if line.match(/^>/)
      seq_count=seq_count+1
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
  return seq_count
end

def parse_rai(fasta, id_to_read_hash, seq_count)
  fasta.each_line do |line|
    if line.match(/^>/)
      seq_count=seq_count+1
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
  return seq_count
end

def create_file(x)
  
  begin
    text = File.open(x,"a")
    yield text
  rescue => err  #folgende fehler im code werden hier zurueckgesandt
    STDERR.puts "Cannot open file #{x} #{err}"
    exit 1
  end
end

def write_file(x)
  begin
    text = File.open(x,"w")
    yield text
  rescue => err  #folgende fehler im code werden hier zurueckgesandt
    STDERR.puts "Cannot open file #{x} #{err}"
    exit 1
  end
end

def open_file(x)
  begin
    text = File.open(x,"r")
    yield text
  rescue => err  #folgende fehler im code werden hier zurueckgesandt
    STDERR.puts "Cannot open file #{x} #{err}"
    exit 1
  end
end

def check_fasta(filename)
  if filename.match(/\.f(na|asta|as|aa)$/) # extend possible suffixes
    yield filename
  end
end

def check_file(filename, word)
  if filename.match(/#{word}_swiss\S+ex\.txt/)
    #puts filename
    yield filename
  #else
    #puts "no match #{filename}"
  end
end
  

def one_step(paths)
  diamond_megan = "/scratch/gi/studprj/metaclassify/diamond_output/megan_diamond"
  lambda_megan = "/scratch/gi/studprj/metaclassify/lambda_output/megan_lambda"
  
  gi_mapfile= "/work/gi/studprj/metaclassify/list_of_names/tax_ids/combined.txt" #"/scratch/gi/studprj/metaclassify/data_base/gi_taxid_nucl_ncbi.dmp"
  map_file= "/work/gi/studprj/metaclassify/list_of_names/tax_ids/combined.txt" #"/scratch/gi/studprj/metaclassify/data_base/idmap.txt"
  reads_Info = "/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/res/readsInfo.tab"
  id_to_read = Hash.new()
  id_to_tax = Hash.new()
  seq_count=0
  
  
  paths.each do |path|
    Dir.entries(path).each do |file|
      #enum_files_in_subtree(path) do |file|
      check_fasta(path + "/"+ file) do |fastafile|
        open_file(fastafile) do |fasta|
          if path.match(/(Carma)/)
            seq_count =parse_carma_facs(fasta,id_to_read, seq_count)
            search_gi_num(id_to_tax, gi_mapfile.to_s, id_to_read)
            megan(diamond_megan, "car", id_to_tax)
            newick("car_output_diamond.txt")
            calculate("car_output_diamond.txt",seq_count)
            megan(lambda_megan, "car", id_to_tax)
            newick("car_output_lambda.txt")
            calculate("car_output_lambda.txt",seq_count)
          elsif path.match(/(FACS)/)
            seq_count =parse_carma_facs(fasta,id_to_read, seq_count) 
            search_gi_num(id_to_tax, gi_mapfile.to_s, id_to_read)
            megan(diamond_megan, "fac", id_to_tax)
            newick("fac_output_diamond.txt")
            calculate("fac_output_diamond.txt",seq_count)
            megan(lambda_megan, "fac", id_to_tax)
            newick("fac_output_lambda.txt")
            calculate("fac_output_lambda.txt",seq_count)
          elsif path.match(/PhymmBL/)
            seq_count =parse_phym(fasta, id_to_read, seq_count)
            search_gi_num(id_to_tax, map_file.to_s, id_to_read)
            megan(diamond_megan, "phym", id_to_tax)
            newick("phym_output_diamond.txt")
            calculate("phym_output_diamond.txt",seq_count)
            megan(lambda_megan, "phym", id_to_tax)
            newick("phym_output_lambda.txt")
            calculate("phym_output_lambda.txt",seq_count)
          elsif path.match(/PhyloPythia/)  
            seq_count =parse_phyl(fasta, id_to_read, seq_count)
            open_extern(id_to_tax, id_to_read, reads_Info.to_s, 2)
            megan(diamond_megan, "phyl", id_to_tax)
            newick("phyl_output_diamond.txt")
            calculate("phyl_output_diamond.txt",seq_count)
            megan(lambda_megan, "phyl", id_to_tax)
            newick("phyl_output_lambda.txt")
            calculate("phyl_output_lambda.txt",seq_count)
          elsif path.match(/Metaphyler/)
            seq_count = parse_met(fasta, id_to_read, seq_count)
            open_extern(id_to_tax, id_to_read, "/scratch/gi/studprj/metaclassify/data_sets/Metaphyler/res/markerstax.tab", 1)
            megan(diamond_megan, "met", id_to_tax)
            newick("met_output_diamond.txt")
            calculate("met_output_diamond.txt",seq_count)
            megan(lambda_megan, "met", id_to_tax)
            newick("met_output_lambda.txt")
            calculate("met_output_lambda.txt",seq_count)
          elsif path.match(/RAIphy/)
            seq_count=parse_rai(fasta, id_to_read,seq_count)
            search_gi_num(id_to_tax, gi_mapfile.to_s, id_to_read)
            megan(diamond_megan, "rai", id_to_tax)
            newick("rai_output_diamond.txt")
            calculate("rai_output_diamond.txt",seq_count)
            megan(lambda_megan, "rai", id_to_tax)
            newick("rai_output_lambda.txt")
            calculate("rai_output_lambda.txt",seq_count)
            
          end
        end
      end
    end
  end
end

def calculate(name, total)
  diff_hash = Hash.new()
  filename = "/work/gi/studprj/metaclassify/#{name}"
  #puts filename
  open_file(filename) do |text|
    #puts filename
    text.each_line do |line|
      s= line.split("\t")
      if s[3] == '?'
        #do nothing
      else
        diff= s[3].to_i + s[4].to_i
        if diff_hash.has_key?(diff)
          diff_hash[diff]= diff_hash[diff]+1
        else
          diff_hash[diff] = 1
        end    
        #puts "#{diff}"
      end
    end
  end
  create_file("/work/gi/studprj/metaclassify/calculation_" + name) do |calc|
    count = 0
    cor0=0
    cor1=0
    cor2=0
    cor3=0
    cor4=0
    cor5=0
    
    
    diff_hash = diff_hash.sort
    calc.puts ">Distance\tNumber of Reads"
    
    diff_hash.each do |key, value|
      if key== "0"
        cor0= cor0+value
        cor1= cor1+value
        cor2= cor2+value
        cor3= cor3+value
        cor4= cor4+value
        cor5= cor5+value
      end
      if key== "1"
        cor1= cor1+value
        cor2= cor2+value
        cor3= cor3+value
        cor4= cor4+value
        cor5= cor5+value
      end
      if key== "2"
        cor2= cor2+value
        cor3= cor3+value
        cor4= cor4+value
        cor5= cor5+value
      end
      if key== "3"
        cor3= cor3+value
        cor4= cor4+value
        cor5= cor5+value
      end
      if key== "4"
        cor4= cor4+value
        cor5= cor5+value
      end
      if key== "5"
        cor5= cor5+value
      end
    
      calc.puts "#{key}\t#{value}"
      count = count + value
    end
    calc.puts "\n"
    calc.puts "Total number of assignedreads: #{count}"
    calc.puts "Total number of reads: #{total}"
    
    calc.puts "\n"
    calc.puts "sensitivitaet"
    var= cor0/total.to_f
    var=var.round(4)
    calc.puts "0\t #{var}" 
    
    var= cor1/total.to_f
    var=var.round(4)
    calc.puts "1\t #{var}"
    
    var= cor2/total.to_f
    var=var.round(4)
    calc.puts "2\t #{var}"  
    
    var= cor3/total.to_f
    var=var.round(4)
    calc.puts "3\t #{var}" 
    
    var= cor4/total.to_f
    var=var.round(4)
    calc.puts "4\t #{var}" 
    
    var= cor5/total.to_f
    var=var.round(4)
    calc.puts "5\t #{var}"  
    calc.puts "\n"
    
    calc.puts "precision"
    var= cor0/count.to_f
    var=var.round(4)
    calc.puts "0\t #{var}" 
    
    var= cor1/count.to_f
    var=var.round(4)
    calc.puts "1\t #{var}"
    
    var= cor2/count.to_f
    var=var.round(4)
    calc.puts "2\t #{var}"  
    
    var= cor3/count.to_f
    var=var.round(4)
    calc.puts "3\t #{var}" 
    
    var= cor4/count.to_f
    var=var.round(4)
    calc.puts "4\t #{var}" 
    
    var= cor5/count.to_f
    var=var.round(4)
    calc.puts "5\t #{var}" 

end
system("rm #{filename}")
end

def newick(name)
  write_file("/work/gi/studprj/metaclassify/" + name) do |out|
    output= `ruby /work/gi/software/taxtree/newick-parse.rb --lca /work/gi/studprj/metaclassify/samples.txt --path-length all_ids.tre`
    out.puts output
  end
    system("rm /work/gi/studprj/metaclassify/samples.txt")
end

def megan(path, word, id_to_tax)
  puts "\r creating temporary-file samples.txt"
  filename = "/work/gi/studprj/metaclassify/samples.txt"
  create_file(filename) do |sample|
    Dir.entries(path).each do |file|
      check_file(path + '/'+ file, word) do |word_file|
        open_file(word_file) do |text|
          text.each_line do |line|
            #line_new=line.chomp!
            #puts line
            s = line.split("\t")
            m_read = s[0]
            m_taxid = s[1].chomp!
            next if m_taxid == "-2"
            if id_to_tax.has_key?(m_read)
              sample.puts "#{id_to_tax[m_read]}\t#{m_taxid}" #read gold_tax megan_tax
              #system("rm samples.txt")
              #calculate()
            end
          end
        end
      end
    end
  end  
end

def  hash_empty(hash, no_match)
  #not extern als file ausgeben
  count=0 
  if not hash.empty?
    #STDERR.puts "Some Seqs aus Fastafile wurden nicht zugeordnet"
    #puts " Seq aus Fasta: "
    hash.each_pair do |key, value|
      value.each do |read|
        #puts "#{read}\t#{key}"
      end
    end
  end
  hash.clear
  #puts("\r Zugeordnet #{count}")
  count = 0
  #puts("Nicht zugeordnet wurden:")
  no_match.each do |object|
    count = count+1
    #puts(object)
  end
  #puts("\r Nicht zugeordnet #{count}")
end

def open_extern(id_to_tax, hash, map, var)
  id=nil 
  count=0
  no_match= Set.new()
  open_file(map) do |text|
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
        #puts id
      else       
        STDERR.puts "Error wrong input"
        exit 1
      end      
      
      if hash.has_key?(id)
        #puts "has key"
        value = hash[id]
        value.each do |r| 
          count=count+1
          #puts "#{r}\t#{s[var]}\t#{id}" #r tax gi
          
          if id_to_tax.has_key?(r)          #zuordnung read zur passenden taxid     
            #id_to_tax[r].push(s[var])
          else
            id_to_tax[r]= s[var]
           # id_to_tax[r]= Array.new()
            #id_to_tax[r].push(s[var])
          end
          
        end
        hash.delete(id)  
      else
        no_match.add("#{id}\t#{s[1]}")
      end
    end
  end    
  hash_empty(hash, no_match)
end

def search_gi_num(id_to_tax, map, hash)
  id=nil 
  count=0
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
          #puts "#{r}\t#{s[1]}\t#{id}"
          
         if id_to_tax.has_key?(r)      #zuordnung read zur passenden taxid     
#             id_to_tax[r].push(s[1]) 
         else
           id_to_tax[r]= s[1]   
         end
#             id_to_tax[r]= Array.new()
#             id_to_tax[r].push(s[1])
#           end
          
        end
        hash.delete(id)
      else
        no_match.add("#{id}\t#{s[1]}")
      end
    end
  end
  hash_empty(hash, no_match)
  #puts "DURCH search_gi_num"
end



testsets = ["/scratch/gi/studprj/metaclassify/data_sets/Carma/data","/scratch/gi/studprj/metaclassify/data_sets/FACS/data","/scratch/gi/studprj/metaclassify/data_sets/RAIphy/data","/scratch/gi/studprj/metaclassify/data_sets/Metaphyler/data","/scratch/gi/studprj/metaclassify/data_sets/PhymmBL/data","/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/data"]
#database = ["/scratch/gi/studprj/metaclassify/data_base/database_SwissProt"]


one_step(testsets)
puts "Done!"
