require 'ebyaml'

class RomMapController < ApplicationController
  def show
    @blocks = EBYAML.rom_map
  end
end
