##############################################################################################################
module AgentXmpp
  
  #####-------------------------------------------------------------------------------------------------------
  class Controller

    #---------------------------------------------------------------------------------------------------------
    attr_reader :format, :params, :pipe
    #---------------------------------------------------------------------------------------------------------

    #.........................................................................................................
    def initialize
    end
 
    #---------------------------------------------------------------------------------------------------------
    # handle request
    #.........................................................................................................
    def handle_request(pipe, action, params)
      @params = params
      @pipe = pipe
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
        pipe.send(add_payload_to_container(respond_to(result)).message)
      end
      EventMachine.defer(@result_for_blk, View.new(pipe, format, params).method(:result_callback).to_proc)
    end
        
  #### Controller
  end

#### AgentXmpp
end

