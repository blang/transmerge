require 'date'

require_relative "../GithubMeta"
require "test/unit"

class GithubMetaTest < Test::Unit::TestCase
 
  def test_initialize
    assert(GithubMeta.new("./merge.rb"))
  end

  def test_initialize_invalid
    assert_raise RuntimeError do 
      GithubMeta.new("./notexisting")
    end
  end

  def test_date
    gm = GithubMeta.new("./merge.rb")
    assert_raise RuntimeError do 
      gm.date(0)
    end
    assert(gm.date(1).is_a? DateTime)
    assert(gm.date(5).is_a? DateTime)
    assert(gm.date(1).to_time.to_i > 1385086110)
  end
  
end