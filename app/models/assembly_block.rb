class AssemblyBlock < Block
  attr_accessor :labels, :arguments, :local_vars

  def initialize(**attributes)
    super
    @labels ||= {}
    @arguments ||= {}
    @local_vars ||= {}
    @data_names = {}
    @code_names = {}
  end
end
