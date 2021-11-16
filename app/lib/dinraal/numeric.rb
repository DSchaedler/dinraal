module D_Numeric
  # Determines the sign of the provided value
  #
  # @param value: [Float]
  #
  # @return [Int] `-1`, `0`, or `1`
  def numeric_sign(value:)
    value <=> 0
  end
end

D_Numeric.extend Dinraal
