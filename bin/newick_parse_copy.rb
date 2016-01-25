#!/usr/bin/env ruby

require 'set'
require 'taxtree'
require 'ostruct'
require 'optparse'

notfound = Set.new

def showtaxonpath(lca,p0,p1,showpath)
  print "#{lca}\t"
  if showpath
    puts p0.join(",") + "\t" + p1.join(",")
  else
    puts "#{p0.length}\t#{p1.length}"
  end
end

def check_options_consistency(options)
  if options.statistics and (options.xmlout or options.newickout or
                             options.tikzout or options.plain)
    opt = Array.new()
    [[options.xmlout,"x"],[options.newickout,"n"],
     [options.tikzout,"t"],[options.rubyout,"r"]].each do |b,c|
      if b
       opt.push(c)
      end
    end
    STDERR.puts "#{$0}: options -s and -" + opt.join("/") +
                " exclude each other"
    exit 1
  end
  if options.showpath and options.lca_from_file.nil?
    STDERR.puts "#{$0}: option --path requires option --lca"
    exit 1
  end
  if options.showpathlength and options.lca_from_file.nil?
    STDERR.puts "#{$0}: option --path-length requires option --lca"
    exit 1
  end
  if options.showpathlength and options.showpath
    STDERR.puts "#{$0}: option --path and --path-length exclude each other"
    exit 1
  end
end

#lst{taxtreeparseargsfirst}
def parseargs(argv)
  options = OpenStruct.new
checkerror() {
if test $? -ne 0
then
  echo "failure: ${cmd}"
  exit 1
else
  echo "okay: ${cmd}"
fi
}

  options.inputfile = nil # last argument
  options.newickout = false
  options.xmlout = false
  options.rubyout = false
  options.tikzout = false
  options.statistics = false
  options.showpath = false
  options.showpathlength = false
  options.subtreename = nil
  options.lca_from_file = nil
  options.find_from_file = nil
  options.all_of_depth = nil
  options.ignore = nil
  options.sample = nil
  opts = OptionParser.new
#lstend#
#lst{taxtreeparseargssecond}
  ind = " " * 37  # indentation for pretty formatting
  opts.banner = "Usage: #{$0} [options] inputfile"
  opts.on("-n","--newick-out","output tree in newick format") do
    options.newickout = true
  end
  opts.on("-x","--xml-out","output tree in XML format") do
    options.xmlout = true
  end
  opts.on("-r","--ruby-out","output tree as Ruby Node-struct\n" +
                            "#{ind}(only for small substrees)") do
    options.rubyout = true
  end
  opts.on("-t","--tikz-out","output tree in tikz format\n" +
                            "#{ind}(should only be used for " +
                            "small subtrees)") do
    options.tikzout = true
  end
  opts.on("-c","--statistics","output statistics\n" +
                              "#{ind}(i.e. counts for different\n" +
                              "#{ind}items) of tree") do
    options.statistics = true
  end
#lstend#
  opts.on("-s","--subtree STRING","output subtree of\n" +
                                  "#{ind}given name") do |x|
    options.subtreename = x
  end
  opts.on("-i","--ignore STRING","ignore taxa matching the given regexp\n") do |x|
    options.ignore = x
  end
#lst{taxtreeparseargsthird}
  opts.on("-f","--find ARRAY","find taxonomic identifiers in\n" +
                               "#{ind}given file") do |x|
    options.find_from_file = x
  end
  opts.on("-a","--all-of-depth NUMBER","output all taxonomic\n" +
                                       "#{ind}identifiers of\n" +
                                       "#{ind}given depth") do |x|
    options.all_of_depth = x.to_i
  end
  opts.on("--sample NUMBER","sample the given number of\n" +
                            "#{ind}taxa") do |x|
    options.sample = x.to_i
  end
  opts.on("-l","--lca STRING","compute lowest common ancestors\n" +
               "#{ind}for pairs of taxonomic units specified\n" +
               "#{ind}in the given file with two taxa per line\n" +
               "#{ind}and separated by a tabulator. The output\n" +
               "#{ind}goes to STDOUT. In each line, the third\n" +
               "#{ind}column containing the LCA of the two\n" +
               "#{ind}taxa is added") do |x|
    options.lca_from_file = x
  end
#lstend#
  opts.on("-p","--path","output paths from taxa to LCA\n" +
                        "#{ind}(when option --lca is used). The paths\n" +
                        "#{ind}for the first and second taxon is shown\n" +
                        "#{ind}comma-separated in column 4 and 5") do
    options.showpath = true
  end
  opts.on("--path-length","output length of paths from taxa to LCA\n" +
                          "#{ind}(when option --lca is used). The length\n" +
                          "#{ind}of the paths are shown in column 4 and 5") do
    options.showpathlength = true
  end
#lst{taxtreeparseargsfourth}
  rest = opts.parse(argv)   # perform the parsing according to ppts
  if rest.length == 0
    STDERR.puts "#{$0}: missing inputfile"
    exit 1
  elsif rest.length > 1
    STDERR.puts "#{$0}: only one inputfile possible"
    exit 1
  else # rest is an array of length 1
    options.inputfile = rest[0]
  end
  # the following method is not shown
  check_options_consistency(options)
  return options
end
#lstend#

#lst{taxtreemainfirst}
options = parseargs(ARGV)

taxtree = Taxtree.new(options.inputfile)
if options.statistics
  depth, numbranching, numleaves,
    branch_depth_dist, leaves_depth_dist = taxtree.statistics()
  print "#{options.inputfile} contains tree of depth #{depth} "
  puts "with #{numbranching} branching nodes and #{numleaves} leaves"
  leaves_depth_dist.sort.each do |k, v|
    puts "leaves of depth #{k}=#{v}"
  end
  branch_depth_dist.sort.each do |k, v|
    puts "branch nodes of depth #{k}=#{v}"
  end
#lstend#
  subtree_size = taxtree.subtree_sizes()
  exceptlist = Regexp.new("^unclassified|^uncultured_bacteria")
  subtree_size.each_pair do |name, size|
    depth = taxtree.find_depth(name)
    if size >= 10 and size <= 20 and not name.match(exceptlist) and depth <= 3
      puts "#{name} of depth #{depth} has size #{size}"
    end
  end
end

if options.subtreename.nil?
  if options.newickout
    taxtree.to_newick()
  end
  if options.xmlout
    taxtree.to_xml(STDOUT)
  end
else
  if taxtree.is_valid_id(options.subtreename)
    smallsubtreenode = taxtree.find_node(options.subtreename)
    depth = taxtree.find_depth(options.subtreename)
    
  else
    puts options.subtreename 
   
  end
  if smallsubtreenode.nil?
    STDERR.puts "#{$0}: line #{__LINE__}: expect smallsubtreenode != nil"
    exit 1
  end
  if options.newickout
    taxtree.to_newick_rec(STDOUT,depth,smallsubtreenode,false)
  end
  if options.xmlout
    taxtree.to_xml_rec(STDOUT,depth,smallsubtreenode)
  end
  if options.tikzout
    taxtree.to_tikz(STDOUT,depth,smallsubtreenode)
  end
  if options.rubyout
    taxtree.to_plain(STDOUT,depth,smallsubtreenode)
    puts ""
  end
end

#lst{taxtreemainlcafromfile}
if not options.lca_from_file.nil?
  File.open(options.lca_from_file).each_with_index do |line, ln|
    taxons = line.chomp.split(/\t/)
    if taxons.length < 2
      STDERR.puts "file #{options.lca_from_file}, " +
                  "line #{ln} does not contain " +
                  "two tab separated taxa"
      exit 1
    end
    print "#{taxons[0]}\t#{taxons[1]}\t"
    if not options.showpath and not options.showpathlength
      lca = taxtree.find_lca(taxons[0],taxons[1])
      puts "#{lca}"
    else # output of path or path-length not shown here
#lstend#
      p0, p1 = taxtree.find_lca_paths(taxons[0],taxons[1])
      if p0.empty?
        if p1.empty?
          assert(__LINE__,"taxons[0] == taxons[1]") {taxons[0] == taxons[1]}
          lca = taxons[0]
        else
          lca = p1[0]
        end
      else
        if p1.empty?
          lca = p0[0]
        else
          p00 = p0.shift
          p10 = p1.shift
          assert(__LINE__,"p0[0] = #{p00} == #{p10} = p1[0]") {p00 == p10}
          lca = p00
        end
      end
      showtaxonpath(lca,p0,p1,options.showpath)
    end
  end
end

if not options.find_from_file.nil?
  nameset = Set.new()
  options.find_from_file.split(",").each do |filename|
    found = 0
    missing = 0
    File.open(filename).each_line do |name|
      if options.ignore.nil? or not name.match(/#{options.ignore}/)
        fname = name.chomp
        if m = fname.match(/\s\(strain (.*)\)$/)
          fname.gsub!(/\s\(strain .*\)$/,"")
          m[1].split(/\//).map {|s| s.gsub!(/^\s+|\s+$/,"")}.each do |strain|
            if not strain.nil? and not strain.match(/^\s*$/)
              nameset.add("#{fname}_#{strain}".gsub(/\s/,"_"))
            end
          end
        else
          fname.gsub!(/\s/,"_")
          nameset.add(fname)
        end
      end
    end
    puts "process #{filename}"
    nameset.sort.each do |name|
      if taxtree.search_node(name)
        found += 1
      else
        witness = taxtree.search_name_lcp(name)
        puts "cannot find \"#{name}\", closest=#{witness}"
        missing += 1
      end
    end
    puts "#{filename} found = #{found}"
    puts "#{filename} missing = #{missing}"
    nameset.clear()
  end
end

if not options.all_of_depth.nil?
  taxtree.enum_nodes_of_depth(options.all_of_depth) do |name|
    puts name
  end
end

if not options.sample.nil?
  odd = false
  taxtree.sample_names(options.sample).each do |name|
    print name
    if odd
      puts ""
      odd = false
    else
      print "\t"
      odd = true
    end
  end
end
