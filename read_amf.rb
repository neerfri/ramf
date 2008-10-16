#!/usr/bin/env ruby

require 'lib/ramf'
require 'irb'


begin
  f = File.open(ARGV[0], "r")

  amf_object = RAMF::Deserializer::Base.new(f).process

  p amf_object#.messages.first.to_operation
ensure
  f.close
end
