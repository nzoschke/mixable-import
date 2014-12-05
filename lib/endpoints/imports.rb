module Endpoints
  class Imports < Base
    namespace "/imports" do
      before do
        halt 401, '{"error": "No session"}' unless uuid = env["rack.session"]["uuid"]
        @user = User[uuid]

        content_type :json, charset: "utf-8"
      end

      get "/spotify" do
        l = 1
        l = [10, params["limit"].to_i].min if params["limit"]
        encode serialize(@user.imports_dataset.order(Sequel.desc(:created_at)).limit(l))
      end

      post "/spotify" do
        # warning: not safe
        import = Import.new(body_params)
        import.save
        status 201
        encode serialize(import)
      end

      get "/spotify/:id" do |id|
        import = Import.first(uuid: id) || halt(404)
        encode serialize(import)
      end

      patch "/spotify/:id" do |id|
        import = Import.first(uuid: id) || halt(404)
        # warning: not safe
        #import.update(body_params)
        encode serialize(import)
      end

      delete "/spotify/:id" do |id|
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
