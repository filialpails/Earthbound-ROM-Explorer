class TextEntry < DataEntry
  validates! :text_table, presence: true
  validates! :text, absence: true

  attr_accessor :text_table, :text

  def initialize(**attributes)
    super
    @pc = 0
    @text = decode
  end

  private

  def decode
    cc_lengths = @text_table.lengths
    replacements = @text_table.replacements
    text = ''
    read_pc = ->{res = @data[@pc]; @pc += 1; res}
    while @pc < @data.length
      opcode = read_pc
      if (0x15..0x17).include?(opcode)
        text << replacements[opcode][readPC]
        next
      end
      if replacements.has_key?(opcode)
        text << replacements[opcode]
        next
      end
      if (0x00..0x1f).include?(opcode)
        operand_length = cc_lengths[opcode] || 1
        if operand_length.kind_of?(Hash)
          operand_length = operand_length[read_pc] || operand_length['default']
        end
        operand_length -= 1
        args = ''
        operand_length.times {args << " #{read_pc.to_hex(1)}"}
        text << "[#{opcode.to_hex(1)}#{args}]"
      end
    end
    text
  end
end
