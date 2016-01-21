#!/usr/bin/ruby

begin
  text = File.open(ARGV[0],"r")
rescue => err
  STDERR.puts "Cannot open file #{ARGV[0]}."
  exit 1
end

text.each_line do |line|
  if ARGV[0].match(/Carma/)
    #Carma
    if line.match(/^>/)
      read = line.match(/^>(r\d+\.\d)/)
      if read.nil?
        STDERR.puts "No id found"
        exit 1
      end 
      id = line.match(/(GI=\d+)/)
      if id.nil?
        STDERR.puts "No id found"
        exit 1
      end 
      gi_id = id[0].split(/=/)
      puts "#{read[1]}\t#{gi_id[0]}_#{gi_id[1]}\n"
    end
  elsif ARGV[0].match(/FACS/) 
    #FACS
    if line.match(/^>/)
      read = line.match(/^>(r\d+\.\d)/)
      if read.nil?
        STDERR.puts "No id found"
        exit 1
      end 
      id = line.match(/(GI=\d+)/)
      if id.nil?
        STDERR.puts "No id found"
        exit 1
      end 
      gi_id = id[0].split(/=/)
      puts "#{read[1]}\t#{gi_id[0]}_#{gi_id[1]}\n"
    end
  elsif ARGV[0].match(/RAIphy/)
    #RAIphy
    if line.match(/^>/)
      read = line.match(/^>(r\d+)/)
      if read.nil?
        STDERR.puts "No id found"
        exit 1
      end
      s = line.split("|")
      id = s[1]
      puts "#{read[1]}\tGI_#{id}"
    end
  elsif ARGV[0].match(/PhymmBL/)
    #PhymmBL
    if line.match(/^>/)
      read = line.match(/^>(r\d+)/)
      if read.nil?
        STDERR.puts "No id found"
        exit 1
      end
      s = line.split(" ")
      id = s[1]
      puts "#{read[1]}\t#{id}"
    end
  end
end
    
