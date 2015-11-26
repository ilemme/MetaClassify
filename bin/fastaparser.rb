#!/usr/bin/env ruby

USAGE = "USAGE: ruby #{$0} num_of_datasets(Integer!) output_option(1,2 or 3)/
         dataset_path\n>>output_option:1 =names and ID\n\t\t2 = only names\n\t\t3 = only ID"

num_datasets = ARGV[0].to_i
output_op = ARGV.last.to_i
hash = Hash.new 
fascount = 0
readphyl = 0
readmet = 0
linecount = 0
path_phym = "/scratch/gi/studprj/metaclassify/data_sets/PhymmBL/res/scientific_names.txt"
path_phyl = "/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/res/readsInfo.txt"
path_met = "/scratch/gi/studprj/metaclassify/data_sets/Metaphyler/res/markerstax.tab"

if ARGV.length != num_datasets + 2 
  STDERR.puts USAGE
  exit 1
elsif !num_datasets.is_a?(Integer) 
  STDERR.puts USAGE
  exit 1
elsif (output_op <= 0) or (output_op > 3)
  STDERR.puts USAGE
  exit 1
else
  path=Array.new
  ARGV[(1..num_datasets)].each do |path|
    path  = path.to_s
    begin
      Dir.foreach(path) do |fasdata|
        if fasdata.match(/\.(fna$|fasta$|fas$|faa$)/) 
          begin
            data = File.open(path+"/"+fasdata, "r")
          rescue => err #begin line 34
            STDERR.puts "Cannot open file #{fasdata}: #{err}"
            exit 1
          end # begin line 34
            data.each_line do |line|
              if line.match(/^>/)
                fascount += 1
                linecount = 1  
                
                #RAIphy
                if line.match(/^>>gi\|/)
                  id = line.match(/\d+/)    # matches every block consisting "="&"and some digits"
                  if id.nil?
                    STDERR.puts "No id found"
                    exit 1
                  end  #id.nil? line 47
                  name = line.match(/[^\"]\w+\s\w+[^\"]*/)    # von " (w+ = jedes word, s leerzeichen, w+) bis " #split
                  if name.nil?
                    STDERR.puts "No name found"
                    exit 1
                  end #if name.nil? line 52
                  
                #CARMA&FACS
                elsif line.match(/\|SOURCES=\{GI=/)
                  m = line.match(/=(\d+)/)   # matches every block consisting "="&"and some digits"
                  if m.nil?
                    STDERR.puts "No id found"
                    exit 1
                  end #line 61
                  id = m[1]
                  m = line.match (/SOURCE_1=\"(.*)\"/)    # von " (w+ = jedes word, s leerzeichen, w+) bis " 
                  if m.nil?
                    STDERR.puts "No name found"
                    exit 1
                  end 
                  name=m[1]     #line 66
                  
                #PHYM
                elsif line.match(/C_/)
                  begin
                    file = File.open(path_phym, "r")
                  rescue => err #begin line 73
                    STDERR.puts "Cannot open File #{path_phym}"
                    exit 1
                  end #begin line 73
                    file.each_line do |linephym|
                      i= linephym.split("\t")
                      id=i[0]
                      name=i[1].gsub(/_/," ")
                      if !hash.include? id
                        hash[id] = name
                      end #line 83
                    end #file.each_line do |linephym|
                  file.close
                  break
                                    
                #PHYL
                elsif line.match(/CHROMAT_FILE/)
                  if readphyl!=0
                    break #elsif line.match(/CHROMAT_FILE/)
                  end # if readphyl!=0
                  readphyl+=1
                  begin
                    file = File.open(path_phyl, "r")
                  rescue => err
                    STDERR.puts "Cannot open File #{path_phyl}"
                    exit 1
                  end #begin line 96
                  file.each_line do |linephyl|
                    i= linephyl.split("\t")
                    id=i[3]
                    name=i[11]
                    if !hash.include? id
                      hash[id] = name
                    end #line 106
                  end #file.each_line do |linephyl
                  file.close
                  break #if line.match(/^>/)
                  
                #MET
                elsif line.match(/^\S+[_]\S+[_]\S+/)
                  if readmet!=0
                    break #elsif line.match(/^\S+[_]\S+[_]\S+/)
                  end #if readmet!=0
                  readmet+=1
                  begin
                    file = File.open(path_met, "r")
                  rescue => err
                    STDERR.puts "Cannot open File #{path_met}"
                    exit 1
                  end #begin line 119
                  file.each_line do |linemet|
                    i= linemet.split("\t")
                    id=i[0]
                    if i[3].match(/genus/)
                      name=i[2]
                    end #line 128
                    if !hash.include? id
                      hash[id] = name
                    end #!hash.include? id
                  end # file.each_line do |linemet|
                  file.close
                  break ##if line.match(/^>/)
                else # if line.match(/gi\|/)
                  STDERR.puts "Unknown data-set"
                  exit 1
                end #  if line.match(/gi\|/)
              
                if !hash.include? id
                  hash[id] = name
                end #!hash.include? id
              end #if line.match(/^>/)
            end #data.each_line do |line|
            if linecount == 0
            STDERR.puts "#{fasdata} has wrong format"
            exit 1
            end # if linecount == 0  
          data.close
        end #if fasdata.match(/(fna$|fasta$|fas$|faa$)/)
          
      end # Dir.foreach(path) do |fasdata|
      
      if fascount == 0
        STDERR.puts "No fasta-file found"
        exit 1
      end #fascount == 0
      
    rescue => err #begin line 31
        STDERR.puts "Error: #{err}"
        exit 1    
    end #begin line 31

    if output_op == 1
      hash.each {|key,value|   
        puts "#{key}\t#{value}"}
    elsif output_op == 2
      hash.each {|key,value|   
        puts "#{value}"}
    elsif output_op == 3
      hash.each {|key,value|   
        puts "#{key}"}
    else
      STDERR.puts "Error. Wrong option argument"
      exit 1
    end #if output_op == 1

  end #ARGV[1..num_datasets].each do |path|
end #if ARGV.length != num_datasets + 2 
