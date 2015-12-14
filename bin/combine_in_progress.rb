#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

def parseargs(argv)
  options = OpenStruct.new
  options.testsetnames = nil
  options.namesonly = false
  options.idsonly = false
  arr= Array.new
  options.datasetpath = "/scratch/gi/studprj/metaclassify/data_sets"
  
  # maybe implement an option to overwrite datapath, if necessary
  optionparser = OptionParser.new()
  # rename following option to switch on mode which outputs extra values
  optionparser.on("-o DIR","--o_path","change default path to ") do |dir|
    arr.push(dir)
  end
  optionparser.on("-d DIR","--db_path","change default path to ") do |dir|
    arr.push(dir)
    puts arr
  end
  optionparser.on("-s DIR","--ds_path","change default path to ") do |dir|
    arr.push(dir)
  end
  optionparser.on("-h","--help","Show this message") do
    puts optionparser
    exit
  end
=begin
  rest = optionparser.parse(argv)
  if rest.empty?
    options.testsetnames = testsets
  else
    options.testsetnames = rest
    options.testsetnames.each do |name|
      if not testsets.member?(name)
        STDERR.puts "#{$0}: illegal name #{name}: possible names of testsets " +
            "are " + testsets.join(", ")
        exit 1
      end
    end
  end
=end
  return arr
end



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


def extract_name_file(filename)
  begin
    file = File.open(filename, "r")
  rescue => err 
    STDERR.puts "Cannot open the File #{filename} #{err}"
    exit 1
  end 
  file.each_line do |line|
    yield line
  end
end

def open_name_file(directory, id_map)
  enum_files_in_subtree(directory) do |filename|
    if filename.match(/\.tab$/) # extend possible suffixes
      extract_name_file(filename) do |line|
        if directory.match(/PhymmBL/)
          if !(phym(line, id_map))
            STDERR.puts "ERROR reading #{filename}"          
            exit 1
          end
        end
        if directory.match(/Metaphyler/)
          if !(met(line, id_map))
            STDERR.puts "ERROR reading #{filename}"          
            exit 1
          end
        end
        if directory.match(/PhyloPythia/)
          if !(phyl(line, id_map))
            STDERR.puts "ERROR reading #{filename}"          
            exit 1
          end
        end
      end
    end
  end
  return true
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
    #where does it close?
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

def output_id_map(query_id, database_id, matching_map, db_ids)
  if @prev_query_id.nil?   #first time functioncall
    @prev_query_id = query_id
    db_ids.push(database_id)  #
    
  elsif @prev_query_id == query_id
    db_ids.push(database_id)
    
  elsif @prev_query_id != query_id
    matching_map[@prev_query_id]= db_ids.flatten
    @prev_query_id = query_id
    db_ids.clear
    if !db_ids.empty?
      puts "could not delete #{db_ids}"
    end
    db_ids.push(database_id)
  end
  
  
end

def output_parse(line, output_map, db_ids)
  s = line.split("\t") 
  query_id = s[0]
  if query_id.nil?
    STDERR.puts "No id found"
    exit 1
  end
  database_id = s[1]
  if database_id.nil?
    STDERR.puts "No name found"
    exit 1
  end 
  output_id_map(query_id, database_id, output_map, db_ids)
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

def phym(line, id_map)
  s = line.split("\t")
  id = s[0]
  name = s[1].gsub(/_/," ")
  identifier_map(id, name, id_map)
  return true
end

#dataset-parser PhyloPythia

def phyl(line, id_map) 
  s = line.split("\t")
  id = s[3]
  name = s[11]
  identifier_map(id, name, id_map)
  
  return true
end

#dataset-parser Metaphyler

def met(line, id_map)
  s = line.split("\t")
  id = s[0]
  if s[3].match(/genus/)
    name = s[2]
  end 
  identifier_map(id, name, id_map)
  return true
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

output_map = Hash.new
db_ids = Array.new

@prev_query_id=nil 
db_map = Hash.new
id_map = Hash.new
arr = parseargs(ARGV)


arr.each do |testsetname|
  enum_fasta_files_in_subtree(testsetname) do |filename|
    stop_read_all_fasta = false
    extract_fasta_header(filename) do |header|
      if header.match(/^>>gi\|/)
        raiphy(header, id_map)
      elsif header.match(/\|SOURCES=\{GI=/)
        carma_facs(header, id_map)
      elsif header.match(/(CHROMAT_FILE)|(^>(\w{3}\d+\.\d+)|(\w+\_(\d+|\w+)\_\d+))/)
        if !(open_name_file(testsetname, id_map))
          #already stopped? ueberflüssig?
          STDERR.puts "ERROR opening name file for #{testsetname}"
          exit 1
        else
          stop_read_all_fasta=true
          break #stopps reading all headers in fasta-file
        end       
      elsif header.match(/^>sp\|\S+/)
        swiss_prot(header, db_map)
      elsif header.match(/\>gi\|\d+\|\w+\|\w+\.\w\|\s\w+\|\w+/)
        output_parse(header, output_map, db_ids)
      else
        STDERR.puts "Unknown format in dataset."
        exit 1
      end 
    end 
    if stop_read_all_fasta
      break
    end
  end
end


  id_map.each {|key,value|   
               puts "#{key}\t#{value}"}
  db_map.each {|key,value|   
               puts "#{key}\t#{value}"}
  output_map.each {|key,value|   
               puts "#{key}\t#{value}"}
  
 

