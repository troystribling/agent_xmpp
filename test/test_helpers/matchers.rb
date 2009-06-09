####------------------------------------------------------------------------------------------------------
def_matcher :respond_with do |receiver, matcher, args|
  prepare_msg = lambda{|msg| msg.split(/\n/).inject("") {|p, m| p + m.strip}}
  given = prepare_msg[receiver.kind_of?(Array) ? receiver.first : receiver]
  expected = prepare_msg[args.first]
  matcher.positive_msg = "Expected response message of \"#{expected}\" but was given message \"#{given}\""
  matcher.negative_msg = "Expected response message \"#{expected}\" to not match given message \"#{given}\""
  given.include?(expected)
end