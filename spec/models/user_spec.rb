require "spec_helper"

describe User do
  before do
    @credentials = { "token" => ENV['RDIO_USER_TOKEN'], "secret" => ENV['RDIO_USER_SECRET'] }
    @user = User.find_or_create_by_credentials @credentials
  end

  it "creates a new user by Rdio OAuth credentials" do
    @user.delete

    u = User.find_or_create_by_credentials @credentials

    assert u.uuid
    assert_equal "s3385", u.key
    assert_equal "/people/nzoschke/", u.url
    assert_equal ENV['RDIO_USER_TOKEN'], u.token
    assert_equal ENV['RDIO_USER_SECRET'], u.secret
  end

  it "finds an existing user by Rdio OAuth credentials" do
    u2 = User.find_or_create_by_credentials @credentials
    assert_equal @user.uuid, u2.uuid
  end

  it "saves a JSON snapshot of Rdio playlists" do
    @user.save_playlists
    assert_equal "April Fools!", @user.playlists["owned"][0]["name"]

    # TODO: How to query into the JSON?!
    # User.db["SELECT * FROM users WHERE 'April Fools!' IN (SELECT value->>'name' FROM json_array_elements(playlists))"].all.inspect
    # Sequel::DatabaseError:
    #   PG::InvalidParameterValue: ERROR:  cannot call json_array_elements on a non-array
  end
end
