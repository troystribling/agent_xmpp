##############################################################################################################
require 'test_helper'

##############################################################################################################
class TestApplicationMessageProcessing < Test::Unit::TestCase

  #.........................................................................................................
  def setup
    @config = {'jid' => 'test@nowhere.com', 'contacts' =>['dev@nowhere.com'], 'password' => 'nopass'}
    @client = TestClient.new(@config)
    test_init_roster(@client, @config)
    @delegate = @client.new_delegate
  end

  #.........................................................................................................
  should "respond to a received message with body text reversed" do
    @client.receiving(ApplicationMessages.recv_message(@client, 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_message(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with scalars" do
    @client.receiving(ApplicationMessages.recv_command_execute(@client, 'scalar', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_x_data_scalar_result(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with arrays of scalars" do
    @client.receiving(ApplicationMessages.recv_command_execute(@client, 'scalar_array', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_x_data_scalar_array_result(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with hashes" do
    @client.receiving(ApplicationMessages.recv_command_execute(@client, 'hash', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_x_data_hash_result(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with arrays of hashes" do
    @client.receiving(ApplicationMessages.recv_command_execute(@client, 'hash_array', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_x_data_hash_array_result(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "return error if command node does not map to a route" do
    @client.receiving(ApplicationMessages.recv_command_execute(@client, 'no_route', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_routing_error(@client, 'no_route', 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "return error if command node route does not map to a controller" do
    @client.receiving(ApplicationMessages.recv_command_execute(@client, 'no_action', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_routing_error(@client, 'no_action', 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "return error if command node route does not map to an action" do
    @client.receiving(ApplicationMessages.recv_command_execute(@client, 'no_controller', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_routing_error(@client, 'no_controller', 'dev@nowhere.com'))
  end

end

