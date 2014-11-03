module Endpoints
  class Exports < Base
    namespace "/exports" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        encode [{ id: "01234567-89ab-cdef-0123-456789abcdef", created_at: '2012-01-01T12:00:00Z', updated_at: '2012-01-01T12:00:00Z' }]
      end

      post do
        status 201
        encode({ id: "01234567-89ab-cdef-0123-456789abcdef", created_at: '2012-01-01T12:00:00Z', updated_at: '2012-01-01T12:00:00Z' })
      end

      get "/:id" do
        encode({ id: "01234567-89ab-cdef-0123-456789abcdef", created_at: '2012-01-01T12:00:00Z', updated_at: '2012-01-01T12:00:00Z' })
      end

      patch "/:id" do |id|
        encode({ id: "01234567-89ab-cdef-0123-456789abcdef", created_at: '2012-01-01T12:00:00Z', updated_at: '2012-01-01T12:00:00Z' })
      end

      delete "/:id" do |id|
        encode({ id: "01234567-89ab-cdef-0123-456789abcdef", created_at: '2012-01-01T12:00:00Z', updated_at: '2012-01-01T12:00:00Z' })
      end
    end
  end
end
