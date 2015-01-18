class TextEntry < DataEntry
  validates! :text, :text_table, presence: true

  attr_accessor :text_table, :text

  after_initialize do
    @text = decode
  end

  private

  def decode
    pc = 0
    cc_lengths = @text_table.lengths
    replacements = @text_table.replacements
    text = ''
    while pc < @data.length
      opcode = @data[pc]
      pc += 1
      if replacements.has_key?(opcode)
        replacement = replacements[opcode]
        if replacement.kind_of?(Array)
          replacement = replacement[@data[pc]]
          pc += 1
        end
        text << replacement
        next
      end
      if opcode < 0x20
        operand_length = cc_lengths[opcode] || 1
        if operand_length.kind_of?(Hash)
          operand_length = operand_length[@data[pc]] || operand_length['default']
        end
        operand_length -= 1
        args = ''
        operand_length.times {args << " #{@data[pc].to_hex(1)}"; pc += 1}
        text << "[#{opcode.to_hex(1)}#{args}]"
      end
    end
    text
  end
end
