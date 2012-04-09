module DCC
  class Function
    attr_accessor :argc, :argv, :code

    def initialize
      @code = []
    end

    def to_assembly
      asm = []
      asm << 'SET PUSH, J'
      asm << 'SET J, SP'

      @code.each do |code|
        case code.first
        when :call
          asm << "JSR #{code[1]}"
        when :print
          asm << "SET A, #{code[1]}"
          asm << "ADD A, data"
          asm << "JSR print"
        end
      end

      asm << 'SET SP, J'
      asm << 'SET J, POP'
      asm << 'SET PC, POP' # Return

      asm.join("\n") + "\n"
    end
  end
end