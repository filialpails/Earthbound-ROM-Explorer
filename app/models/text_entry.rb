class TextEntry < DataEntry
  validates :text_table, presence: true
  validates :text, absence: true

  attr_accessor :text_table, :text

  def initialize(**attributes)
    super
    @pc = 0
    @text = decode
  end

  private

  def readPC
    res = @data[@pc] || 0x69
    @pc += 1
    res
  end

  def decode
    cc_lengths = @text_table['lengths']
    replacements = @text_table['replacements']
    text = ''
    while @pc < @data.length
      opcode = readPC
      if (0x15..0x17).include?(opcode)
        text << replacements[opcode][readPC]
      elsif replacements.has_key?(opcode)
        text << replacements[opcode]
      elsif (0x00..0x1f).include?(opcode)
        operand_length = cc_lengths[opcode] || 1
        if operand_length.kind_of?(Hash)
          operand_length = operand_length[readPC] || operand_length['default']
        end
        operand_length -= 1
        args = ''
        operand_length.times {args << " #{readPC.to_hex(1)}"}
        text << "[#{opcode.to_hex(1)}#{args}]"
      end
    end
    text
  end
end
