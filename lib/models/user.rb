class User < Sequel::Model
  plugin :timestamps

  def save_playlists
    client = User.rdio_client({ "token" => self.token, "secret" => self.secret })
    r = client.post('http://api.rdio.com/1/',
      method: 'getPlaylists',
      extras: '[{ "field": "tracks", "extras": [{ "field": "*", "exclude": true }, {"field": "album"}, {"field": "artist"}, {"field": "duration"}, {"field": "isrcs"}, {"field": "key"}, {"field": "name"}] }]'
    )

    r = JSON.parse(r.body)['result']
    update(playlists: Sequel.pg_json(r))
  end

  def self.rdio_client(creds)
    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuth::AccessToken.new(consumer, creds['token'], creds['secret'])
  end

  def self.find_or_create_by_credentials(creds)
    client = self.rdio_client(creds)
    r = JSON.parse(client.post('http://api.rdio.com/1/',
      method: 'currentUser'
    ).body)['result']

    user = User[key: r['key']] || User.create(key: r['key'], url: r['url'])
    user.update(token: creds['token'], secret: creds['secret'])
    user
  end
end
