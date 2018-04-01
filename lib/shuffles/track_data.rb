module Shuffles
  class TrackData
    attr_accessor :name, :artist, :album, :bpm, :fingerprint, :length, :cache_location

    def to_s
      "#{name} by #{@artist} on #{album} (#{get_duration(@length)}) : #{cache_location}"
    end

    private

    def get_duration(duration)
      minutes = duration / (1000 * 60) % 60
      seconds = duration / (1000) % 60
      sprintf("%01d:%02d", minutes, seconds)
    rescue
      ""
    end
  end
end