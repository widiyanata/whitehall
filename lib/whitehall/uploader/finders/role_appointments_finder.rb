module Whitehall::Uploader::Finders
  class RoleAppointmentsFinder
    extend FindersHelper

    def self.find(date, *slugs, logger, line_number)
      slugs = slugs.reject { |slug| slug.blank? }

      people = people_from_slugs(slugs, logger, line_number)

      people.map do |person|
        appointments = person.role_appointments_at(date)
        logger.error "Unable to find an appointment for '#{person.slug}' at '#{date}'", line_number if appointments.empty?
        appointments
      end.flatten
    end
  end
end
