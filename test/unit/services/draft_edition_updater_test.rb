require 'test_helper'

class DraftEditionUpdaterTest < ActiveSupport::TestCase

  setup do
    @creator = create(:user)
    @original_creator = Edition::AuditTrail.whodunnit
    Edition::AuditTrail.whodunnit = @creator
  end

  teardown do
    Edition::AuditTrail.whodunnit = @original_creator
  end

  test '#perform! with an unpersisted draft edition assigns attributes and creates the edition' do
    edition = build(:draft_edition)
    attributes = {title: "A draft edition"}
    updater = DraftEditionUpdater.new(edition, attributes: attributes)

    assert updater.perform!
    assert edition.persisted?, edition.errors.full_messages.to_sentence
    assert_equal attributes[:title], edition.title
  end

  test '#perform! with a persisted draft edition assigns attributes and updates the edition' do
    edition = create(:draft_edition)
    attributes = {title: "A draft edition"}
    updater = DraftEditionUpdater.new(edition, attributes: attributes)

    assert updater.perform!
    assert_equal attributes[:title], edition.reload.title
  end

  test "#perform! records new creator if edit succeeds" do
    edition = create(:draft_edition)

    new_user = create(:user)
    Edition::AuditTrail.acting_as(new_user) do
      updater = DraftEditionUpdater.new(edition, attributes: {})

      assert updater.perform!
    end

    assert_equal 2, edition.edition_authors.count
    assert_equal new_user, edition.edition_authors.last.user
  end

  test '#perform! with an invalid edition refuses to update' do
    edition = create(:draft_edition)
    updater = DraftEditionUpdater.new(edition, attributes: {title: nil})

    refute updater.perform!
    assert_equal "This edition is invalid: Title can't be blank", updater.failure_reason
  end

  test "#perform! does not record new creator if edit fails" do
    edition = create(:draft_edition)

    new_user = create(:user)
    Edition::AuditTrail.acting_as(new_user) do
      updater = DraftEditionUpdater.new(edition, attributes: {title: nil})

      refute updater.perform!
    end

    assert_equal 1, edition.edition_authors.count
  end
end
