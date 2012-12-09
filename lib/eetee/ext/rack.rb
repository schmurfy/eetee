
gem 'rack-test', '~> 0.6.2'
require 'rack/test'

module HTTPTest
  def serve_app(app)
    @app = Rack::Test::Session.new(
        Rack::MockSession.new(app)
      )
  end
  
  def request(method, url, opts = {})
    @app.request(url, opts.merge(method: method))
    @app.last_response
  end
  
end

EEtee::Context.__send__(:include, HTTPTest)
