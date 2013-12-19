# Abstract base class for edition services
class EditionService
  attr_reader :edition, :options, :notifier

  def initialize(edition, options={})
    @edition = edition
    @notifier = options.delete(:notifier)
    @options = options
  end

  def perform!
    if can_perform?
      prepare_edition
      result = execute!
      notify!
      result
    end
  end

  def can_perform?
    !failure_reason
  end

  def failure_reason
    raise NotImplementedError.new("You must implement failure method.")
  end

private

  def execute!
    # Noop
  end

  def notify!
    notifier && notifier.publish(verb, edition, options)
  end

  def prepare_edition
    # Noop by default
  end
end
