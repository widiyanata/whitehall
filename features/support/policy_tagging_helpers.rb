require 'gds_api/test_helpers/content_register'

module PolicyTaggingHelpers
  include GdsApi::TestHelpers::ContentRegister

  def stub_content_register_with_policies(policies = [])
    @policy_entries = policies.map do |policy_title|
      {
        content_id: SecureRandom.uuid,
        title: policy_title,
        format: "policy",
        base_path: "/government/policies/#{policy_title.parameterize}"
      }
    end

    content_register_has_entries(policy: @policy_entries)
  end

  def select_policies_in_form(policies = [])
    policies.each do |policy_title|
      select policy_title, from: "New policies"
    end
  end

  def assert_policies_were_saved
    assert has_css?('.flash.notice')
    click_on 'Edit draft'
    assert_equal @policy_entries.map {|pe| pe[:content_id] }.to_set,
                 find_field('Additional specialist sectors').value.to_set
  end

  def save_document
    click_button 'Save'
  end
end

World(PolicyTaggingHelpers)
