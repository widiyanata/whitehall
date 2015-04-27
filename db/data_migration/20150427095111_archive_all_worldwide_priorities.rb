WorldwidePriority.where(state: "published").each do |wp|
  puts "Archiving #{wp.title}"
  wp.archive!
end
