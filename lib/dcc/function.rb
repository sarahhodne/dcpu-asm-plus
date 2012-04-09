module DCC
  class Function
    attr_accessor :argc, :argv, :code

    def initialize(name)
      @name = name
      @code = []
      @vars = ['ret']
      @argc = 0
      @argv = []
    end

    def to_assembly
      code_block = create_code_block(@code)

      asm = []
      asm << 'SET PUSH, J'
      asm << 'SET J, SP'
      asm << "SUB SP, #{@vars.length}" if @vars.any?

      asm << code_block

      asm << 'SET SP, J'
      asm << 'SET J, POP'
      asm << 'SET PC, POP' # Return

      asm.join("\n") + "\n"
    end

    def create_code_block(body)
      asm = []
      body.each do |code|
        case code.first
        when :call
          # Store A, B and C (may not be necessary)
          asm << 'SET PUSH, A'
          asm << 'SET PUSH, B'
          asm << 'SET PUSH, C'

          (code[2][0..2] || []).each.with_index do |arg, i|
            asm << "SET #{%w(A B C)[i]}, #{var(asm, arg, true)}"
          end
          (code[2][3..-1] || []).each do |arg|
            asm << "SET PUSH, #{var(asm, arg, true)}"
          end
          asm << "JSR #{code[1]}"
          asm << "ADD SP, #{code[2].length-3}" if code[2].length > 3

          # Save return value to `ret` variable
          asm << "SET #{var(asm, 'ret')}, A"

          asm << 'SET C, POP'
          asm << 'SET B, POP'
          asm << 'SET A, POP'
        when :print
          asm << "SET A, #{code[1]}"
          asm << "ADD A, data"
          asm << "JSR print"
        when :var
          @vars << code[1]
          asm << "SET #{var(asm, code[1])}, #{var(asm, code[2])}"
        when :set
          asm << "SET #{var(asm, code[1])}, #{var(asm, code[2])}"
        when :add
          if code.size == 3
            asm << "ADD #{var(asm, code[1])}, #{var(asm, code[2])}"
          else
            asm << "SET #{var(asm, code[3])}, #{var(asm, code[1])}"
            asm << "ADD #{var(asm, code[3])}, #{var(asm, code[2])}"
          end
        when :sub
          if code.size == 3
            asm << "SUB #{var(asm, code[1])}, #{var(asm, code[2])}"
          else
            asm << "SET #{var(asm, code[3])}, #{var(asm, code[1])}"
            asm << "SUB #{var(asm, code[3])}, #{var(asm, code[2])}"
          end
        when :return
          asm << "SET A, #{var(asm, code[1])}; return"
          asm << 'SET SP, J'
          asm << 'SET J, POP'
          asm << 'SET PC, POP'
        when :sret
          asm << "SET #{var(asm, code[1])}, #{var(asm, 'ret')}"
        end
      end

      asm.join("\n")
    end

    def var(asm, name, in_stack=false)
      if name[0] == '['
        varloc = var(asm, name[1..-2], in_stack)
        if %w(A B C).include?(varloc)
          return "[#{varloc}]"
        else
          pointername = %w(X Y Z)[@pointercount % 3]
          @pointercount += 1
          asm << "SET #{pointername}, #{var(asm, name[1..-2], in_stack)}"
          return "[#{pointername}]"
        end
      end
      index = @argv.index(name)
      if index # function argument
        if index < 3
          if in_stack
            # [SP+(2-index)], but [SP-x] isn't supported
            "[SP+#{(2-index)}]"
          else
            %w(A B C)[index]
          end
        else
          "[J+#{index-1}]"
        end
      elsif @vars.index(name) # local variable
        "[J+#{0x10000-(@vars.index(name)+2)}]"
      else
        name
      end
    end
  end
end