module Mangabey
  ClientPager = Struct.new(:client, :resource_class, :scope) do
    def all
      Enumerator.new do |yielder|
        page_url = Mangabey::API_ROOT.join(*[scope, resource_class.path].compact)
        yield_page(client, yielder, page_url)
      end
    end

    def yield_page(client, yielder, page_url)
      loop do
        page = ClientPage.new(client.get(page_url), resource_class, client)
        page.elements.each do |elem|
          yielder << elem
        end

        page_url = page.next_url or return
      end
    end
  end
end
