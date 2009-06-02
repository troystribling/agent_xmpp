##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Controller

    #---------------------------------------------------------------------------------------------------------
    attr_reader :format, :params, :connection
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize
    end
 
    #---------------------------------------------------------------------------------------------------------
    # handle request
    #.........................................................................................................
    def handle_request(connection, action, params)
      @params = params
      @connection = connection
      @format = Format.new(params[:xmlns])
      send(action)
    end

    #.........................................................................................................
    def result_for(&blk)
      @result_for_blk = blk
    end

    #.........................................................................................................
    def respond_to(&blk)
      View.send(:define_method, :respond_to, &blk)
      View.send(:define_method, :result_callback) do |*result|
        connection.send(add_payload_to_container(respond_to(result)))
      end
      EventMachine.defer(@result_for_blk, View.new(connection, format, params).method(:result_callback).to_proc)
    end
        
  #### Controller
  end

#### AgentXmpp
end

