require 'eventmachine'
require 'em-http'
require 'base64'
module Rack
  module Smaw
  
    class Base
    
      def initialize(app,mpkey,&block)
        @app = app
        Sender.mixpanel_key = mpkey
        @sender = Sender.new
        @sender.parser = block
      end

      def call(env)
        @sender.env = env
        @sender.run
        @app.call(env)
      end
      
    end

    class Sender 
      attr_accessor :env, :parser

      def self.mixpanel_key=(key)
        @mixpanel_key = key
      end

      def self.mixpanel_key
        @mixpanel_key
      end

      def self.basics(req)
        { "ip" => req.ip, "token" => mixpanel_key, "time" => ::Time.now.to_i} 
      end

      def run
          http = EventMachine::HttpRequest.
          new('http://api.mixpanel.com/track').
          get(:query => {
                :ip => 0,
                :data => ::Base64.encode64(parser.call(env).to_json)
              })
          http.errback { }
          http.callback { }
      end
      

    end

  end
end
