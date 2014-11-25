require 'test_helper'
require 'data_hygiene/tag_changes_processor'
require "gds_api/panopticon"
require 'gds_api/test_helpers/panopticon'

class TopicChangesProcessorTest < ActiveSupport::TestCase
  include DataHygiene
  include GdsApi::TestHelpers::Panopticon

  setup do
    @published_edition = create(:published_publication)
    @draft_edition = create(:draft_publication)
    @gds_user = create(:user, email: 'govuk-whitehall@digital.cabinet-office.gov.uk')
  end

  # Replace the `log` method on a TopicTagger with one that appends the logged
  # messages to an array.  Return the array.
  def stub_logging(processor)
    def processor.log(message)
      @logs ||= []
      @logs << message
    end
    def processor.logs
      @logs
    end
  end

  def stub_registration(edition, sectors)
    registerable = RegisterableEdition.new(edition)
    panopticon_request = stub_artefact_registration(
      registerable.slug,
      hash_including(specialist_sectors: sectors),
      true
    )
    Whitehall::SearchIndex.expects(:add).with(edition)
    panopticon_request
  end

  test "#process - processes the csv file containing new and old topics" do
    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @draft_edition)
    create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: @published_edition)
    tag_changes_file =  Rails.root.join('test', 'fixtures', 'data_hygiene', 'tag_changes.csv')

    panopticon_request = stub_registration(@published_edition, ['oil-and-gas/really-far-out'])

    processor = TagChangesProcessor.new(tag_changes_file, 'oil-and-gas/offshore', 'oil-and-gas/really-far-out')

    stub_logging(processor)
    processor.process

    assert_requested panopticon_request
    [@published_edition, @draft_edition].each do |edition|
      edition.reload
      assert edition.editorial_remarks.any?
      assert edition.specialist_sectors.map(&:tag) == ['oil-and-gas/really-far-out']
    end

    # expected_logs = [
    #   %{Updating 2 taggings of editions (1 published) to change oil-and-gas/offshore to oil-and-gas/really-far-out},
    #   %{tagging '#{@draft_edition.title}' edition #{@draft_edition.id}},
    #   %{ - adding editorial remark},
    #   %{tagging '#{@published_edition.title}' edition #{@published_edition.id}},
    #   %{ - adding editorial remark},
    #   %{registering '#{@published_edition.title}'},
    # ]
    # assert processor.logs == expected_logs
  end

end
