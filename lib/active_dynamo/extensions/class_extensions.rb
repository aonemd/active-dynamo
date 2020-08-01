class Class
  def snake_name
    name.gsub('::', '_').downcase
  end
end
