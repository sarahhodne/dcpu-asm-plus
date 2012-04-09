module DCC
  class Compiler
    attr_reader :asm

    def initialize
      @functions = {}
      @asm = ""
    end

    def compile(parser)
      @parser = parser
      @tree = @parser.tree.dup

      until @tree.empty?
        parse_token(@tree.shift)
      end

      @asm << create_preamble
      @functions.each do |name, function|
        @asm << ":#{name}\n"
        @asm << function.to_assembly
      end

      @asm << create_data
    end

    def parse_token(token)
      case token.first
      when :function
        function_name = token[1]
        function = DCC::Function.new
        @functions[function_name] = function
        token[2].each { |body_token| function.code << parse_token(body_token) }

        function
      when :print, :call
        token
      end
    end

    def create_preamble
      asm = []
      asm << 'JSR main'
      asm << ':halt SET PC halt'
      asm << ':print'
      asm << 'SET B, 0x8000'
      asm << ':print_loopbegin'
      asm << 'IFE [A], 0x0'
      asm << 'SET PC, print_loopdone'
      asm << 'SET [B], [A]'
      asm << 'ADD B, 0x1'
      asm << 'ADD A, 0x1'
      asm << 'SET PC, print_loopbegin'
      asm << ':print_loopdone'
      asm << 'SET PC, POP'

      asm.join("\n") + "\n"
    end

    def create_data
      asm = []

      asm << ':data'
      @parser.data.each do |data|
        asm << "DAT " + escape_data(data)
      end

      asm.join("\n") + "\n"
    end

    def escape_data(data)
      '"' + data.gsub("\x00", "\\\\0") + '"'
    end
  end
end