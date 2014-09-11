module Whitehall::Uploader::Finders
  class MinisterialRolesFinder
    extend FindersHelper

    def self.find(date, *slugs, logger, line_number)
      slugs = slugs.reject { |slug| slug.blank? }

      people = people_from_slugs(slugs, logger, line_number)

      people.map do |person|
        ministerial_roles = person.ministerial_roles_at(date)
        logger.error "Unable to find a Role for '#{person.slug}' at '#{date}'", line_number if ministerial_roles.empty?
        ministerial_roles
      end.flatten
    end
  end
end
