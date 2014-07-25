require 'ebyaml'

class AddressController < ApplicationController
  def show
    @block = EBYAML[params[:address].delete('$').to_i(16)]
  end
end
