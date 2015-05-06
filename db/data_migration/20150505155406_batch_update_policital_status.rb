require "csv"

PUBLISHED_AND_PUBLISHABLE_STATES = %w(published draft archived submitted rejected scheduled)

csv_file = File.join(File.dirname(__FILE__), "20150505155406_batch_update_policital_status.csv")
csv = CSV.parse(File.open(csv_file), headers: true)

csv.each do |row|
  puts "#{row["type"]},#{row["slug"]}"
  document = Document.find_by(document_type: row["type"].camelize, slug: row["slug"])
  raise "no document #{row["type"]},#{row["slug"]}" unless document
  editions = document.editions.where(state: PUBLISHED_AND_PUBLISHABLE_STATES)
  raise "no editions on #{row["type"]},#{row["slug"]}" unless editions

  puts "\tsetting political status to: #{row["political"]}"
  editions.each { |edition|
    edition.update_column(:political, row["political"] == "true")
  }

  if row["publication-type"]
    new_type = PublicationType.find_by_slug(row["publication-type"].parameterize)
    puts "\tsetting publication type to: #{new_type.singular_name}"
    editions.each { |edition|
      edition.update_column(:publication_type_id, new_type.id)
    }
  end
end
