require 'rails_helper'

RSpec.describe AddressController, :type => :controller do

  describe "GET show" do
    it "returns http success" do
      get :show, id: '$c08000'
      expect(response).to have_http_status(:success)
    end
  end

end
