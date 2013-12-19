require 'test_helper'

class EditionRedrafterTest < ActiveSupport::TestCase
  def redraft(published_edition, new_creator = nil)
    EditionRedrafter.new(published_edition, creator: new_creator).perform!
  end

  test "#perform! with a published edition succeeds" do
    published_edition = build(:published_edition)
    redrafter = EditionRedrafter.new(published_edition)

    assert redrafter.perform!
  end

  test "#perform! builds a new draft of the same type" do
    published_edition = build(:published_edition)

    new_draft = EditionRedrafter.new(published_edition).perform!

    assert new_draft.is_a?(published_edition.class)
  end

  test "#perform! builds a new draft which is persisted" do
    published_edition = build(:published_edition)

    new_draft = EditionRedrafter.new(published_edition).perform!

    assert new_draft.persisted?
  end

  test "#perform! records the creator of the new draft" do
    published_edition = build(:published_edition)
    policy_writer = build(:policy_writer)

    new_draft = EditionRedrafter.new(published_edition, creator: policy_writer).perform!

    assert_equal policy_writer, new_draft.creator
  end

  test "#perform! does not copy created_at and updated_at to new draft" do
    published_edition = build(:published_edition)
    Timecop.travel 1.minute.from_now
    new_draft = EditionRedrafter.new(published_edition).perform!

    refute_equal published_edition.created_at, new_draft.created_at
    refute_equal published_edition.updated_at, new_draft.updated_at
  end

  test "#perform! does not copy change note to new draft" do
    published_edition = build(:published_edition, change_note: "change-note")

    new_draft = EditionRedrafter.new(published_edition).perform!

    assert new_draft.change_note.nil?
  end

  test "#perform! does not copy minor change flag to new draft" do
    published_edition = build(:published_edition, minor_change: true)

    new_draft = EditionRedrafter.new(published_edition).perform!

    assert_equal false, new_draft.minor_change
  end

  test "#perform! does not copy force published flag to new draft" do
    published_edition = build(:published_edition, force_published: true)

    new_draft = EditionRedrafter.new(published_edition).perform!

    refute new_draft.force_published
  end

  test "#perform! does not copy scheduled_publication date to new draft" do
    published_edition = build(:published_edition, scheduled_publication: 1.day.from_now)

    new_draft = EditionRedrafter.new(published_edition).perform!

    assert_nil new_draft.scheduled_publication
  end

  test "#perform! copies time of first publication to new draft" do
    published_edition = create(:published_edition, first_published_at: 1.week.ago)
    Timecop.travel 1.hour.from_now
    new_draft = EditionRedrafter.new(published_edition).perform!

    assert_equal published_edition.first_published_at, new_draft.first_published_at
  end

  test "#perform! copies references to topics, organisations, ministerial roles & world locations to the new draft" do
    topic = create(:topic)
    organisation = create(:organisation)
    ministerial_role = create(:ministerial_role)
    country = create(:world_location)

    published_policy = create(:published_policy, topics: [topic], organisations: [organisation], ministerial_roles: [ministerial_role], world_locations: [country])

    new_draft = EditionRedrafter.new(published_policy, creator: create(:policy_writer)).perform!

    assert_equal [topic], new_draft.topics
    assert_equal [organisation], new_draft.organisations
    assert_equal [ministerial_role], new_draft.ministerial_roles
    assert_equal [country], new_draft.world_locations
  end

  test "#perform! copies consultation participation to new draft" do
    consultation_participation = create(:consultation_participation, link_url: "http://link.com")
    published_consultation = create(:published_consultation, consultation_participation: consultation_participation)

    draft_consultation = EditionRedrafter.new(published_consultation, creator: create(:policy_writer)).perform!
    draft_consultation.change_note = 'change-note'

    assert draft_consultation.valid?

    assert new_consultation_participation = draft_consultation.consultation_participation
    refute_equal consultation_participation, new_consultation_participation
    assert_equal consultation_participation.link_url, new_consultation_participation.link_url
  end

  test "#perform! copies related policies to new draft" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    publication = create(:published_publication, related_editions: [policy_1, policy_2])

    new_draft = EditionRedrafter.new(publication, creator: create(:policy_writer)).perform!
    new_draft.change_note = 'change-note'

    assert new_draft.valid?

    assert new_draft.related_policies.include?(policy_1)
    assert new_draft.related_policies.include?(policy_2)
  end

  test "#perform! preserves topic ordering on new draft" do
    topic = create(:topic)
    published_policy = create(:published_policy, topics: [topic])
    association = topic.classification_memberships.where(edition_id: published_policy.id).first
    association.update_attributes(ordering: 31)

    new_draft = EditionRedrafter.new(published_policy, creator: create(:policy_writer)).perform!

    new_association = topic.classification_memberships.where(edition_id: new_draft.id).first
    assert_equal 31, new_association.ordering
  end

  test "#perform! builds a new draft even if original is invalid" do
    published_policy = create(:published_policy)
    published_policy.update_attributes(title: nil)
    refute published_policy.valid?
    new_draft = EditionRedrafter.new(published_policy, creator: create(:policy_writer)).perform!
    assert new_draft.persisted?
  end

  test "#perform! copies translations to new draft" do
    editor = create(:gds_editor)
    spanish_translation_attributes = {
      title: 'spanish-title',
      summary: 'spanish-summary',
      body: 'spanish-body'
    }
    priority = create(:draft_worldwide_priority)
    with_locale(:es) { priority.update_attributes!(spanish_translation_attributes) }
    force_publish(priority)

    assert_equal 2, priority.translations.length

    draft_priority = EditionRedrafter.new(priority, creator: editor).perform!

    assert_equal 2, draft_priority.translations.length
    with_locale(:es) do
      assert_equal 'spanish-title', draft_priority.title
      assert_equal 'spanish-summary', draft_priority.summary
      assert_equal 'spanish-body', draft_priority.body
    end
  end
end
