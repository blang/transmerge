require_relative "../YamlParser"
require "test/unit"

class YamlParserTest < Test::Unit::TestCase

  def test_initialize()
    assert(YamlParser.new(["# test"]))
  end

  def test_initialize_fail
    assert_raise RuntimeError do 
      YamlParser.new([])
    end
  end

  def test_comment()
    p = YamlParser.new(["# test"])
    lines, map = p.parse()
    assert_equal(1, lines.length)
    assert_equal(:comment, lines[0].type)
    assert_equal("# test", lines[0].raw)
    assert_equal(nil, lines[0].path)
  end

  def test_object_single()
    p = YamlParser.new(["de:"])
    lines, map = p.parse()
    assert_equal(1, lines.length)
    c = lines[0]
    assert_equal(c, map["de"])
    assert_equal(:object, c.type)
    assert_equal("de:", c.raw)
    assert_equal(nil, c.content)
    assert_equal("de", c.identifier)
    assert_equal("de", c.path)
  end

  def test_object_quoted()
    p = YamlParser.new(["'de':", "  'sub':"])
    lines, map = p.parse()
    assert_equal(2, lines.length)
    c1 = lines[0]
    assert_equal(c1, map["de"])
    assert_equal(:object, c1.type)
    assert_equal("'de':", c1.raw)
    assert_equal(nil, c1.content)
    assert_equal("'de'", c1.identifier)
    assert_equal("de", c1.path)
    assert_equal(0, c1.indent)

    c2 = lines[1]
    assert_equal(c2, map["de.sub"])
    assert_equal(:object, c2.type)
    assert_equal("  'sub':", c2.raw)
    assert_equal(nil, c2.content)
    assert_equal("'sub'", c2.identifier)
    assert_equal("de.sub", c2.path)
    assert_equal(1, c2.indent)
  end

  def test_object()
    p = YamlParser.new(["de:", "  sub:"])
    lines, map = p.parse()
    assert_equal(2, lines.length)
    c1 = lines[0]
    assert_equal(c1, map["de"])
    assert_equal(:object, c1.type)
    assert_equal("de:", c1.raw)
    assert_equal(nil, c1.content)
    assert_equal("de", c1.identifier)
    assert_equal("de", c1.path)
    assert_equal(0, c1.indent)

    c2 = lines[1]
    assert_equal(c2, map["de.sub"])
    assert_equal(:object, c2.type)
    assert_equal("  sub:", c2.raw)
    assert_equal(nil, c2.content)
    assert_equal("sub", c2.identifier)
    assert_equal("de.sub", c2.path)
    assert_equal(1, c2.indent)
  end

  def test_string_single()
    p = YamlParser.new(["de: 'my test'"])
    lines, map = p.parse()
    assert_equal(1, lines.length)
    c1 = lines[0]
    assert_equal(c1, map["de"])
    assert_equal(:string, c1.type)
    assert_equal("de: 'my test'", c1.raw)
    assert_equal("my test", c1.content)
    assert_equal("'", c1.delim)
    assert_equal("de", c1.identifier)
    assert_equal("de", c1.path)
    assert_equal(0, c1.indent)
  end

  def test_string_quoted()
    p = YamlParser.new(["'de': 'my test'"])
    lines, map = p.parse()
    assert_equal(1, lines.length)
    c1 = lines[0]
    assert_equal(c1, map["de"])
    assert_equal(:string, c1.type)
    assert_equal("'de': 'my test'", c1.raw)
    assert_equal("my test", c1.content)
    assert_equal("'", c1.delim)
    assert_equal("'de'", c1.identifier)
    assert_equal("de", c1.path)
    assert_equal(0, c1.indent)
  end

  def test_string_doublequoted()
    p = YamlParser.new(['"de": "my test"'])
    lines, map = p.parse()
    assert_equal(1, lines.length)
    c1 = lines[0]
    assert_equal(c1, map["de"])
    assert_equal(:string, c1.type)
    assert_equal('"de": "my test"', c1.raw)
    assert_equal("my test", c1.content)
    assert_equal('"', c1.delim)
    assert_equal('"de"', c1.identifier)
    assert_equal("de", c1.path)
    assert_equal(0, c1.indent)
  end

  def test_complete()
    p = YamlParser.new(
      [
        '# comment',
        'de:',
        '  lang:',
        '    value: "123"',
        '', #newline
        '  script:',
        "    test: 'bla'",
        'main:',
        '  trans: "bla"'
      ]
      );
    lines, map = p.parse()
    assert_equal(9, lines.length)
    c1 = lines[0]
    assert_equal(:comment, c1.type)
    assert_equal('# comment', c1.raw)
    assert_equal(1, c1.line)

    c2 = lines[1]
    assert_equal(c2, map["de"])
    assert_equal(:object, c2.type)
    assert_equal('de', c2.identifier)
    assert_equal("de", c2.path)
    assert_equal(0, c2.indent)
    assert_equal(2, c2.line)

    c3 = lines[2]
    assert_equal(c3, map["de.lang"])
    assert_equal(:object, c3.type)
    assert_equal('lang', c3.identifier)
    assert_equal("de.lang", c3.path)
    assert_equal(1, c3.indent)
    assert_equal(3, c3.line)

    c4 = lines[3]
    assert_equal(c4, map["de.lang.value"])
    assert_equal(:string, c4.type)
    assert_equal('value', c4.identifier)
    assert_equal('123', c4.content)
    assert_equal('"', c4.delim)
    assert_equal("de.lang.value", c4.path)
    assert_equal(2, c4.indent)
    assert_equal(4, c4.line)

    c5 = lines[4]
    assert_equal(:empty, c5.type)
    assert_equal('', c5.raw)
    assert_equal(5, c5.line)

    c6 = lines[5]
    assert_equal(c6, map["de.script"])
    assert_equal(:object, c6.type)
    assert_equal('script', c6.identifier)
    assert_equal("de.script", c6.path)
    assert_equal(1, c6.indent)
    assert_equal(6, c6.line)

    c7 = lines[6]
    assert_equal(c7, map["de.script.test"])
    assert_equal(:string, c7.type)
    assert_equal('test', c7.identifier)
    assert_equal('bla', c7.content)
    assert_equal("'", c7.delim)
    assert_equal("de.script.test", c7.path)
    assert_equal(2, c7.indent)
    assert_equal(7, c7.line)

    c = lines[7]
    assert_equal(c, map["main"])
    assert_equal(:object, c.type)
    assert_equal('main', c.identifier)
    assert_equal("main", c.path)
    assert_equal(0, c.indent)
    assert_equal(8, c.line)

    c = lines[8]
    assert_equal(c, map["main.trans"])
    assert_equal(:string, c.type)
    assert_equal('trans', c.identifier)
    assert_equal('bla', c.content)
    assert_equal('"', c.delim)
    assert_equal("main.trans", c.path)
    assert_equal(1, c.indent)
    assert_equal(9, c.line)
  end

end