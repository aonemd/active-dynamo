class Hash
  def symbolize_keys
    self.inject({}) do |h, (k, v)|
      if v.is_a? Hash
        h[k.to_sym] = v.symbolize_keys
      else
        h[k.to_sym] = v
      end

      h
    end
  end
end
