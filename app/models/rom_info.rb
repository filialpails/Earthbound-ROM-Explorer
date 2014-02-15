class ROMInfo < ApplicationModel
  attr_reader :processor, :platform, :title, :series

  def initialize(**attributes)
    super
    @processor = EBYAML.info['processor']
    @platform = EBYAML.info['platform']
    @title = EBYAML.info['title']
    @series = EBYAML.info['series']
  end
end
