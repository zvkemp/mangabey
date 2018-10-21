module Mangabey
  class Resource
    include Model::HasData

    def self.all(client, scope = nil)
      Mangabey::ClientPager.new(client, self, scope).all
    end

    def self.find(client, id)
      attrs = { 'id' => id.to_s, 'href' => Mangabey::API_ROOT.join(path, id.to_s) }
      new(from_sparse: attrs, client: client)
    end

    attr_reader :data, :client

    def initialize(from_sparse: {}, from_details: {}, client:)
      @data = from_sparse.merge(from_details)
      @details_loaded = !from_details.empty?
      @client = client
    end

    def details_loaded?
      !!@details_loaded
    end

    def load_details!
      body = JSON.parse(client.get(details_url).body)
      @data.merge!(body)
      @details_loaded = true
    end

    def href
      fetch_attribute('href')
    end

    private

    def details_url
      Pathname.new(href).join('details')
    end
  end
end
