require 'tempfile'

class RAMF::FlexObjects::ByteArray < Tempfile
  def initialize(content)
    super("RAMFTemp")
    self.write content
    self.rewind
  end
end