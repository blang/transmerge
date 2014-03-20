require 'date'

require_relative "../TransifexApi"
require "test/unit"

class TransifexApiTest < Test::Unit::TestCase

  def test_initialize()
    assert(TransifexApi.new('./transifex_config.yml'))
  end

  def test_get()
    api = TransifexApi.new('./transifex_config.yml')
    assert(api.get('de.js.log_in').is_a? DateTime)
    assert(api.get('de.js.log_in'))
  end

end