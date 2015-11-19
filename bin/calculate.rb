#!/usr/bin/env ruby

path= ARGV[0]

programm_output= ARGV[1]

num_of_seq=0
Dir.foreach(path) do |fas|
  next if fas=='.' or fas=='..'
  dataset = File.open(path+"/"+fas, "r")
  data = dataset.readlines
  dataset.close
  data.each do |i|
    if i.match (/^(>|\s*$|\s*#)/)
      num_of_seq = num_of_seq+1
    end
  end
end
#puts num_of_seq


file = File.open(output, "r")
f = file.readlines
file.close


num_cor_assign=0
num_assign=0
f.each do |i|
  i=i.split("\t")
  num_assign+=1
  if i[2].match("100")
    #org=i[1].split("_")
    #genus = org[1].scan(/.{3}/)
    #puts genus[0]
    #art= org[1].scan(/./)
    #puts art[3]
    num_cor_assign = num_cor_assign+1
  end
end
#puts num_assign
sensitivity = (num_cor_assign.to_f/num_of_seq.to_f)
precision= (num_cor_assign.to_f/num_assign.to_f)
puts precision
printf("sensitivity = #{sensitivity}\n")


