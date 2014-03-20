#!/usr/bin/ruby
require_relative './YamlEntity'
require_relative './YamlParser'
require_relative './GithubMeta'
require_relative './TransifexApi'

if ARGV.length < 3 || ARGV.length > 4
  puts "Usage: ./merge.rb ./transifex.yml ./github.yml [./english.yml] ./output.yml"
  puts "If an english translation is given, interactive merge process is activated. Otherwise the most up-to-date translation is used in case of conflict."
  exit 1
end

countStrings = 0
countEmpty = 0
countConflict = 0
countGithub = 0
countTransifex = 0
countConflictTransiflex = 0

interactiveMerge = ARGV.length == 4
filenameTransifex = ARGV[0]
filenameGithub = ARGV[1]
filenameOrigin = interactiveMerge ? ARGV[2] : nil
filenameOutput = interactiveMerge ? ARGV[3] : ARGV[2]

fileTransifex = File.open(filenameTransifex,"r:UTF-8") or die "Unable to open file: " + filenameTransifex 
fileGithub = File.open(filenameGithub,"r:UTF-8") or die "Unable to open file: " + filenameGithub

if interactiveMerge
  fileOrigin = File.open(filenameOrigin,"r:UTF-8") or die "Unable to open file: " + filenameOrigin
end

linesTransifex = []
fileTransifex.each_line {|line|
  linesTransifex.push line
}

linesGithub = []
fileGithub.each_line {|line|
  linesGithub.push line
}

if interactiveMerge
  linesOrigin = []
  fileOrigin.each_line {|line|
    linesOrigin.push line
  }
end

parserTransifex = YamlParser.new(linesTransifex)
parseLinesTransifex, parseMapTransifex = parserTransifex.parse()

parserGithub = YamlParser.new(linesGithub)
parseLinesGithub, parseMapGithub = parserGithub.parse()

if interactiveMerge
  parserOrigin = YamlParser.new(linesOrigin)
  parseLinesOrigin, parseMapOrigin = parserOrigin.parse()
end

githubMeta = GithubMeta.new(filenameGithub)
transifexApi = TransifexApi.new('./transifex_config.yml')

outputLines = []

# Comparing
parseLinesTransifex.each { |entityTransifex|
  if entityTransifex.type != :string
    outputLines.push(entityTransifex.raw)
  else
    countStrings+=1
    path = entityTransifex.path
    dateTransifex = transifexApi.get(path)
    entityGithub = parseMapGithub[path]

    # Github has translation, conflict incoming
    if entityGithub && (!entityGithub.content.empty?)
      dateGithub = githubMeta.date(entityGithub.line)

      # Check if there is a conflict
      if ((!entityTransifex.content.empty?) && (entityTransifex.content != entityGithub.content))
        countConflict+=1

        # Interactive merge
        if interactiveMerge

          # Get english version
          pathOrigin = entityGithub.path.split(".")
          pathOrigin.shift
          pathOrigin = pathOrigin.insert(0, "en")
          pathOrigin = pathOrigin.join(".")
          contentOrigin = parseMapOrigin[pathOrigin]

          puts "Path: " + entityGithub.path
          if contentOrigin
            puts "English: "+contentOrigin.content
          end
          puts "Transifex (1): "+entityTransifex.content
          if dateTransifex
            puts "Transifex Date: "+dateTransifex.iso8601
          end
          puts "Github (2): "+entityGithub.content
          puts "Github Date: "+dateGithub.iso8601

          # Prompt the user
          input = -1
          while(!(input == '1' || input == '2'))
            puts "Choose translation: 1 or 2"
            input = $stdin.gets.chomp
          end

          if input == '1'
            countTransifex+=1
            outputLines.push(entityTransifex.raw)
          else
            countGithub+=1
            outputLines.push(entityGithub.raw)
          end
        else # Automatic merge
          if dateTransifex
            if dateTransifex > dateGithub
              countTransifex+=1
              countConflictTransiflex+=1
              outputLines.push(entityTransifex.raw)
              if entityTransifex.content.empty?
                countEmpty+=1
              end
            else
              countGithub+=1
              outputLines.push(entityGithub.raw)
              if entityGithub.content.empty?
                countEmpty+=1
              end
            end
          else

          end
        end
      else # Use github
        countGithub+=1
        outputLines.push(entityGithub.raw)
        if entityGithub.content.empty?
          countEmpty+=1
        end
      end

    else # No github, no conflict
      countTransifex+=1
      outputLines.push(entityTransifex.raw)
      if entityTransifex.content.empty?
        countEmpty+=1
      end
    end

  end
}

fileOutput = File.open(filenameOutput,"w:UTF-8") or die "Unable to open file: " + filenameOutput
fileOutput.write(outputLines.join("\n")+"\n")

puts "Strings: "+countStrings.to_s
puts "Used Github: "+countGithub.to_s
puts "Used Transifex: "+countTransifex.to_s
puts "Conflicts but Transiflex newer: " + countConflictTransiflex.to_s
puts "Conflicts solved: "+countConflict.to_s
puts "Still empty: "+countEmpty.to_s