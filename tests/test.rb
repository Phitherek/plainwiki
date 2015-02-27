require_relative '../lib/parser'
require 'byebug'

wt = File.read("testwt")
puts PlainWiki::Parser.parse(wt)
