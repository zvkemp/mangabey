module Mangabey
  module Model
    module HasData
      def method_missing(name, *args, &block)
        return fetch_attribute(name) if data.key?(name.to_s)
        return fetch_attribute(name) if self.class::ATTRIBUTES.include?(name)
        super
      end

      def fetch_attribute(name)
        data.fetch(name.to_s)
      rescue KeyError
        raise if details_loaded?
        load_details!
        retry
      end

      def load_details!
        # no-op
      end

      def details_loaded?
        true
      end
    end
  end
end
