#####-------------------------------------------------------------------------------------------------------
RSpec::Matchers.define :be_called do
  match do |return_val|
    return_val.first
  end
  failure_message_for_should do |return_val|
    "Expected '#{return_val.last}' to have been called"
  end
  failure_message_for_should_not do |return_val|
    "Expected '#{return_val.last}' to not have been called"
  end
end

#####-------------------------------------------------------------------------------------------------------
RSpec::Matchers.define :respond_with do |expected_response|
  prepare_msg = lambda{|msg| msg.collect{|i| i.split(/\n+/).inject("") {|p, m| p + m.strip.gsub(/id='\d+'/, '').gsub(/\s+/, " ")}}}
  expected = prepare_msg[[expected_response].flatten].join
  match do |response|
    given = prepare_msg[[response].flatten].join
    given.include?(expected)
  end
  failure_message_for_should do |response|
    "Expected response message to include '#{expected}' but was given message '#{prepare_msg[[response].flatten].join}'"
  end
  failure_message_for_should_not do |response|
    "Expected response message '#{expected}' to not include given message '#{prepare_msg[[response].flatten].join}'"
  end
end