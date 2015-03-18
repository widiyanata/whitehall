Given(/^there are some policies in the content register$/) do
  stub_content_register_with_policies([
    "Climate change",
    "Immigration",
  ])
end

Then(/^I can tag it to some policies$/) do
  select_policies_in_form([
    "Climate change",
    "Immigration",
  ])

  save_document

  assert_policies_were_saved([
    "Climate change",
    "Immigration",
  ])
end
