class Cregularity

  class Error < Exception; end

  PATTERNS = {
    "digit"        => "[0-9]",
    "lowercase"    => "[a-z]",
    "uppercase"    => "[A-Z]",
    "letter"       => "[A-Za-z]",
    "alphanumeric" => "[A-Za-z0-9]",
    "whitespace"   => "\\s",
    "space"        => " ",
    "tab"          => "\\t"
  }

  ESCAPED_CHARS = [
    "*", ".", "?", "^", "+", "$", "|", "(", ")", "[", "]", "{", "}"
  ]

  def initialize
    @str = ""
    @ended = false
  end

  def start_with(*args)
    raise Cregularity::Error.new("#start_with? called multiple times") unless @str.empty?
    write "^%s", args
  end

  def append(*args)
    write interpret(*args)
  end
  def then(*args)
    append(*args)
  end

  def end_with(*args)
    write "%s$", args
    @ended = true
    self
  end

  def maybe(*args)
    write "%s?", args
  end

  def not(*args)
    write "(?!%s)", args
  end

  def one_of(ary)
    write "[%s]" % ary.map { |c| escape(c) }.join("|")
  end

  def between(range, pattern)
    unless range.size == 2 && range.any? { |i| i.is_a?(Int) }
      raise Cregularity::Error.new("must provide an array of 2 elements, one of them must be an integer")
    end

    write "%s{%s,%s}" % [interpret(pattern), range[0], range[1]]
  end

  def at_least(times, pattern)
    between [times, nil], pattern
  end

  def at_most(times, pattern)
    between [nil, times], pattern
  end

  def zero_or_more(pattern)
    write "%s*", pattern
  end

  def one_or_more(pattern)
    write "%s+", pattern
  end

  def regex
    Regex.new(@str)
  end

  def get
    regex
  end

  def =~(other)
    regex =~ other
  end

  forward_missing_to regex

  def to_s
    "#<Cregularity:#{object_id} regex=/#{@str}/>"
  end

  def inspect
    to_s
  end

  private def write(str, *args)
    raise Cregularity::Error.new("#end_with has already been called") if @ended
    if args.nil? || args == Tuple.new
      @str += str
    else
      @str += str % interpret(*args)
    end
    self
  end

  # Translate/escape characters etc and return regex-ready string
  private def interpret(*args)
    case args
    when Tuple(Int32, Symbol)
      numbered_constraint(args[0], args[1])
    when Tuple(Tuple(Int32, Symbol))
      interpret(*args[0])
    when Tuple(Int32, String)
      numbered_constraint(args[0], args[1])
    when Tuple(Tuple(Int32, String))
      interpret(*args[0])
    when Tuple(String)
      patterned_constraint(args[0])  
    when Tuple(Tuple(String))
      interpret(*args[0])
    when Tuple(Symbol)
      patterned_constraint(args[0])  
    else
      raise ArgumentError.new("Args was actually a #{args}")
    end
  end

  # Ex: (2, "x") or (3, :digits)
  private def numbered_constraint(count, _type)
    pattern = patterned_constraint(_type)
    raise Cregularity::Error.new("Unrecognized pattern") if pattern.nil? || pattern.empty?
    "%s{%s}" % [pattern, count]
  end

  # Ex: ("aa") or ("$")
  private def patterned_constraint(pattern)
    escape translate(pattern)
  end

  # Remove a trailing "s", if there is one
  private def singularize(word)
    str = word.to_s
    str.ends_with?("s") ? str[0..-2] : str
  end

  # Escape special regex characters in a string
  #
  # Ex:
  #   escape("one.two")
  #   # => "one\.two"
  #
  private def escape(pattern)
    pattern.to_s.gsub(/.+/) do |char|
      ESCAPED_CHARS.includes?(char) ? "\\#{char}" : char
    end
  end

  # Translate an identifier such as :digits to [0-9], etc
  # Returns the original identifier if no character class found
  private def translate(pattern)
    PATTERNS.fetch(singularize(pattern), pattern)
  end

end
