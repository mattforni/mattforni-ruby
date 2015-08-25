module Epsilon
  def self.equal?(first, second, epsilon = EPSILON)
    (first.to_f - second.to_f).abs < epsilon
  end

  private

  EPSILON = 0.0001
end

