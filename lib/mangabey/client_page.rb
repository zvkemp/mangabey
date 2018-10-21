module Mangabey
  class ClientPage
    attr_reader :response, :resource_class, :client

    def initialize(response, resource_class, client)
      @response = response
      @resource_class = resource_class
      @client = client
    end

    def data
      @data ||= JSON.parse(response.body)
    end

    def elements
      data['data'].map do |elem|
        resource_class.new(from_list: elem, client: client)
      end
    end

    def next_url
      data.dig('links', 'next')
    end
  end
end
