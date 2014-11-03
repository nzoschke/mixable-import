class Track < Sequel::Model
  plugin :timestamps

  def rdio_get
    self.isrc = "USRC11301695"
    self.artist = "Pitbull"
    self.album = "Timber"
    self.name = "Timber"
    self.duration = 204
  end
end
