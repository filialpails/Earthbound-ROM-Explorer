class TextEntry < ROMEntry
  validates :text_table, presence: true
  validates :text, absence: true

  attr_readonly :text_table, :text

  def initialize(**attributes)
    super
    @text = ''
    decode
  end

  private

  def decode
    cc_lengths = @text_table.lengths
    replacements = @text_table.replacements
    @data.length.times do |i|
      opcode = @data[i]
      if [0x15, 0x16, 0x17].include?(opcode)
        i += 1
        @text << replacements[opcode][@data[i]]
      elsif replacements.has_key?(opcode)
        @text << replacements[opcode]
      elsif opcode >= 0x00 && opcode <= 0x1f
        operand_length = 1
        if cc_lengths[opcode]
          operand_length = cc_lengths[opcode]
        end
        if operand_length.is_a?(Array)
          if operand_length[@data[i + 1]]
            operand_length = operand_length[@data[i + 1]]
          else
            operand_length = operand_length['default']
          end
        end
        operand_length -= 1
        args = ''
        operand_length.times do |j|
          i += 1
          args << ' ' << @data[i].to_hex(6)
        end
        @text << "[#{opcode.to_hex(3)}#{args}]"
      end
    end
  end
end
