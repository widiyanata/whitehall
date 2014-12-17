require 'csv'

# eg
# ContentLinksReporter.new("/var/govuk", Regexp.new("\(http[^:]*:\/\/[^\.]*\.hmrc\.gov\.uk[^\) \n]*\)")).report
#
class ContentLinksReporter
  attr_reader :report_dir, :link_regex

  EDITION_TYPES = %w(CaseStudy Consultation CorporateInformationPage DetailedGuide
                     DocumentCollection FatalityNotice NewsArticle Policy Publication
                     Speech StatisticalDataSet SupportingPage WorldLocationNewsArticle
                     WorldwidePriority)

  def initialize(report_dir, link_regex)
    @report_dir = report_dir
    @link_regex = link_regex
  end

  def report
    matching_editions = []
    CSV.open(csv_file_path, "wb") do |csv|
      csv << ["Title", "Format", "Links"]

      EDITION_TYPES.each do |edition_type|
        editions = Edition.published.where(type: edition_type).each do |edition|
          links = edition.body.scan(link_regex)
          unless links.empty?
            links = links.flatten.join(",")
            # This probably doesn't belong here as it's a workaround to the regex commented above
            # which captures markdown parenthesis.
            links.gsub!("(","").gsub!(")","")
            csv << [edition.title, edition.type, links]
            matching_editions << edition.title
          end
        end
      end
    end
    if matching_editions.any?
      puts "#{matching_editions.size} Editions found matching #{link_regex}."
      puts matching_editions.join(",")
    else
      puts "No matches for #{link_regex}"
      FileUtils.rm(csv_file_path)
    end
  end

  def csv_file_path
    File.join(report_dir, "content-links-whitehall-#{Time.zone.now.strftime('%d%m%y-%H%M')}.csv")
  end
end
