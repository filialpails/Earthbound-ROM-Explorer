require 'rails_helper'

RSpec.describe AddressController, :type => :controller do

  describe "GET 'show'" do
    it "returns http success" do
      get 'show', address: '$c08000'
      expect(response).to be_success
    end
  end

end
