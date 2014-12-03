module Endpoints
  class Imports < Base
    namespace "/imports" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        encode serialize(Import.all)
      end

      post do
        # warning: not safe
        import = Import.new(body_params)
        import.save
        status 201
        encode serialize(import)
      end

      get "/:id" do |id|
        import = Import.first(uuid: id) || halt(404)
        encode serialize(import)
      end

      patch "/:id" do |id|
        import = Import.first(uuid: id) || halt(404)
        # warning: not safe
        #import.update(body_params)
        encode serialize(import)
      end

      delete "/:id" do |id|
        import = Import.first(uuid: id) || halt(404)
        import.destroy
        encode serialize(import)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Import.new(structure).serialize(data)
      end
    end
  end
end
