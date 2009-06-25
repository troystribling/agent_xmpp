# =XMPP4R - XMPP Library for Ruby
# License:: Ruby's license (see the LICENSE file) or GNU GPL, at your option.
# Website::http://home.gna.org/xmpp4r/

module Jabber

  class IdGenerator

    @last_id = 0

    class << self

      def generate_id
        @last_id += 1
        timefrac = Time.new.to_f.to_s.split(/\./, 2).last[-3..-1]
        "#{@last_id}#{timefrac}"
      end

    end
    
  end
end
