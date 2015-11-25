#!/usr/bin/env ruby

USAGE = "ruby #{$0} num_of_datasets dataset_path"
#ERROR = "No Fasta-File found"
num_datasets=ARGV[0].to_i
if ARGV.length != num_datasets + 1
  puts USAGE
else
path=Array.new

ARGV[1..num_datasets].each do |path|
  path  = path.to_s

path_phym = "/scratch/gi/studprj/metaclassify/data_sets/PhymmBL/res/scientific_names.txt"
path_phyl = "/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/res/readsInfo.txt"
path_met = "/scratch/gi/studprj/metaclassify/data_sets/Metaphyler/res/markerstax.tab"
        
hash=Hash.new 
fascount = 0
readphyl = 0
readmet = 0

begin
  Dir.foreach(path) do |fasdata|
    if fasdata.match(/(fna$|fasta$|fas$|faa$)/)
      fascount += 1
      begin
        data = File.open(path+"/"+fasdata, "r")
      rescue => err
        STDERR.puts "Cannot open file #{fasdata}: #{err}"
        exit 1
      end
        data.each_line do |line|
          if line.match (/^>/) 
            
            
            #RAIphy
            if line.match(/gi\|/)
              id = line.match(/\d+/)    # matches every block consitsing "="&"and some digits"
              if id.nil?
                puts "No id found"
                exit 1
              end  
              name = line.match (/[^\"]\w+\s\w+[^\"]*/)    # von " (w+ = jedes word, s leerzeichen, w+) bis " 
              if name.nil?
                puts "No name found"
                exit 1
              end
            #CARMA&FACS
            elsif line.match(/GI=/)
              one ,id = line.match(/(=)(\d+)/).captures    # matches every block consitsing "="&"and some digits"
              if id.nil?
                puts "No id found"
                exit 1
              end  
              name = line.match (/[^\"]\w+\s\w+[^\"]*/)    # von " (w+ = jedes word, s leerzeichen, w+) bis " 
              if name.nil?
                puts "No name found"
                exit 1
              end
            #PHYM
            elsif line.match(/C_/)
              begin
	        file = File.open(path_phym, "r")
	      rescue => err
                STDERR.puts "Cannot open File #{path_phym}"
                exit 1
	      end
              file.each_line do |linephym|
                i= linephym.split("\t")
                id=i[0]
                name=i[1]
                if !hash.include? id
                  hash[id] = name
                end
              end
              file.close
              break
            #PHLO
            elsif line.match(/CHROMAT_FILE/)
              if readphyl!=0
                break
              end
              readphyl+=1
              begin
                file = File.open(path_phyl, "r")
              rescue => err
                STDERR.puts "Cannot open File #{path_phyl}"
                exit 1
              end
              file.each_line do |linephyl|
                i= linephyl.split("\t")
                id=i[3]
                name=i[11]
                if !hash.include? id
                  hash[id] = name
                end
              end
              file.close
            break
            #MET
            elsif line.match(/^\S+[_]\S+[_]\S+/)
              if readmet!=0
                break
              end
              readmet+=1
              begin
                file = File.open(path_met, "r")
              rescue => err
                STDERR.puts "Cannot open File #{path_met}"
                exit 1
              end
              file.each_line do |linemet|
                i= linemet.split("\t")
                id=i[0]
                if i[3].match(/genus/)
                  name=i[2]
                end
                if !hash.include? id
                  hash[id] = name
                end
              end
              file.close
              break
            end
            
           
            if !hash.include? id
              hash[id] = name
            end
          end
        end
        data.close
      end
  end
  
  if fascount == 0
    puts "No fasta-file found"
    exit 1
  end
  
rescue => err
    STDERR.puts "Error: #{err}"
    exit 1    
end

hash.each {|key,value|   
  puts "#{key}\t#{value}"}

end
end