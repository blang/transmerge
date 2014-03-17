#!/usr/bin/ruby
require 'yaml'

if ARGV.length < 3 || ARGV.length > 4
  puts "Usage: ./merge.rb ./transiflex.yml ./github.yml [./english.yml] ./output.yml"
  puts "If an english translation is given, interactive merge process is activated. Otherwise transiflex.yml translation is used in case of conflict."
  exit 1
end

interactiveMerge = ARGV.length == 4
fileInput = ARGV[0]
fileAlt = ARGV[1]
fileSource = interactiveMerge ? ARGV[2] : nil
fileOutput = interactiveMerge ? ARGV[3] : ARGV[2]

compareDoc = YAML.load_file(fileAlt) or die "Unable to open '"+fileAlt+"'"

if interactiveMerge
  origDoc = YAML.load_file(fileSource) or die "Unable to open '"+fileSource+"'"
end

f = File.open(fileInput,"r:UTF-8") or die "Unable to open file..."
contentArray=[]
pathStack=[]

countEmpty = 0
countUsed = 0
countSolvedConflicts = 0
countKeep = 0
countDups = 0


regex_comment = /^ *#/
regex_object = /^(?<indent> *)(?<identifier>[a-zA-Z0-9_+]+):$/
regex_string = /^(?<indent> *)(?<identifier>[a-zA-Z0-9_+"]+): *(?<delim>['|"]?)(?<content>.*?)\k<delim>$/

def getTranslation(document, path, altEntry = false)
  doc = document
  i = 0
  for val in path
    if altEntry && i == 0
      doc = doc["en"]
      i+=1
      next
    end
    if doc[val]
      doc = doc[val]
    else
      return nil
    end
  end
  return doc
end

def prompt(orig, alt, pathStack, origDoc)
  puts ("----Conflict: " + pathStack.join('.') + "----")
  puts "1: "+orig
  puts "2: "+alt
  puts "Orig: "+getTranslation(origDoc, pathStack, true)
  input = ''
  while(!(input == '1' || input == '2'))
    puts "Choose translation: "
    input = $stdin.gets.chomp
  end
  if input == '1'
    puts "Use: "+orig
    return orig
  else
    puts "Use: "+alt
    return alt
  end
end

f.each_line {|line|
  line = line.chomp
  if ((regex_comment =~ line) || (line.length == 0))
    contentArray.push line
  else
    match_object = regex_object.match(line)
    match_string = regex_string.match(line)
    if match_object || match_string
      indent = 0

      if match_object
        indent = match_object[:indent].length.to_i / 2
      else
        indent = match_string[:indent].length.to_i / 2
      end

      while indent != pathStack.length
        pathStack.pop
      end

      if match_object
        pathStack.push match_object[:identifier].gsub('"',"") 
        contentArray.push line
      else
        if match_string
          pathStack.push match_string[:identifier].gsub('"',"")
          translation = getTranslation(compareDoc, pathStack)
          delimiter = match_string[:delim]
          if not delimiter
            delimiter = "'"
          end

          # no translation
          if match_string[:content].empty?
            if translation && ! translation.empty?
              countUsed+=1
              contentArray.push(match_string[:indent]+match_string[:identifier]+": "+delimiter+translation+delimiter)
            else # keep empty translation
              countEmpty+=1
              contentArray.push(match_string[:indent]+match_string[:identifier]+": "+delimiter+delimiter)
            end
          else # translation already exists
            
            # alternate translation not found
            if translation && translation.empty?
              # keep original translation
              countKeep+=1
              contentArray.push(match_string[:indent]+match_string[:identifier]+": "+delimiter+match_string[:content]+delimiter)
            else
              # ask which translation to use
              if match_string[:content] != translation
                countSolvedConflicts+=1
                if interactiveMerge
                  content = prompt(match_string[:content], translation, pathStack, origDoc)
                else
                  content = match_string[:content]
                end
                contentArray.push(match_string[:indent]+match_string[:identifier]+": "+match_string[:delim]+content+match_string[:delim])
              else
                countDups+=1
                contentArray.push(match_string[:indent]+match_string[:identifier]+": "+match_string[:delim]+match_string[:content]+match_string[:delim])
              end
            end
          end
          pathStack.pop
        end
      end
    else
      puts "Line could not be parsed"
      puts "'"+line+"'", line.length
    end
  end
}

File.open(fileOutput, 'w') { |file|
  file.write(contentArray.join("\n")+"\n") 
}

# for newline in contentArray
#   puts newline
# end

puts "Keep original: "+countKeep.to_s
puts "Dups: "+countDups.to_s
puts "Still empty: "+countEmpty.to_s
puts "Alternative translation used: "+countUsed.to_s
puts "Solved conflicts: "+countSolvedConflicts.to_s