require 'ostruct'

module DissociatedIntrospection

  class Inspection

    def initialize(file:, parent_class_replacement: :RecordingParent)
      @file                     = file
      @parent_class_replacement = parent_class_replacement
    end

    def class_name
      ruby_class_source.class_name
    end

    def get_class
      @get_class ||= _get_class
    end

    def class_macros
      get_class.__missing_class_macros__
    end

    private

    def _get_class
      modified_class_str = ruby_class_source.modify_parent_class(parent_class_replacement)
      load_sandbox(OpenStruct.new(read: modified_class_str, path: file.path))
    end

    def ruby_class_source
      @ruby_class_source ||= RubyClass.new(file.read)
    end

    def load_sandbox(file)
      @klass ||= EvalSandbox.new(file: file).call
    end

    attr_reader :parent_class_replacement, :file

  end
end