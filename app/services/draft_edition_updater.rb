class DraftEditionUpdater < EditionService

  def failure_reason
    @failure_reason ||= compute_failure_reason
  end

  def verb
    'update'
  end

  private

  def compute_failure_reason
    prepare_edition
    if !edition.valid?
      "This edition is invalid: #{edition.errors.full_messages.to_sentence}"
    end
  end

  def prepare_edition
    edition.assign_attributes(attributes)
  end

  def fire_transition!
    if edition.save
      edition.edition_authors.create!(user: user)
      edition.recent_edition_openings.where(editor_id: user).delete_all
    end
  end

  def user
    Edition::AuditTrail.whodunnit
  end

  def attributes
    options[:attributes]
  end
end
