class User < Sequel::Model
  plugin :timestamps

  def self.find_or_create_by_credentials(creds)
    rdio_consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    rdio_access_token = OAuth::AccessToken.new(rdio_consumer, creds['token'], creds['secret'])

    r = JSON.parse(rdio_access_token.post('http://api.rdio.com/1/',
      method: 'currentUser'
    ).body)['result']

    user = User[key: r['key']] || User.create(key: r['key'], url: r['url'])
    user.update(token: creds['token'], secret: creds['secret'])
    user
  end
end
