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
    @user   = User.create
    @import = Import.create(user: @user)

    @import.updated_at
    @import.save

    @env = { "rack.session" => { "uuid" => @user.uuid } }
  end

  context "Spotify" do

    describe 'GET /imports' do
      it 'returns correct status code and conforms to schema' do
        get '/imports/spotify', {}, @env
        assert_equal 200, last_response.status
        assert_schema_conform
      end
    end

    describe 'POST /imports' do
      it 'returns correct status code and conforms to schema' do
        expect(SpotifyImportWorker).to receive(:perform_async) {}

        header "Content-Type", "application/json"
        post '/imports/spotify', MultiJson.encode({ user_uuid: @user.uuid, updated_at: Time.now }), @env
        assert_equal 201, last_response.status
        assert_schema_conform
      end
    end

    describe 'GET /imports/:id' do
      it 'returns correct status code and conforms to schema' do
        get "/imports/spotify/#{@import.uuid}", {}, @env
        assert_equal 200, last_response.status
        assert_schema_conform
      end
    end

    describe 'PATCH /imports/:id' do
      it 'returns correct status code and conforms to schema' do
        header "Content-Type", "application/json"
        patch "/imports/spotify/#{@import.uuid}", MultiJson.encode({}), @env
        assert_equal 403, last_response.status
        assert_schema_conform
      end
    end

    describe 'DELETE /imports/:id' do
      it 'returns correct status code and conforms to schema' do
        delete "/imports/spotify/#{@import.uuid}", {}, @env
        assert_equal 403, last_response.status
        assert_schema_conform
      end
    end
  end
end
