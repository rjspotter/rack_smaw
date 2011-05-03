require 'wrest'
require 'base64'
require 'simple_worker'
module Rack
  module Smaw
  
    class Base
    
      def initialize(app,swkey,swsecret,mpkey,&block)
        @app = app
        Sender.mixpanel_key = mpkey
        SimpleWorker.configure do |config|
          config.access_key = swkey
          config.secret_key = swsecret
        end
        @sender = Sender.new
        @sender.parser = block
      end

      def call(env)
        @sender.env = env
        @sender.queue
        @app.call(env)
      end
      
    end

    class Sender  < SimpleWorker::Base
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
        puts data = parser.call(env)
        'http://api.mixpanel.com/track'.to_uri.get({
                                                     :ip => 0,
                                                     :data => ::Base64.encode64(data.to_json)
                                                   })
      end
      

    end

  end
end
