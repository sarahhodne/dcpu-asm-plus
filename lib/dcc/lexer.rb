module DCC
  class Lexer
    attr_reader :tokens
    attr_accessor :include_comments

    def initialize
      @include_comments = false
      @tokens = []
    end

    def lex(f)
      until f.eof?
        line = f.gets.strip
        tokens = line.split(/ /)

        until tokens.empty?
          token = tokens.shift
          case token
          when /\A[A-Z]+\Z/
            @tokens << [:keyword, token]
          when /\A[a-z]+\Z/
            @tokens << [:id, token]
          when /\A"/
            token = token[1..-1]
            str = ''
            until token['"'] # Until token contains "
              str << ' '
              str << token
              token = tokens.shift
            end
            str << ' '
            str << token[0..-2]
            @tokens << [:string, str[1..-1]] # Remove the first space
          when /\A;/
            # Eat the rest of the tokens into a comment
            comment = [:comment, token[1..-1] + tokens.slice!(0..-1).join(' ')]
            @tokens << comment if include_comments
          end
        end
      end
    end
  end
end
