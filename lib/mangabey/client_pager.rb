module Mangabey
  ClientPager = Struct.new(:client, :resource_class, :scope, :query) do
    def all
      Enumerator.new do |yielder|
        page_url = Mangabey::API_ROOT.join(*[scope, resource_class.path].compact)
        yield_page(client, yielder, page_url)
      end
    end

    def yield_page(client, yielder, page_url)
      loop do
        page = ClientPage.new(client.get(merge_params(page_url)), resource_class, client)
        page.elements.each do |elem|
          yielder << elem
        end

        page_url = page.next_url or return
      end
    end

    private

    # SurveyMonkey doesn't include the 'title' param in the links, so their provided
    # pagination is quite wrong when using search terms. It's therefore necessary
    # always to merge in the local params
    def merge_params(url)
      url = URI(url.to_s)
      current_params = CGI.parse(url.query || '')
      url.query = URI.encode_www_form(current_params.merge(query || {}))
      url
    end
  end
end
