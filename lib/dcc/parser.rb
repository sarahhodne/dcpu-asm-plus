module DCC
  class Parser
    attr_reader :tree, :data, :data_length

    def initialize
      @tokens = []
      @tree = []
      @data = []
      @data_length = 0
    end

    def parse(lexer)
      @tokens = lexer.tokens.dup
      until @tokens.empty?
        @tree << parse_token(@tokens.shift)
      end
    end

    def parse_token(token)
      token_type = token.first

      case token_type
      when :keyword
        parse_keyword(token)
      when :id
        parse_id(token)
      when :string
        parse_string(token)
      else
        token
      end
    end

    def parse_keyword(token)
      case token[1]
      when 'FUNC'
        function_name_token = @tokens.shift
        # function_name_token should be an ID
        # TODO: Add checking of the above
        function_name = function_name_token.last

        [:function, function_name, read_function_body]
      when 'CALL'
        [:call, @tokens.shift.last]
      when 'PRINT'
        [:print, parse_token(@tokens.shift)]
      else
        token
      end
    end

    def parse_id(token)
      token.last
    end

    def parse_string(token)
      str = token.last + "\0"
      @data << str
      @data_length += str.length

      @data_length - str.length
    end

    def read_function_body
      function_body = []
      until @tokens.first == [:keyword, 'ENDFUNC']
        function_body << parse_token(@tokens.shift)
      end
      @tokens.shift # Remove the ENDFUNC keyword

      function_body
    end
  end
end
