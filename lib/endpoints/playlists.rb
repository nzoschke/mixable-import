module Endpoints
  class Playlists < Base
    namespace "/playlists" do
      before do
        halt 401, '{"error": "No OAuth Session"}' unless uuid = env['rack.session']['uuid']
        @user = User[uuid]

        content_type :json, charset: 'utf-8'
      end

      get do
        encode serialize(@user.playlists_to_a, :spotify)
      end

      post do
        halt 403, '{"error": "Forbidden"}'
      end

      get "/:id" do |id|
        playlist = @user.playlists_to_a.detect { |p| p["key"] == id } || halt(404)
        playlist.instance_eval { undef :map }
        encode serialize(playlist, :spotify)
      end

      patch "/:id" do |id|
        halt 403, '{"error": "Forbidden"}'
      end

      delete "/:id" do |id|
        halt 403, '{"error": "Forbidden"}'
      end

      private

      def serialize(data, structure = :default)
        Serializers::Playlist.new(structure).serialize(data)
      end
    end
  end
end
