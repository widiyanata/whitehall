module Edition::RelatedPolicies
  extend ActiveSupport::Concern

  include Edition::RelatedDocuments

  included do
    has_many :related_policies, through: :related_documents, source: :latest_edition, class_name: 'Policy'
    has_many :published_related_policies, through: :related_documents, source: :published_edition, class_name: 'Policy'

    # HABTM association via the content register
    has_many :edition_policies
  end

  # Ensure that when we set policy ids we don't remove other types of edition from the array
  def related_policy_ids=(policy_ids)
    policy_ids = Array.wrap(policy_ids).reject(&:blank?)
    new_policies = policy_ids.map {|id| Policy.find(id).document }
    other_related_documents = self.related_documents.reject { |document| document.document_type == Policy.name }
    self.related_documents = other_related_documents + new_policies
  end

  def related_policy_ids
    related_documents.
      find_all {|d| d.document_type == Policy.name }.
      map {|d| d.latest_edition.try(:id) }.compact
  end

  def can_be_related_to_policies?
    true
  end

  def policy_ids
    edition_policies.map(&:policy_content_id)
  end

  def policies
    policies_by_content_id = Future::Policy.all.inject({}) do |hash, policy|
      hash.merge(policy.id => policy)
    end

    edition_policies.map do |edition_policy|
      policies_by_content_id[edition_policies]
    end
  end
end
