class RomInfoController < ApplicationController
  def show
    @info = ROMInfo.new
  end
end
