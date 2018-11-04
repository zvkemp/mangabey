module Mangabey
  ClientResource = Struct.new(:client, :resource_class, :scope, :query) do
    def all(local_query = {})
      resource_class.all(client, scope: scope, query: merge_query(local_query))
    end

    def find(id)
      resource_class.find(client, id)
    end

    private

    def merge_query(q)
      (query || {}).merge(q)
    end
  end
end
