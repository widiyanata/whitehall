Feature: Tagging content to policies
  In order to make my content available to users interested in a related policy
  As a departmental content editor
  I want to be able to tag my content to one or more policy areas or programmes

  Scenario: writer can tag documents with policies
    Given I am a writer
    And there are some policies in the content register
    When I start editing a draft document
    Then I can tag it to some policies
