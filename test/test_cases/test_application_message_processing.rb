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
    @client.receiving(ApplicationMessages.recv_message_chat(@client, 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_message_chat(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with scalars in jabber:x:data format" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'scalar', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_iq_result_command_x_data_scalar(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with arrays of scalars in jabber:x:data format" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'scalar_array', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_iq_result_command_x_data_scalar_array(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with hashes in jabber:x:data format" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'hash', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_iq_result_command_x_data_hash(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with arrays of hashes in jabber:x:data format" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'array_hash', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_iq_result_command_x_data_array_hash(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with hashes of arrays in jabber:x:data format" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'hash_array', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_iq_result_command_x_data_hash_array(@client, 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "respond to requests with arrays of hashes of arrays in jabber:x:data format" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'array_hash_array', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_iq_result_command_x_data_array_hash_array(@client, 'dev@nowhere.com'))
  end
   
  #.........................................................................................................
  should "return error if command node does not map to a route" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'no_route', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_error_command_routing(@client, 'no_route', 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "return error if command node route does not map to a controller" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'no_action', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_error_command_routing(@client, 'no_action', 'dev@nowhere.com'))
  end
  
  #.........................................................................................................
  should "return error if command node route does not map to an action" do
    @client.receiving(ApplicationMessages.recv_iq_set_command_execute(@client, 'no_controller', 'dev@nowhere.com')).should \
      respond_with(ApplicationMessages.send_error_command_routing(@client, 'no_controller', 'dev@nowhere.com'))
  end

end

