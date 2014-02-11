require 'yaml'

class ROMInfo
  attr_reader :processor, :platform, :title, :series

  def initialize
    #rom_file = File.open(Rails.root.join('data', 'Earthbound (U) [!].smc'))
    ebyaml = YAML.load_file(Rails.root.join('data', 'eb.yml'))
    @processor = ebyaml['processor']
    @platform = ebyaml['platform']
    @title = ebyaml['title']
    @series = ebyaml['series']
  end
end
