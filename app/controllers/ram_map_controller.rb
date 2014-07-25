require 'ebyaml'

class RamMapController < ApplicationController
  def show
    @blocks = EBYAML.ram_map
  end
end
