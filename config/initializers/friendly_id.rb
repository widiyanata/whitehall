FriendlyId.defaults do |config|
  config.base = :name
  config.use :sequentially_slugged, :finders
  config.use Module.new {
    def normalize_friendly_id(input)
      super input.to_s.to_slug.truncate(150).normalize.to_s
    end
  }

  config.sequence_separator = '--'
end
