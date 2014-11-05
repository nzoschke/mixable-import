class Track < Sequel::Model
  plugin :timestamps

  def self.rdio_client
    # TODO: Figure out right way to do unauthorized API call
    user = User.first
    creds = { 'token' => user.token, 'secret' => user.secret }

    consumer = OAuth::Consumer.new(ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET'], { site: 'http://api.rdio.com' })
    OAuth::AccessToken.new(consumer, creds['token'], creds['secret'])
  end

  def self.find_or_create_by_isrc(isrc)
    unless track = Track[isrc: isrc]
      client = self.rdio_client
      r = JSON.parse(client.post('http://api.rdio.com/1/',
        method: 'getTracksByISRC',
        isrc:   isrc
      ).body)['result']

      # TODO: is this the right way to handle multiple tracks?
      track = Track.create(
        isrc:     isrc,
        rdio_key: r[0]['key'],
        artist:   r[0]['artist'],
        album:    r[0]['album'],
        name:     r[0]['name'],
        duration: r[0]['duration']
      ).save
    end

    track
  end
end
