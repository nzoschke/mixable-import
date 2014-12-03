require "spec_helper"

describe Endpoints::Imports do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./docs/schema.json"
  end

  before do
    @user = User.create(rdio_playlists: Sequel.pg_json({
      "collab"      => [],
      "subscribed"  => [],
      "favorites"   => [],
      "owned"       => [{ "name"=>"April Fools!", "tracks"=>[ {"album"=>"The Bends (Collector's Edition)", "isrcs"=>["GBAYE9400673"], "name"=>"The Trickster", "artist"=>"Radiohead", "key"=>"t2062973", "duration"=>282}, ], "length"=>1, "key"=>"p8763814" }]
    }))

    @track = Track.create(rdio_key: "t2062973")

    @env = { "rack.session" => { "uuid" => @user.uuid } }
  end

  describe 'GET /imports' do
    it 'returns correct status code and conforms to schema' do
      get '/imports', {}, @env
      assert_equal 200, last_response.status
      #assert_schema_conform
    end
  end

  describe 'POST /imports' do
    it 'returns correct status code and conforms to schema' do
      expect(SpotifyImportWorker).to receive(:perform_async) {}

      header "Content-Type", "application/json"
      post '/imports', MultiJson.encode({}), @env
      assert_equal 201, last_response.status
      #assert_schema_conform
    end
  end

  describe 'GET /imports/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/imports/123", {}, @env
      assert_equal 403, last_response.status
      #assert_schema_conform
    end
  end

  describe 'PATCH /imports/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      patch '/imports/123', MultiJson.encode({}), @env
      assert_equal 403, last_response.status
      #assert_schema_conform
    end
  end

  describe 'DELETE /imports/:id' do
    it 'returns correct status code and conforms to schema' do
      delete '/imports/123', {}, @env
      assert_equal 403, last_response.status
      #assert_schema_conform
    end
  end
end
