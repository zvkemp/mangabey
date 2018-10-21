module Mangabey
  class Client
    def initialize(token, opts = {})
      @oauth_token = Mangabey.oauth_access_token(token, opts)
    end

    attr_reader :oauth_token

    def surveys
      wrap_resource(Survey)
    end

    def survey(id)
      oauth_token.get(Mangabey.api_root.join('surveys', id.to_s).to_s)
    end

    def survey_details(id)
      oauth_token.get(Mangabey.api_root.join('surveys', id.to_s, 'details').to_s)
    end

    def wrap_resource(resource)
      ClientResource.new(self, resource)
    end

    def get(url, *args)
      Mangabey::LOGGER.debug("[GET] #{url.to_s}")
      oauth_token.get(url.to_s, *args).tap do |resp|
        raise Error.new unless resp.status == 200
      end
    end
  end
end
