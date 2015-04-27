WorldwidePriority.where(state: "published").each do |wp|
  puts "Archiving #{wp.title} - edition #{wp.latest_edition.id}"
  wp.archive!
end
