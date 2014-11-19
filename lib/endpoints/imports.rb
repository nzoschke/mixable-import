module Endpoints
  class Imports < Base
    namespace "/imports" do
      before do
        halt 401, '{"error": "No OAuth Session"}' unless uuid = env['rack.session']['uuid']
        @user = User[uuid]

        content_type :json, charset: 'utf-8'
      end

      get do
        encode(@user.imported_playlists)
      end

      post do
        ImportWorker.perform_async(@user.uuid)

        status 201
        encode({})
      end

      get "/:id" do
        halt 403, '{"error": "Forbidden"}'
      end

      patch "/:id" do |id|
        halt 403, '{"error": "Forbidden"}'
      end

      delete "/:id" do |id|
        halt 403, '{"error": "Forbidden"}'
      end
    end
  end
end
