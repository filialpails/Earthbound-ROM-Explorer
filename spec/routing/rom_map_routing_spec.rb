require "rails_helper"

RSpec.describe RomMapController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/rom_map").to route_to("rom_map#index")
    end

  end
end
