require "spec_helper"

describe User do
  before do
    @credentials = { "token" => ENV['RDIO_USER_TOKEN'], "secret" => ENV['RDIO_USER_SECRET'] }
  end

  it "creates a new user by Rdio OAuth credentials" do
    assert !User[key: "s3385"]

    u = User.find_or_create_by_credentials @credentials

    assert u.uuid
    assert_equal "s3385", u.key
    assert_equal "/people/nzoschke/", u.url
    assert_equal ENV['RDIO_USER_TOKEN'], u.token
    assert_equal ENV['RDIO_USER_SECRET'], u.secret
  end

  it "finds an existing user by Rdio OAuth credentials" do
    u1 = User.find_or_create_by_credentials @credentials
    u2 = User.find_or_create_by_credentials @credentials
    assert_equal u1.uuid, u2.uuid
  end
end
