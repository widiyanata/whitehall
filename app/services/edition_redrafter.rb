class EditionRedrafter < EditionService
  attr_reader :edition, :options, :notifier, :new_draft, :creator

  def initialize(edition, options={})
    @edition = edition
    @notifier = options.delete(:notifier)
    @options = options
    @creator = options[:creator]
  end

  def execute!
    @new_draft = edition.class.new(draft_attributes).tap do |draft|
      edition.traits.each { |t| t.process_associations_before_save(draft) }
      if draft.valid? || !draft.errors.keys.include?(:base)
        if draft.save(validate: false)
          edition.traits.each { |t| t.process_associations_after_save(draft) }
        end
      end
    end
  end

private
  def draft_attributes
    edition.attributes.except(*excluded_attributes).merge('state' => 'draft', 'creator' => creator)
  end

  def excluded_attributes
    %w{
      id
      type
      state
      created_at
      updated_at
      change_note
      minor_change
      force_published
      scheduled_publication
    }
  end

  def failure_reason
    unless edition.published?
      raise "Cannot create new edition based on edition in the #{edition.state} state"
    end
    nil
  end
end
