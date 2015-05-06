module Election
  class PolicyPaperPublisher
    def initialize(policy_paper_ids)
      @policy_paper_ids = policy_paper_ids
    end

    def run!
      @policy_paper_ids.each do |policy_paper_id|
        if policy_paper = Publication.find_by(id: policy_paper_id)
          if policy_paper.published?
            Rails.logger.warn("WARNING: Policy paper ##{policy_paper_id} already published")
          else
            Rails.logger.info("Force publishing policy paper ##{policy_paper_id} as a minor change")
            policy_paper.minor_change = false

            Edition::AuditTrail.acting_as(gds_user) do
              EditionForcePublisher.new(policy_paper).perform!
            end

            policy_paper.update_column(:public_timestamp, 1.day.ago)
          end
        else
          Rails.logger.warn("WARNING: Couldn't find policy paper ##{policy_paper_id}")
        end
      end
    end

  private

    def gds_user
      @gds_user ||= User.find_by(email: "govuk-whitehall@digital.cabinet-office.gov.uk")
    end
  end
end
