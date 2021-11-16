require 'app/lib/dinraal/numeric.rb'

module Dinraal

  def vector_angle(vector1:, vector2:)
    Math.acos(vector_dot_product(vector1: vector1,
                                 vector2: vector2) / (vector_normal(vector: vector1) * vector_normal(vector: vector2))) * numeric_sign(value: vector_cross_product(vector1: vector1,
                                                                                                                                                                   vector2: vector2))
  end

  def vector_cross_product(vector1:, vector2:)
    (vector1.x * vector2.y) - (vector2.x * vector1.y)
  end

  def vector_dot_product(vector1:, vector2:)
    (vector1.x * vector2.x) + (vector1.y * vector2.y)
  end

  def vector_normal(vector:)
    Math.sqrt((vector.x * vector.x) + (vector.y * vector.y))
  end

end

Dinraal.extend Dinraal