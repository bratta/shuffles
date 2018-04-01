require "shuffles/version"

Bundler.setup

require 'pry'
require 'sycl'
require 'rspotify'

require "shuffles/exceptions"
require "shuffles/spotify"
require "shuffles/track_data"

# https://gist.github.com/bratta/1567bf53c9f680a82ea99725d2150c89

module Shuffles
  class Optimizer
    attr_accessor :config, :spotify

    def initialize(config)
      @config = config
      @spotify = Shuffles::Spotify.new(@config)
    end

    def optimize
      tracks = @spotify.tracks
      binding.pry
    end
  end
end
