require 'json_expressions/matcher'

module JsonExpressions
  WILDCARD_MATCHER = Object.new

  def WILDCARD_MATCHER.is_a?(klass)
    false
  end

  def WILDCARD_MATCHER.==(other)
    true
  end

  def WILDCARD_MATCHER.=~(other)
    true
  end

  def WILDCARD_MATCHER.to_s
    'WILDCARD_MATCHER'
  end
end