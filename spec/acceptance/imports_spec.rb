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
    # @import.user = @user

    # temporarily touch #updated_at until we can fix prmd
    @import.updated_at
    @import.save
  end

  describe 'GET /imports' do
    it 'returns correct status code and conforms to schema' do
      get '/imports'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'POST /imports' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/imports', MultiJson.encode({ user_uuid: @user.uuid, updated_at: Time.now })
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end

  describe 'GET /imports/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/imports/#{@import.uuid}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'PATCH /imports/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      patch "/imports/#{@import.uuid}", MultiJson.encode({})
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'DELETE /imports/:id' do
    it 'returns correct status code and conforms to schema' do
      delete "/imports/#{@import.uuid}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
