module Sidekiq::Middleware::Server
  class Logging
    def call(worker, item, queue)
      cls = worker.class.to_s.downcase

      Sidekiq::Logging.with_context("#{worker.class.to_s} JID-#{item['jid']}") do
        begin
          start = Time.now

          # TODO: Can we pass `jid` to the worker function, Pliny REQUEST_ID style?
          Pliny.log(
            jid:      item["jid"],
            "#{cls}"  => true,
            at:       "start",
            queue:    item["queue"],
          )

          yield

          Pliny.log(
            jid:      item["jid"],
            "#{cls}"  => true,
            at:       "finish",
            queue:    item["queue"],
            elapsed:  (Time.now - start).to_f
          )
        rescue Exception
          Pliny.log(
            jid:      item["jid"],
            "#{cls}"  => true,
            at:       "exception",
            queue:    item["queue"],
            elapsed:  (Time.now - start).to_f
          )
          raise
        end
      end
    end
  end
end


class RdioPlaylistsWorker
  include Sidekiq::Worker

  def perform(uuid)
    User[uuid].match_tracks!
  end
end

class SpotifyPlaylistsWorker
  include Sidekiq::Worker

  def perform(uuid)
    User[uuid].save_spotify_playlist_tracks!
  end
end

class ImportWorker
  include Sidekiq::Worker

  def perform(uuid)
    User[uuid].create_spotify_playlists!
  end
end
