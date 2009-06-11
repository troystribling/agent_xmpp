##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestRosterManagement < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @client = TestClient.new
  end
  
  #.........................................................................................................
  should "query server for roster on succesful session start and activate configured roster items which match those returned in query result" do
  end

  #.........................................................................................................
  should "query server for roster on succesful session start and send a subscription request to configured roster items not returned by query result" do
  end

  #.........................................................................................................
  should "query server for roster on succesful session start and send an unsubscribe request to roster items returned by query result that are not in configured roster" do
  end

  #.........................................................................................................
  should "accept self presence message and do nothing" do
  end

  #.........................................................................................................
  should "make roster item inactive when unavable presence is received" do
  end

  #.........................................................................................................
  should "decline subscription requests which are not in the configured roster" do
  end

  #.........................................................................................................
  should "decline subscription requests which are not in the configured roster" do
  end

end
