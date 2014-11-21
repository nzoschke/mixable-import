module Endpoints
  class Imports < Base
    namespace "/imports" do
      before do
        halt 401, '{"error": "No OAuth Session"}' unless @user = User[env['rack.session']['uuid']]

        content_type :json, charset: 'utf-8'
      end

      get do
        encode(@user.spotify_imports)
      end

      post do
        halt 403, '{"error": "Import in progress"}' if @user.spotify_import_in_progress?

        ImportWorker.perform_async(@user.uuid)

        status 201
        encode(@user.spotify_imports)
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
