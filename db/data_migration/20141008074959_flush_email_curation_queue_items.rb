puts "Sending notifications to subscribers for email curation queue items and deleting them"

connection = ActiveRecord::Base.connection
email_curation_queue_items = connection.select_all("SELECT * FROM email_curation_queue_items;")
email_curation_queue_items.each do |email_curation_queue_item|
  # {
  #   "id" => 15142,
  #   "edition_id"=>381908,
  #   "title"=>"Airports Commission announces inner Thames estuary decision",
  #   "summary"=>"The inner Thames estuary airport proposal not shortlisted.",
  #   "notification_date"=>2014-09-03 06:34:29 UTC
  # }
  Whitehall::GovUkDelivery::Worker.notify!(
    Edition.find(email_curation_queue_item['edition_id']),
    email_curation_queue_item['notification_date'],
    email_curation_queue_item['title'],
    email_curation_queue_item['summary']
  )
  connection.execute("DELETE FROM email_curation_queue_items WHERE id=#{email_curation_queue_item['id']};")
  print "."
end

puts "\nSent notifications for #{email_curation_queue_items.count} email curation queue items and deleted them."
