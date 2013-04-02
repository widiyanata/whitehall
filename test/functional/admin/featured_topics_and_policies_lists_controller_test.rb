require 'test_helper'

class Admin::FeaturedTopicsAndPoliciesListsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  test "GET show fetches the featured topics and policies list for the supplied org" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    get :show, organisation_id: org

    assert_equal featured_topics_and_policies_list, assigns(:featured_topics_and_policies_list)
  end

  test "GET show fetches an unsaved featured topics and policies list for the supplied org if it doesn't already have one" do
    org = create(:organisation)

    get :show, organisation_id: org

    list = assigns(:featured_topics_and_policies_list)
    assert list
    assert_equal org, list.organisation
    refute list.persisted?
  end

  test 'GET show will add an unsaved featured_item of the Topic type to the featured topics and policies list' do
    org = create(:organisation)

    get :show, organisation_id: org
    list = assigns(:featured_topics_and_policies_list)
    items = list.featured_items
    assert_equal 1, items.size
    refute items.first.persisted?
    assert_equal 'Topic', items.first.item_type
  end

  test "PUT update will save the supplied changes to the featured topics and policies list for the supplied org" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: 'Wooo' }

    assert_equal 'Wooo', featured_topics_and_policies_list.reload.summary
  end

  test "PUT update will create a featured topics and policies list for the supplied org if it doesn't already have one" do
    org = create(:organisation)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: 'Wooo' }

    list = assigns(:featured_topics_and_policies_list)
    assert list
    assert_equal org, list.organisation
    assert list.persisted?
    assert_equal 'Wooo', list.summary
  end

  test "PUT update will save featured items, using item_type to choose between topic_id and document_id params" do
    org = create(:organisation)
    t = create(:topic)
    p = create(:policy, :with_document)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: {
      featured_items_attributes: {
        :"0" => {
          item_type: 'Topic',
          topic_id: t.id.to_s,
          document_id: p.document.id.to_s,
          ordering: '1'
        },
        :"1" => {
          item_type: 'Document',
          topic_id: t.id.to_s,
          document_id: p.document.id.to_s,
          ordering: '2'
        }
      }
    }

    list = assigns(:featured_topics_and_policies_list)
    items = list.featured_items
    featured_topic = items.detect { |i| i.ordering == 1 }
    assert_equal t, featured_topic.item
    assert featured_topic.persisted?

    featured_policy = items.detect { |i| i.ordering == 2 }
    assert_equal p.document, featured_policy.item
    assert featured_policy.persisted?
  end

  test "PUT update that fails will render the show template" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: '' }

    assert_template :show
  end
end