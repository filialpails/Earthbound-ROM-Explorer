class RamMapController < ApplicationController
  def show
    @map = RAMMap.new
  end
end
