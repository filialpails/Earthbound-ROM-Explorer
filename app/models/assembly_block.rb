class AssemblyBlock < Block
  attr_accessor :labels, :arguments, :local_vars

  after_initialize do
    @labels ||= {}
    @arguments ||= {}
    @local_vars ||= {}
    @data_names = {}
    @code_names = {}
  end
end
