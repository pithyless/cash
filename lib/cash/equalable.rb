module Equalable
  def ==(o)
    o.class == self.class && o.equality_state == equality_state
  end
  alias_method :eql?, :==

  def hash
    equality_state.hash
  end
end
