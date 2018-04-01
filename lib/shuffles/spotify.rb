require 'open-uri'

module Shuffles
  class Spotify
    attr_accessor :config, :username, :playlist_id, :user, :playlist

    def initialize(config)
      @config = config
      begin
        RSpotify.authenticate(@config.data.spotify.client_id, @config.data.spotify.client_secret)
      rescue
        raise Shuffle::SpotifyAuthenticationException.new("Cannot authenticate with Spotify. Check your client_id and client_secret and try again.")
      end
      parse_playlist_uri()
      @user = RSpotify::User.find(@username)
      @playlist = get_playlist(@playlist_id)
    end

    def tracks
      {}.tap do |track|
        @playlist.tracks.each do |track_object|
          data = Shuffles::TrackData.new
          data.name = track_object.name
          data.artist = track_object.artists.map(&:name).join(", ")
          data.album = track_object.album.name
          data.length = track_object.duration_ms
          track[track_object.uri] = data
          data.cache_location = download_track_sample(track_object)
        end
      end
    end

    private

    def parse_playlist_uri()
      if match = @config.data.spotify.playlist_uri.match(/^spotify:user:(.+):playlist:(.+)$/i)
        @username, @playlist_id = match.captures
      else
        raise Shuffles::GeneralException.new("Invalid Spotify playlist URI format. Right-click the playlist and choose 'Copy Spotify URI'")
      end
    end

    def get_playlist(playlist_id)
      RSpotify::Playlist.find(@user.id, playlist_id)
    end

    def download_track_sample(track_object)
      filename = File.join(@config.data.cache.directory, "#{track_object.uri.split(':').last}.mp3")
      if !File.exist?(filename) && track_object.preview_url
        File.open(filename, "wb") do |saved_preview|
          open(track_object.preview_url, "rb") do |read_file|
            saved_preview.write(read_file.read)
          end
        end
      end
      filename
    end
  end
end