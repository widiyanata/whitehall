module Whitehall::Uploader::Finders::FindersHelper
  def people_from_slugs(slugs, logger, line_number)
    slugs.map do |slug|
      person = Person.find_by_slug(slug)
      logger.error "Unable to find Person with slug '#{slug}'", line_number unless person
      person
    end.compact
  end
end
