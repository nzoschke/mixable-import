module Endpoints
  class Playlists < Base
    namespace "/playlists" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        encode serialize(Playlist.all)
      end

      post do
        # warning: not safe
        playlist = Playlist.new(body_params)
        playlist.save
        status 201
        encode serialize(playlist)
      end

      get "/:id" do |id|
        playlist = Playlist.first(uuid: id) || halt(404)
        encode serialize(playlist)
      end

      patch "/:id" do |id|
        playlist = Playlist.first(uuid: id) || halt(404)
        # warning: not safe
        #playlist.update(body_params)
        encode serialize(playlist)
      end

      delete "/:id" do |id|
        playlist = Playlist.first(uuid: id) || halt(404)
        playlist.destroy
        encode serialize(playlist)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Playlist.new(structure).serialize(data)
      end
    end
  end
end
