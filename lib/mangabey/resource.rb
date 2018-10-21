module Mangabey
  class Resource
    include Model::HasData

    def self.all(client)
      Enumerator.new do |yielder|
        page_url = Mangabey::API_ROOT.join(path)
        yield_page(client, yielder, page_url)
      end
    end

    def self.yield_page(client, yielder, page_url)
      loop do
        page = ClientPage.new(client.get(page_url), self, client)
        page.elements.each do |elem|
          yielder << elem
        end

        page_url = page.next_url or return
      end
    end

    attr_reader :data, :client

    def initialize(from_list: {}, from_details: {}, client:)
      @data = from_list.merge(from_details)
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
