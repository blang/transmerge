require 'date'
class GithubMeta

  def initialize(filename)
    raise unless filename.is_a? String
    raise "File not exists" unless File.exist? filename
    output = `./git_meta.sh #{filename}`
    @lines = output.split("\n")
    raise "No blame data" unless @lines.length > 0
  end

  def date(linenumber)
    raise unless linenumber.is_a? Numeric
    raise "Wrong linenumber" unless linenumber > 0
    raise "No data for linenumber found" unless linenumber <= @lines.length 
    return DateTime.strptime(@lines[linenumber].chomp.to_s, '%s')
  end

end
