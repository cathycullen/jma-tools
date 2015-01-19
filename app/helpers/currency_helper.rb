class CurrencyyHelper
  def to_currency(amount)
    amount.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
  end
end
