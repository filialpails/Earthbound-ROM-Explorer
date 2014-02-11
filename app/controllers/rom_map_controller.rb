class RomMapController < ApplicationController
  def show
    @map = ROMMap.new
  end
end
