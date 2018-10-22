module Mangabey
  ClientResource = Struct.new(:client, :resource_class, :scope) do
    def all
      resource_class.all(client, scope)
    end

    def find(id)
      resource_class.find(client, id)
    end
  end
end
