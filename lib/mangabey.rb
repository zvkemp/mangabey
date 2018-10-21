require "mangabey/version"
require 'oauth2'
require 'pathname'

module Mangabey
  API_ROOT = Pathname.new('/v3')

  class Error < StandardError
  end

  autoload :Client, 'mangabey/client'
  autoload :ClientResource, 'mangabey/client_resource'
  autoload :ClientPage, 'mangabey/client_page'
  autoload :ClientPager, 'mangabey/client_pager'
  autoload :Model, 'mangabey/model'
  autoload :Resource, 'mangabey/resource'

  autoload :Survey, 'mangabey/survey'
  autoload :Question, 'mangabey/question'
  autoload :Response, 'mangabey/response'

  class << self
    def api_root
      API_ROOT
    end

    def oauth_client
      OAuth2::Client.new(
        ENV['MANGABEY_CLIENT_ID'],
        ENV['MANGABEY_CLIENT_SECRET'],
        site: 'https://api.surveymonkey.com/oauth/authorize'
      )
    end

    def oauth_access_token(token = ENV['MANGABEY_ACCESS_TOKEN'], opts = {})
      OAuth2::AccessToken.new(oauth_client, token, opts)
    end
  end
end
