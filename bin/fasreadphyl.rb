#!/usr/bin/env ruby

USAGE = "ruby #{$0} dataset_path output"

if ARGV.length != 2
  puts USAGE
else
  dat  = ARGV[0].to_s
  output= ARGV[1].to_s

  @names=Array.new
  @n=0

    datei = File.open(dat, "r")
    input= datei.readlines
    datei.close
      input.each do |i|
	if !i.match (/^#/)
	  i= i.split("\t")	
	  name="#{i[10]} #{i[11]}"
	  name=name.split()
	  name="#{name[0]} #{name[1]}"
	  if !@names.include? name
	    @names[@n]= name
	    @n= @n+1
	  end
	end
      end
    

  fout = File.open(output, "w")
  fout.puts dat
  fout.write("\n")
  fout.puts @names.sort
  fout.close
end