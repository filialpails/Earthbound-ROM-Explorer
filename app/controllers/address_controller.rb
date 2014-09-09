require 'ebyaml'

class AddressController < ApplicationController
  def show
    @block = EBYAML[params[:id].delete('$').to_i(16)]
  end
end
