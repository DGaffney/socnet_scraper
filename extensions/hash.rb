##
# Helpers
class Hash

  ##
  # For any hash, rescue method missing and see if the method being called is a name of a key either as a string or a symbol, then return the value at that point. This could get you into hot water with calls like #values, which is something you could name, but is already taken, which means that the hash[] syntax would have to be used to get that value out.
  def method_missing(method, *args)
    if method.to_s.split("").last == "="
      self[method.to_s.gsub("=", "").to_sym] = args.first
    else
      if (self.keys|[method.to_s,method]).length != 0
        return self.values_at(method, method.to_s).compact.first
      else
        return nil
      end
    end
  end
  
  ##
  # Turn a nested hash into a flattened hash - pass in a delimiter in the second options hash to change how they look (`{some_nested: {value: 1}}` to `{"some_nested-value" => 1}`)
  def recursive_flatten(output = {}, options = {})
    self.each do |key, value|
      key = options[:prefix].nil? ? "#{key}" : "#{options[:prefix]}#{options[:delimiter]||"_"}#{key}"
      if value.is_a? Hash
        value.recursive_flatten(output, :prefix => key, :delimiter => options[:delimiter]||"_")
      else
        output[key]  = value
      end
    end
    output
  end

end
