require_relative "../YamlEntity"
require "test/unit"

class YamlEntityTest < Test::Unit::TestCase

  def test_initialize()
    assert(YamlEntity.new())
  end

  def test_identifier()
    e = YamlEntity.new()
    e.identifier = "test"
    assert_equal("test", e.identifier)
  end

  def test_type()
    e = YamlEntity.new()
    e.type="comment"
    assert_equal("comment", e.type)
  end

  def test_path()
    e = YamlEntity.new()
    e.path="path"
    assert_equal("path", e.path)
  end

  def test_content()
    e = YamlEntity.new()
    e.content="content"
    assert_equal("content", e.content)
  end

  def test_raw()
    e = YamlEntity.new()
    e.raw="raw"
    assert_equal("raw", e.raw)
  end

  def test_indent()
    e = YamlEntity.new()
    e.indent=2
    assert_equal(2, e.indent)
  end

  def test_delim()
    e = YamlEntity.new()
    e.delim="'"
    assert_equal("'", e.delim)
  end
  def test_delim()
    e = YamlEntity.new()
    e.line=2
    assert_equal(2, e.line)
  end

end