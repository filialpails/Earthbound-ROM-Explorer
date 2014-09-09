require 'ebyaml'

class RomMapController < ApplicationController
  def index
    @blocks = EBYAML.rom_map
  end
end
