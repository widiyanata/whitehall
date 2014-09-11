module Whitehall::Uploader
  module UploaderHelpers
    def world_locations
      Finders::WorldLocationsFinder.find(row['country_1'], row['country_2'], row['country_3'], row['country_4'], @logger, @line_number)
    end

    def related_editions
      Finders::EditionFinder.new(Policy, @logger, @line_number).find(row['policy_1'], row['policy_2'], row['policy_3'], row['policy_4'])
    end
  end
end
