# =XMPP4R - XMPP Library for Ruby
# License:: Ruby's license (see the LICENSE file) or GNU GPL, at your option.
# Website::http://home.gna.org/xmpp4r/

begin
  require 'base64'
rescue LoadError
  ##
  # Ruby 1.9 has dropped the Base64 module,
  # this is a replacement
  #
  module Base64

    def self.encode64(data)
      [data].pack('m')
    end

    def self.decode64(data64)
      data64.unpack('m').first
    end
  end
end
