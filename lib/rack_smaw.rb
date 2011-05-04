require 'httparty'
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
<<<<<<< HEAD
      attr_accessor :env, :parser, :client
=======

      attr_accessor :env, :parser
>>>>>>> a51768b036b9fde48ab22de70f6050d03d009de9

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
<<<<<<< HEAD
        begin
        client.get("/track/?data=#{::Base64.encode64(parser.call(env).to_json).gsub(/\s/,'')}&ip=0")
        rescue
          #swallow errors (should error log here)
        end
=======
        HTTParty.get('http://api.mixpanel.com/track',{
                             :ip => 0,
                             :data => ::Base64.encode64(parser.call(env).to_json)
                           })
>>>>>>> a51768b036b9fde48ab22de70f6050d03d009de9
      end
      

    end

  end
end
