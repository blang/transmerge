# Yaml Parser that preserves order, comments, newlines
require_relative './YamlEntity'
class YamlParser
  @@regex_comment = /^ *#/
  @@regex_object = /^(?<indent> *)(?<identifier>[a-zA-Z0-9_+"']+):$/
  @@regex_string = /^(?<indent> *)(?<identifier>[a-zA-Z0-9_+"']+): *(?<delim>['|"]?)(?<content>.*?)\k<delim>$/
  @@indentMulti = 2


  def initialize(lines)
    raise unless lines.is_a? Array
    raise unless lines.length > 0
    @lines = lines
  end

  def parse()
    countLine = 1
    plines = []
    refMap = {}
    pathStack = []
    @lines.each do |line|
      line = line.chomp
      entity = YamlEntity.new()
      entity.raw = line
      if @@regex_comment =~ line
        entity.type = :comment
      elsif line.length == 0
        entity.type = :empty
      else
        match_object = @@regex_object.match(line)
        match_string = @@regex_string.match(line)
        if !match_object && !match_string
          raise "Error: Line " + countLine.to_s + " could not be parsed: " + line
          next
        end
        if match_object
          entity.type = :object
        else
          entity.type = :string
        end

        #combine to one object
        match = (match_object) ? match_object : match_string

        entity.indent = match[:indent].length.to_i / 2

        # Adjust path
        while entity.indent != pathStack.length
          pathStack.pop
        end

        # get entity
        entity.identifier = match[:identifier]
        pathStack.push match[:identifier].gsub('"',"").gsub("'","")
        entity.path = pathStack.join('.')

        if entity.type == :string
          entity.delim = match[:delim]
          entity.content = match[:content]
        end

      end

      if entity && entity.path && !entity.path.empty?
        refMap[entity.path] = entity
      end
      entity.line = countLine
      plines.push(entity)
      countLine+=1
    end
    return plines, refMap
  end

end