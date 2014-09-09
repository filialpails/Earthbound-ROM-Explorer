require "rails_helper"

RSpec.describe RomInfoController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/rom_info").to route_to("rom_info#index")
    end

  end
end
