#!/usr/bin/ruby

module Fasta_parser
  
require 'optparse'
require 'ostruct'

def enum_files_in_subtree(directory)
  stack = Array.new()
  stack.push(directory)
  while not stack.empty?
    subdir = stack.pop
    Dir.entries(subdir).each do |entry|
      if not entry.match(/^\.\.?$/)
        if File.stat(subdir + "/" + entry).file?
          yield subdir + "/" + entry
        else
          stack.push(subdir + "/" + entry)
        end
      end
    end
  end
end

# use the previous function to enumerate all files in directory and
# select only those that are fasta files based on the the possible suffixes
# of the file names
def enum_fasta_files_in_subtree(directory)
  enum_files_in_subtree(directory) do |filename|
    if filename.match(/\.f(na|asta|as|aa)$/) # extend possible suffixes
      yield filename
    end
  end
end

# given the name of an inputfile in fasta format, open it and extract
# the header line from it
def extract_fasta_header(inputfile)
  begin
    f = File.new(inputfile,"r")
  rescue => err
    STDERR.puts "#{$0}: cannot open inputfile #{inputfile}: #{err}"
    exit 1
  end
  f.each_line do |line|
    if line.match(/^>/)
      yield line.chomp
    end
  end
end

#following function
#includes name and id given by the different functions into the hash id_map
def identifier_map(id, name, id_map)
  if !id_map.include? id
    id_map[id] = name
  end 
end

#dataset-parser RAIphy
def raiphy(line, id_map)
  s = line.split("|") 
  id = s[3]
  if id.nil?
    STDERR.puts "No id found"
    exit 1
  end
  name_split = s[4].split(",")
  name = name_split[0]
  if name.nil?
   STDERR.puts "No name found"
   exit 1
  end 
  identifier_map(id, name, id_map)
end

#dataset-parser CARMA and FACS
def carma_facs(line, id_map)
   m = line.match(/=(\d+)/)   
  if m.nil?
    STDERR.puts "No id found"
    exit 1
  end 
  id = m[1]
  m = line.match (/SOURCE_1=\"(.*)\"/)  
  if m.nil?
    STDERR.puts "No name found"
    exit 1
  end 
  name=m[1]
  identifier_map(id, name, id_map)
end

#dataset-parser PhymmBL
def phym(id_map, path_phym)
  begin
    file = File.open(path_phym, "r")
  rescue => err 
    STDERR.puts "Cannot open File #{path_phym}"
    exit 1
  end 
    file.each_line do |linephym|
      s = linephym.split("\t")
      id = s[0]
      name = s[1].gsub(/_/," ")
      identifier_map(id, name, id_map)
    end 
  file.close
end

#dataset-parser PhyloPythia
def phyl(id_map, path_phyl)
  begin
    file = File.open(path_phyl, "r")
  rescue => err
    STDERR.puts "Cannot open File #{path_phyl}"
    exit 1
  end 
  file.each_line do |linephyl|
    s = linephyl.split("\t")
    id = s[3]
    name = s[11]
    identifier_map(id, name, id_map)
  end 
  file.close
end

#dataset-parser Metaphyler
def met(id_map, path_met)
  begin
    file = File.open(path_met, "r")
  rescue => err
    STDERR.puts "Cannot open File #{path_met}"
    exit 1
  end
  file.each_line do |linemet|
    s = linemet.split("\t")
    id = s[0]
    if s[3].match(/genus/)
      name = s[2]
    end 
    identifier_map(id, name, id_map)
  end
  file.close
end

#database-parser SwissProt
def swiss_prot(line, id_map)
  m = line.match(/^>(sp\|\S+\|\S+)/)   
  if m.nil?
    STDERR.puts "No id found"
    exit 1
  end 
  id = m[1]
  m = line.match (/OS=(.*)/)  
  if m.nil?
    STDERR.puts "No name found"
    exit 1
  end 
  name=m[1]
  identifier_map(id, name, id_map)
end
  
def mainly(id_map, testsetname)
  #testsetname = "/scratch/gi/studprj/metaclassify/data_sets/Carma"
    if testsetname.match(/PhymmBL/)
      path_phym = "/scratch/gi/studprj/metaclassify/data_sets/PhymmBL/res/scientific_names.tab"
      phym(id_map, path_phym)
    elsif testsetname.match(/PhyloPythia/)
      path_phyl = "/scratch/gi/studprj/metaclassify/data_sets/PhyloPythia/res/readsInfo.tab"
      phyl(id_map, path_phyl)  
    elsif testsetname.match(/Metaphyler/)
      path_met = "/scratch/gi/studprj/metaclassify/data_sets/Metaphyler/res/markerstax.tab"
      met(id_map, path_met)
    else
      enum_fasta_files_in_subtree(testsetname) do |filename|
        extract_fasta_header(filename) do |header|
          
          if testsetname.match(/(Carma)|(FACS)/)
            if header.match(/\|SOURCES=\{GI=/)
              carma_facs(header, id_map) 
            else
              STDERR.puts "In Carma or FACS: Unknown format in dataset."
              exit 1 
            end
          
          elsif testsetname.match(/RAIphy/)
            if header.match(/^>>gi\|/)
              raiphy(header, id_map)
            else
              STDERR.puts "In RAIphy: Unknown format in dataset."
              exit 1 
            end 

          elsif testsetname.match(/database_SwissProt/)
            if header.match(/^>sp\|\S+/)
              swiss_prot(header, id_map)
            else
              STDERR.puts "In Database_SwissProt: Unknown format in dataset."
              exit 1 
            end
          
          else
            STDERR.puts "Unknown format in dataset."
            exit 1
          end    
        end
      end
    end # if testsetname.match(/PhymmBL/)
    return id_map  
  end #options.testsetnames.each do |testsetname|
end

                  
