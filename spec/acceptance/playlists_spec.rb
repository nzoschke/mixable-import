require "spec_helper"

describe Endpoints::Playlists do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./docs/schema.json"
  end

  before do
    @playlist = Playlist.create

    # temporarily touch #updated_at until we can fix prmd
    @playlist.updated_at
    @playlist.save
  end

  describe 'GET /playlists' do
    it 'returns correct status code and conforms to schema' do
      get '/playlists'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

=begin
  describe 'POST /playlists' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/playlists', MultiJson.encode({})
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end
=end

  describe 'GET /playlists/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/playlists/#{@playlist.uuid}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'PATCH /playlists/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      patch "/playlists/#{@playlist.uuid}", MultiJson.encode({})
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'DELETE /playlists/:id' do
    it 'returns correct status code and conforms to schema' do
      delete "/playlists/#{@playlist.uuid}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
