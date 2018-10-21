module Mangabey
  ClientResource = Struct.new(:client, :resource_class) do
    def all
      resource_class.all(client)
    end
  end
end
