module Mangabey
  class ClientPage
    attr_reader :response, :resource_class, :client

    def initialize(response, resource_class, client)
      @response = response
      @resource_class = resource_class
      @client = client
    end

    def data
      @data ||= JSON.parse(response.body).tap do |parsed|
        log_response(parsed)
      end
    end

    def elements
      data['data'].map do |elem|
        resource_class.new(from_sparse: elem, client: client)
      end
    end

    def next_url
      data.dig('links', 'next')
    end

    private

    def log_response(response)
      Mangabey.logger.debug do
        {
          url: (response['links'] || {})['self'],
          count: response['total'],
          per_page: response['per_page']
        }.to_json
      end
    end
  end
end
