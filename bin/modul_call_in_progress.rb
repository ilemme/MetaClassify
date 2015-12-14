#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require_relative 'fastaparser2.rb'


  extend Fasta_parser
  hash = Hash.new
  hash = self.mainly(hash)
  hash.each {|k,v|
             puts "#{k}\t#{v}" }
