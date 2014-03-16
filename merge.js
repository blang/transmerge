'use strict';
var fs = require('fs'),
  yaml = require('js-yaml');

if(process.argv.length != 5){
  console.log("This tool merges multiple yaml translations.");
  console.log("Usage: node merge.js ./transiflex.yml ./github.yml ./output.yml");
  process.exit(1);
}

var referenceFile = process.argv[2];
var compareFile = process.argv[3];
var outputFile = process.argv[4];

var indentSpaces = 2,
  countSyncd = 0,
  countLines = 0,
  countStrings = 0,
  countEmpty = 0,
  countDelConflicts = 0,
  countConflicts = 0,
  countMatch = 0,
  countUntouched = 0;

var docArray = fs.readFileSync(referenceFile, 'utf8').split('\n');
var docCompare = yaml.safeLoad(fs.readFileSync(compareFile, 'utf8'));

var pathStack = [];
var genArray = [];
for (var i = 0; i < docArray.length; i++) {
  countLines++;
  var cur = docArray[i];
  var obj = parseLine(docArray[i]);
  if(obj.type === 'object' || obj.type === 'string'){
    while(obj.indent !== pathStack.length){
      pathStack.pop();
    }
  }

  //console.log(i+": "+docArray[i]);
  //console.log(obj);
  //console.log("Path: "+pathStack.join("/"));
  if(obj.type === 'string'){
    countStrings++;
    pathStack.push(obj.identifier);
    var compTranslation = getCompare(docCompare, pathStack);
    
    //Does not have translation yet;
    if(obj.content.length === 0){
      if(compTranslation.length > 0){
        if(compTranslation.indexOf(obj.delimiter) !== -1){
          obj.delimiter = (obj.delimiter === '"')? "'":'"';
          if(compTranslation.indexOf(obj.delimiter) !== -1){
            console.log("Path: "+pathStack.join("/"));
            console.log("Delimiter conflict");
            countDelConflicts++;
          }
        }
        countSyncd++;
        obj.content = compTranslation;
      }else{
        countEmpty++;
      }
    }else{ //does have translation, possible conflict
      if(compTranslation.length > 0){
        if(compTranslation != obj.content){
          countConflicts++;
        }else{
          countMatch++;
        }
      }else{
        countUntouched++;
      }
    }
    //Remove current entry from pathStack
    pathStack.pop();
  }

  //Push line to final array
  genArray.push(obj);

  //Adjust path
  if(obj.type === 'object'){
    pathStack.push(obj.identifier);
  }
}
//Generate yaml and write to file
var dumpStr = dump(genArray);
fs.writeFileSync(outputFile, dumpStr, 'utf8');

//Stats
console.log('Lines: '+countLines);
console.log('Strings: '+countStrings);
console.log('Synced Translations: '+countSyncd);
console.log('Still without translation: '+countEmpty);
console.log('Untouched: '+countUntouched);
console.log('Match (same translation): '+countMatch);
console.log('Conflicts: '+countConflicts);
console.log('Delimiter conflicts: '+countDelConflicts);

/////////////////////////Functions
function getCompare(docCompare, pathArr){
  var obj = docCompare;
  for(var i = 0; i < pathArr.length; i++){
    if(obj.hasOwnProperty(pathArr[i])){
      obj = obj[pathArr[i]];
    }else{
      return "";
    }
  }
  return obj;
}

//Dump array to string
function dump(docArray){
  var dump = '';
  for(var i = 0; i < docArray.length; i++){
    var obj = docArray[i];
    switch(obj.type){
      case 'object':
        dump += (repeat(' ', obj.indent*indentSpaces))+obj.identifier+':';
        break;
      case 'string':
        dump += (repeat(' ', obj.indent*indentSpaces))+obj.identifier+': '+obj.delimiter+obj.content+obj.delimiter;
        break;
      default:
        dump += obj.raw;
        break;
    }
    if(i !== (docArray.length -1) )
      dump += '\n';
  }
  return dump;
}

//Parse line
//TODO: Replace with proper regex
function parseLine(line){
  if(line.length === 0){
    return {type: 'empty', raw: ''};
  }else{
    var indent = 0;
    var cchar = line[0];
    var identifier = '';
    var content = '';
    var strdelimiter = '';
    var i = 0;
    //get indent
    for(i = 0; i < line.length && line[i] === ' '; i++){
        indent++;
    }
    if(line[i] === '#'){
      return {type: 'comment', raw: line};
    }
    for(;i < line.length && line[i] !== ':'; i++){
      identifier += line[i];
    }
    i++;
    //ignore whitespaces
    for(;i < line.length && line[i] === ' '; i++){
    }

    //determine string delimiter
    switch(line[i]){
      case "'":
      case '"':
        strdelimiter = line[i];
        i++;
        break;
      default:
        strdelimiter = '';
        break;
    }
    
    //read content, including possible delimiter
    for(;i < line.length; i++){
      content += line[i];
    }

    var type = (!content.trim()) ? 'object' : 'string';

    //remove delimiter
    //TODO: That's not cool!
    if(strdelimiter.length > 0){
      content = content.substring(0, content.length - 1);
    }
    return {'type': type, raw: line, 'identifier': identifier, 'content': content, 'indent': parseInt(indent/2), 'delimiter':strdelimiter};
  }
}

function repeat(pattern, count) {
    if (count < 1) return '';
    var result = '';
    while (count > 0) {
        if (count & 1) result += pattern;
        count >>= 1, pattern += pattern;
    }
    return result;
}
