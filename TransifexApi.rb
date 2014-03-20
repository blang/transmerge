require 'yaml'
require 'json'
require 'net/http'
require 'uri'

class TransifexApi

  def initialize(configFile)
    @configFile = configFile
    readConfig()
    data = readData()
    parseData(data)
    
  end

  def get(key)
    # Handle transifex pluralization (only one last_updated for the pluralization)
    lastkey = key.split(".").last
    if(lastkey == "one" || lastkey == "other")
      newPath = key.split(".")
      newPath.pop
      return @data[newPath.join(".")]
    else 
      return @data[key]
    end
  end

  private

  def readConfig()
    @config = YAML.load_file(@configFile) or die "Unable to open '"+@config_file+"'"
    raise "No auth" unless @config['auth']
    raise "No username" unless @config['auth']['username']
    raise "No username" unless @config['auth']['password']
    raise "No api" unless @config['api']
    raise "No api.url" unless @config['api']['url']
    raise "No project" unless @config['project']
    raise "No project.name" unless @config['project']['name']
    raise "No project.resource" unless @config['project']['resource']
    raise "No project.language" unless @config['project']['language']

    @url = @config['api']['url']
    @url = @url.gsub("%project%", @config['project']['name'])
    @url = @url.gsub("%resource%", @config['project']['resource'])
    @url = @url.gsub("%language%", @config['project']['language'])
  end

  def readData()
    uri = URI.parse(@url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(@config['auth']['username'], @config['auth']['password'])
    response = http.request(request)
    if response.code != '200'
      raise "Could not request transiflex api" + response.inspect
    end
    return JSON.parse(response.body)
  end

  def parseData(jsonData)
    @data = Hash.new
    jsonData.each { |x|
      path = @config['project']['language'] + '.' + x['key']
      if x['last_update'] != ''
        @data[path]=DateTime.parse(x['last_update'])
      else
        @data[path]=nil
      end
    }
  end

end