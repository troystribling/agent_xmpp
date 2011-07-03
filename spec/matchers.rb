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
  expected = SpecUtils.prepare_msg([expected_response].flatten).join
  match do |response|
    given = SpecUtils.prepare_msg([response].flatten).join
    given.include?(expected)
  end
  failure_message_for_should do |response|
    "Expected response message to include '#{expected}' but was given message '#{SpecUtils.prepare_msg([response].flatten).join}'"
  end
  failure_message_for_should_not do |response|
    "Expected response message '#{expected}' to not include given message '#{SpecUtils.prepare_msg([response].flatten).join}'"
  end
end