####------------------------------------------------------------------------------------------------------
def_matcher :respond_with do |receiver, matcher, args|
  prepare_msg = lambda{|msg| msg.collect{|i| i.split(/\n/).inject("") {|p, m| p + m.strip}}}
  given = prepare_msg[receiver.stuff_a].join
  expected = prepare_msg[args].join
  matcher.positive_msg = "Expected response message of \"#{expected}\" but was given message \"#{given}\""
  matcher.negative_msg = "Expected response message \"#{expected}\" to not match given message \"#{given}\""
  given.include?(expected)
end

####------------------------------------------------------------------------------------------------------
def_matcher :not_respond do |receiver, matcher, args|
  matcher.positive_msg = "Expected no responce"
  matcher.negative_msg = "Expected a response"
  receiver.nil? || receiver.empty?
end

####------------------------------------------------------------------------------------------------------
def_matcher :be_called do |receiver, matcher, args|
  matcher.positive_msg = "Expected client delgate method '#{receiver.last}' to be called"
  matcher.negative_msg = "Expected client delgate method '#{receiver.last}' to not be called"
  receiver.first
end
