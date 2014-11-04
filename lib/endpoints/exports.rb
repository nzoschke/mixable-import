module Endpoints
  class Exports < Base
    namespace "/exports" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        encode [{ id: "01234567-89ab-cdef-0123-456789abcdef", created_at: '2012-01-01T12:00:00Z', updated_at: '2012-01-01T12:00:00Z', rdio_username: 'nzoschke', state: 'pending' }]
      end

      post do
        e = Export.create(rdio_username: 'nzoschke', state: 'pending')
        e.save
        status 201
        encode Serializers::Export.new(:default).serialize(e)
      end

      get "/:id" do
        e = Export[params[:id]]
        encode Serializers::Export.new(:default).serialize(e)
      end

      patch "/:id" do |id|
        e = Export[params[:id]]
        encode Serializers::Export.new(:default).serialize(e)
      end

      delete "/:id" do |id|
        e = Export[params[:id]]
        e.delete
        encode Serializers::Export.new(:default).serialize(e)
      end
    end
  end
end
