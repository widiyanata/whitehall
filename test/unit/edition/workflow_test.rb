require "test_helper"

class Edition::WorkflowTest < ActiveSupport::TestCase
  test "indicates pre-publication status" do
    pre, post = Edition.state_machine.states.map(&:name).partition do |state|
      if state == :deleted
        create(:edition, state)
      else
        build(:edition, state)
      end.pre_publication?
    end

    assert_equal [:imported, :draft, :submitted, :rejected, :scheduled], pre
    assert_equal [:published, :superseded , :deleted, :archived], post
  end

  test "rejecting a submitted edition transitions it into the rejected state" do
    submitted_edition = create(:submitted_edition)
    submitted_edition.reject!
    assert submitted_edition.rejected?
  end

  [:draft, :scheduled, :published, :superseded, :deleted].each do |state|
    test "should prevent a #{state} edition being rejected" do
      edition = create("#{state}_edition")
      edition.reject! rescue nil
      refute edition.rejected?
    end
  end

  [:draft, :rejected].each do |state|
    test "submitting a #{state} edition transitions it into the submitted state" do
      edition = create("#{state}_edition")
      edition.submit!
      assert edition.submitted?
    end
  end

  [:scheduled, :published, :superseded, :deleted].each do |state|
    test "should prevent a #{state} edition being submitted" do
      edition = create("#{state}_edition")
      edition.submit! rescue nil
      refute edition.submitted?
    end
  end

  [:draft, :submitted, :scheduled, :rejected, :deleted].each do |state|
    test "should prevent a #{state} edition being superseded" do
      edition = create("#{state}_edition")
      edition.supersede! rescue nil
      refute edition.superseded?
    end
  end

  test "should not find deleted editions by default" do
    edition = create(:deleted_edition)
    assert_nil Edition.find_by(id: edition.id)
  end

  [:draft, :submitted, :rejected].each do |state|
    test "should be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      assert edition.valid?
    end
  end

  [:scheduled, :published, :superseded, :deleted].each do |state|
    test "should not be editable when #{state}" do
      edition = create("#{state}_edition")
      edition.title = "new-title"
      edition.body = "new-body"
      refute edition.valid?
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:title]
      assert_equal ["cannot be modified when edition is in the #{state} state"], edition.errors[:body]
    end
  end

  test "should be able to change major_change_published_at and first_published_at when scheduled" do
    edition = create(:edition, :scheduled)
    edition.first_published_at = Time.zone.now
    edition.major_change_published_at = Time.zone.now
    assert edition.valid?
  end

  test "#edit_as updates the edition" do
    attributes = stub(:attributes)
    edition = create(:policy)
    edition.edit_as(create(:user), title: 'new-title')
    assert_equal 'new-title', edition.reload.title
  end

  test "#edit_as records new creator if edit succeeds" do
    edition = create(:policy)
    edition.stubs(:save).returns(true)
    user = create(:user)
    edition.edit_as(user, {})
    assert_equal 2, edition.edition_authors.count
    assert_equal user, edition.edition_authors.last.user
  end

  test "#edit_as returns true if edit succeeds" do
    edition = create(:policy)
    edition.stubs(:valid?).returns(true)
    assert edition.edit_as(create(:user), {})
  end

  test "#edit_as does not record new creator if edit fails" do
    edition = create(:policy)
    edition.stubs(:valid?).returns(false)
    user = create(:user)
    edition.edit_as(user, {})
    assert_equal 1, edition.edition_authors.count
  end

  test "#edit_as returns false if edit fails" do
    edition = create(:policy)
    edition.stubs(:valid?).returns(false)
    refute edition.edit_as(create(:user), {})
  end

end
