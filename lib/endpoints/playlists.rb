module Endpoints
  class Playlists < Base
    namespace "/playlists" do
      before do
        halt 401, '{"error": "No session"}' unless uuid = env["rack.session"]["uuid"]
        @user = User[uuid]

        content_type :json, charset: "utf-8"
      end

      get "/rdio" do
        encode serialize(@user.rdio_playlists_to_a, :rdio)
      end

      get "/rdio/:id" do |id|
        playlist = @user.rdio_playlists_to_a.detect { |p| p["key"] == id } || halt(404)
        playlist.instance_eval { undef :map }
        encode serialize(playlist, :rdio)
      end

      get "/spotify" do
        if !@user.spotify_playlists
          encode serialize([])
        else
          encode serialize(@user.spotify_playlists["items"])
        end
      end

      get "/spotify/:id" do |id|
        playlist = @user.spotify_playlists["items"].detect { |p| p["id"] == id } || halt(404)
        playlist.instance_eval { undef :map }
        encode serialize(playlist)
      end

      post "/:provider" do |provider|
        halt 403, '{"error": "Forbidden"}'
      end

      patch "/:provider/:id" do |provider, id|
        halt 403, '{"error": "Forbidden"}'
      end

      delete "/:provider/:id" do |provider, id|
        halt 403, '{"error": "Forbidden"}'
      end

      private

      def serialize(data, structure = :default)
        Serializers::Playlist.new(structure).serialize(data)
      end
    end
  end
end
