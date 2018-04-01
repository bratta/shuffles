require 'tmpdir'
require 'fileutils'

module Shuffles
  class Config
    attr_accessor :config_file, :data
    
    REQUIRED_FIELDS = ['spotify', 'spotify.client_id', 'spotify.client_secret', 'cache.use_tempdir']

    def initialize(config_file)
      self.config_file = File.expand_path(config_file) || File.expand_path('~/.shuffles.yml')
      if !self.config_file || !File.exist?(self.config_file)
        raise Shuffles::FileNotFoundException.new("Missing configuration file: #{self.config_file}")
      end
      self.data = Sycl::load_file self.config_file
      self.validate()
      initialize_cache_directory()
    end

    def validate
      config_usage = "See shuffles.yml.example for more information on configuring this gem."
      raise Shuffles::InvalidConfigException.new("Missing configuration data for #{self.config_file}. #{config_usage}") if !self.data
      errors = []
      REQUIRED_FIELDS.each do |required_field|
        errors.push(required_field) unless deep_key_exists?(required_field)
      end
      if errors.count > 0
        raise Shuffles::InvalidConfigException.new("Missing required configuration elements: #{errors.join(', ')}")
      end
    end

    private

    def self.require_fields(*fields)
      fields.each {|field| @@required_config_fields.push(field)}
    end

    def deep_key_exists?(config_key)
      exists = false
      begin
        exists = self.data.get config_key
      rescue
      end
    end

    def initialize_cache_directory
      if self.data.cache.use_tempdir
        self.data.cache.directory = File.join(Dir.tmpdir(), "shuffles")
      end
      if !self.data.cache.directory
        raise Shuffles::InvalidConfigException.new("Missing configuration data for cache directory.")
      end
      self.data.cache.directory = File.expand_path(self.data.cache.directory)
      if !(Dir.exist?(self.data.cache.directory))
        FileUtils.mkdir_p(self.data.cache.directory)
      end
    end
  end
end
