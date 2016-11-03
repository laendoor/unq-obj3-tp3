class Symbol
  def symbol_get
    "@#{self}".to_sym
  end

  def symbol_set
    "#{self}=".to_sym
  end
end