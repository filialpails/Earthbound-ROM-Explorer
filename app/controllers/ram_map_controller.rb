require 'ebyaml'

class RamMapController < ApplicationController
  def index
    @blocks = EBYAML.ram_map
  end
end
