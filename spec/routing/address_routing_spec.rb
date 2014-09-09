require "rails_helper"

RSpec.describe AddressController, :type => :routing do
  describe "routing" do

    it "routes to #show" do
      expect(:get => "/address/$c08000").to route_to("address#show", :id => "$c08000")
    end

  end
end
