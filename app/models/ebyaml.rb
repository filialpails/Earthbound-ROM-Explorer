require 'yaml'

module EBYAML
  @yaml = File.open(Rails.configuration.yaml_location, 'r') do |file|
    YAML.load_stream(file.read, file.path)
  end

  def self.info
    @yaml[0]
  end

  def self.map
    @yaml[1]
  end
end
