# Abstract base class for edition services which perform a state transition of
# an edition
class EditionStateTransitionService < EditionService

  def can_transition?
    edition.public_send("can_#{verb}?")
  end

  def verb
    raise NotImplementedError.new("You must implement verb method.")
  end

  def past_participle
    "#{verb}ed".humanize.downcase
  end

private
  def execute!
    fire_transition!
  end

  def fire_transition!
    edition.public_send("#{verb}!")
  end

end