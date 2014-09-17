require "spec_helper"

RSpec.describe Fixnum do
  describe "#to_hex" do
    it "converts to hex" do
      expect(0.to_hex(1)).to eq('00')
      expect(255.to_hex(1)).to eq('ff')
      expect(65535.to_hex(2)).to eq('ffff')
      expect(16777215.to_hex(3)).to eq('ffffff')
    end
    it "pads with zeroes" do
      expect(0.to_hex(2)).to eq('0000')
      expect(0.to_hex(3)).to eq('000000')
      expect(0.to_hex(4)).to eq('00000000')
      expect(255.to_hex(2)).to eq('00ff')
      expect(255.to_hex(3)).to eq('0000ff')
      expect(255.to_hex(4)).to eq('000000ff')
      expect(65535.to_hex(3)).to eq('00ffff')
      expect(65535.to_hex(4)).to eq('0000ffff')
      expect(16777215.to_hex(4)).to eq('00ffffff')
    end
  end
end
