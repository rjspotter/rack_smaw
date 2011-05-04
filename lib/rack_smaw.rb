require 'patron'
require 'base64'
module Rack
  module Smaw
  
    class Base
    
      def initialize(app,mpkey,&block)
        @app = app
        Sender.mixpanel_key = mpkey
        @sender = Sender.new
        @sender.parser = block
        @sender.client = Patron::Session.new
        @sender.client.timeout = 10
        @sender.client.base_url = 'http://api.mixpanel.com'
      end

      def call(env)
        @sender.env = env
        @sender.run
        @app.call(env)
      end
      
    end

    class Sender 
      attr_accessor :env, :parser, :client

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
        begin
        client.get("/track/?data=#{::Base64.encode64(parser.call(env).to_json).gsub(/\s/,'')}&ip=0")
        rescue
          #swallow errors (should error log here)
        end
      end
      

    end

  end
end
