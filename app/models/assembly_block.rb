class AssemblyBlock < Block
  attr_accessor :labels, :arguments, :local_vars, :initial_index_size, :initial_accum_size, :final_index_size, :final_accum_size

  validates :initial_index_size, :initial_accum_size, inclusion: { in: [8, 16] }
  validates :final_index_size, :final_accum_size, inclusion: { in: [8, 16] }, allow_nil: true

  after_initialize do
    @labels ||= {}
    @arguments ||= {}
    @local_vars ||= {}
    @initial_index_size ||= 16
    @initial_accum_size ||= 16
    @data_names = {}
    @code_names = {}
  end
end
