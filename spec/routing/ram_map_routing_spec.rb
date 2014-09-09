require "rails_helper"

RSpec.describe RamMapController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/ram_map").to route_to("ram_map#index")
    end

  end
end
