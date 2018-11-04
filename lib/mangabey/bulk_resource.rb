module Mangabey
  class BulkResource
    # wrapper around a resource class (e.g., Response)
    # Provides a mechanism to fully load complex objects in a single query
    # (instead of the paginate/load dance). Must be supported by a /bulk modifier
    # on the SurveyMonkey API.
    attr_reader :resource_class

    def initialize(resource_class)
      @resource_class = resource_class
    end

    def path
      Pathname.new(resource_class.path).join('bulk')
    end

    # details_loaded will be assumed.
    def new(from_sparse: {}, from_details: {}, client:)
      resource_class.new(from_details: from_sparse.merge(from_details), client: client)
    end

    def all(client, scope: nil, query: {})
      Mangabey::ClientPager.new(client, self, scope, query).all
    end

    def method_missing(name, *args, &block)
      resource_class.send(name, *args, &block)
    end

  end
end
