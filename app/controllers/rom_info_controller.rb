class RomInfoController < ApplicationController
  def index
    @info = ROMInfo.new
  end
end
