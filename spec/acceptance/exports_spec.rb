require "spec_helper"

describe Endpoints::Exports do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  def schema_path
    "./docs/schema.json"
  end

  before do
    e = Export.create(rdio_username: "nzoschke", state: "pending").save
    @uuid = e.uuid
  end

  describe 'GET /exports' do
    it 'returns correct status code and conforms to schema' do
      get '/exports'
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'POST /exports' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      post '/exports', MultiJson.encode({})
      assert_equal 201, last_response.status
      assert_schema_conform
    end
  end

  describe 'GET /exports/:id' do
    it 'returns correct status code and conforms to schema' do
      get "/exports/#{@uuid}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'PATCH /exports/:id' do
    it 'returns correct status code and conforms to schema' do
      header "Content-Type", "application/json"
      patch "/exports/#{@uuid}", MultiJson.encode({})
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end

  describe 'DELETE /exports/:id' do
    it 'returns correct status code and conforms to schema' do
      delete "/exports/#{@uuid}"
      assert_equal 200, last_response.status
      assert_schema_conform
    end
  end
end
