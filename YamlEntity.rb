class YamlEntity
  @indent = 0
  @type = nil
  @identifier = nil
  @content = nil
  @path = nil
  @line = 0
  
  attr_accessor :identifier, :type, :delim, :content, :path, :raw, :indent, :line

  def initialize()

  end

  # def identifier=(identifier)
  #   @identifier = identifier
  # end

  # def type=(type)
  #   @type = type
  # end

  # def indent=(indent)
  #   @indent = indent
  # end

  # def delim=(delim)
  #   @delim = delim
  # end

  # def content=(content)
  #   @content = content
  # end

  # def path=(path)
  #   @path = path
  # end

  # def raw=(raw)
  #   @raw = raw
  # end

end