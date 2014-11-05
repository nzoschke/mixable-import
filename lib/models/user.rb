class User < Sequel::Model
  plugin :timestamps

  def save_playlists!
    client = User.rdio_client({ "token" => self.token, "secret" => self.secret })
    r = client.post('http://api.rdio.com/1/',
      method: 'getPlaylists',
      extras: '[{ "field": "tracks", "extras": [{ "field": "*", "exclude": true }, {"field": "album"}, {"field": "artist"}, {"field": "duration"}, {"field": "isrcs"}, {"field": "key"}, {"field": "name"}] }]'
    )

    r = JSON.parse(r.body)['result']
    update(playlists: Sequel.pg_json(r))
  end

  def save_tracks!
    self.playlists.each do |kind, lists|
      lists.each do |list|
        list['tracks'].each do |track|
          # TODO: how to handle no ISRC?
          # TODO: is this the right way to handle multiple ISRCs?
          track['isrcs'].each do |isrc|
            Track.create(
              isrc:     isrc,
              rdio_key: track['key'],
              artist:   track['artist'],
              album:    track['album'],
              name:     track['name'],
              duration: track['duration']
            ).save
          end
        end
      end
    end
  end

  def playlists_isrcs
    isrcs = []
    self.playlists.each do |kind, lists|
      lists.each do |list|
        list['tracks'].each do |track|
          isrcs.push track['isrcs']
        end
      end
    end
    isrcs.flatten
  end

  def self.rdio_client(creds)
    # Authorized Rdio client
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
