require "active_support/core_ext/module"

class RuboCopDiff
  def self.changed_lines
    @changed_lines ||= begin
      changes = changed_files.map do |file|
        next unless File.exist?(file)
        [file, `git difftool #{commit_options} -y -x 'diff --new-line-format="%dn "
                --unchanged-line-format="" --changed-group-format="%>"' #{file}`.split.map(&:to_i)]
      end.compact

      Hash[changes]
    end
  end

private
  def self.changed_files
    `git diff #{commit_options} --name-only`.
      split.
      select { |f| f =~ %r{.rb$} }.
      map { |f| File.expand_path(f.chomp, "./") }
  end

  def self.commit_options
    @commit_options ||= begin
      options = {diff_from: "origin/master", diff_to: "HEAD", cached: false}
      OptionParser.new do |opts|
        opts.on("--diff-from COMMITISH", "ref to compare from (default: origin/master") do |f|
          options[:diff_from] = f
        end
        opts.on("--diff-to COMMITISH", "ref to compare to (default: HEAD)") do |t|
          options[:diff_to] = t
        end
        opts.on("--cached", "diff staged files") do |c|
          options[:cached] = true
        end
      end.parse!

      if options[:cached]
        "--cached #{options[:diff_from]}"
      else
        "#{options[:diff_from]} #{options[:diff_to]}"
      end
    end
  end
end

class RuboCop::Cop::Cop
  def enabled_line_with_diff?(line_number)
    enabled_line_without_diff?(line_number) &&
      (RuboCopDiff.changed_lines[@processed_source.path] || []).include?(line_number)
  end
  alias_method_chain :enabled_line?, :diff
end

class RuboCop::TargetFinder
  def find_with_diff(args)
    find_without_diff(args).select { |f| RuboCopDiff.changed_lines.keys.include? f }
  end
  alias_method_chain :find, :diff
end
