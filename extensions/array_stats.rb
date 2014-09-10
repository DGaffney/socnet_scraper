# encoding: UTF-8
##
# Statistics methods inherited from tons of different projects
module ArrayStats
  ##
  # http://en.wikipedia.org/wiki/Median
  def median
    return nil if self.empty?
    self.sort!
    if self.length % 2 == 0
      return (self.at_halfway + self[self.halfway - 1]) / 2.0
    else
      return self.at_halfway
    end
  end
  
  ##
  # Halfway through a set - not a median (and nothing here is requiring the set to be sorted)
  def at_halfway
    self[halfway]
  end

  ##
  # The halfway index
  def halfway
    self.length / 2
  end

  ##
  # ∑
  def sum
    return self.collect(&:to_f).inject(0){|acc,i|acc +i}
  end

  ##
  # http://en.wikipedia.org/wiki/Average
  def average
    return self.empty? ? 0 : self.sum/self.length.to_f
  end

  ##
  # A metric necessary in assessing the std dev of a set - it's the sqrt of the sample variance. Get your learn on: http://en.wikipedia.org/wiki/Variance
  def sample_variance
    avg=self.average
    sum=self.inject(0){|acc,i|acc +(i-avg)**2}
    return(1/self.length.to_f*sum)
  end

  ##
  # Return the standard deviation of a set of data. I know you're going to abuse this, but you should know that standard deviations only mean something if the distribution is normal. Otherwise, this is lying to you and you are lying to others when you use it.
  def standard_deviation
    return 0 if self.empty?
    return Math.sqrt(self.sample_variance)
  end

  ##
  # Standardize the set - convert the set from the values to the number of standard deviations each datapoint is.
  def standardize
    return self if self.uniq.length == 1
    stdev = self.standard_deviation
    mean = self.average
    self.collect do |val|
      (val-mean)/stdev
    end
  end

  ##
  # Return a hash that assesses the number of instances of each value in the set.
  def counts
    self.inject(Hash.new(0)) do |hash,element|
      hash[element] += 1
      hash
    end
  end

  ##
  # return the point at which the elbow occurs - only intended for highly skewed datasets. Get learned: http://stackoverflow.com/questions/2018178/finding-the-best-trade-off-point-on-a-curve
  def elbow_cutoff
    frequencies = self.counts
    distances = {}
    frequencies.each_pair do |insider_score, count|
      index = frequencies.keys.sort.index(insider_score)
      translated_x = insider_score/frequencies.keys.max.to_f
      translated_y = 1-translated_x
      expected_x = index/frequencies.length.to_f
      expected_y = 1-expected_x
      distances[insider_score] = Math.sqrt((translated_x-expected_x)**2+(translated_y-expected_y)**2)
    end
    elbow = distances.sort_by{|k,v| v}.last
    return 0 if elbow.nil?
    return elbow.first
  end
  
  ##
  # 80/20 principle. But 90/10.
  def pareto_cutoff
    #our world is a bit more unfair. 0.8 moved to 0.9.
    self.percentile(0.9)
  end
  
  ##
  # Return the value present at a given percentile. 1 will return max, 0 will return min, and anything in between chooses the nearest value, skewing to the left
	def percentile(percentile=0.0)
	  if percentile == 0.0
	    return self.sort.first
    else
      if elems_are_enumerable
        return self[((self.length * percentile).ceil)-1]
      else
        return self ? self.sort[((self.length * percentile).ceil)-1] : nil rescue nil
      end
    end
  end

  ##
  # Helper
  def enumerable_combinations
    [["Array", "Hash"], ["Array"], ["Hash"]]
  end
  
  ##
  # Are the elements in the array themselves enumerable elements like hashes and arrays?
  def elems_are_enumerable
    enumerable_combinations.include?(self.collect(&:class).uniq.collect(&:to_s).sort)
  end

  ##
  # Return the percentile of a hypothetical value for the set. eg [1,2,3].reverse_percentile(2) => 0.33333333
	def reverse_percentile(value=0.0)
	  return nil if self.empty?
    index_value = nil
    self.collect(&:to_f).sort.each do |val|
      index_value = val;break if value <= val
    end
    return (self.index(index_value)/self.length.to_f)
  end
  
  ##
  # The most frequently occurring value in the set
  def mode
    freq = self.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
    self.sort_by { |v| freq[v] }.last
  end
  
  ##
  # Return a hash of all the summary stats for the set. Super useful for quickly getting the gist of a set.
  def all_stats
    summary_statistics = {}
    summary_statistics[:min] = self.min
    summary_statistics[:first_quartile] = self.percentile(0.25)
    summary_statistics[:second_quartile] = self.percentile(0.5)
    summary_statistics[:third_quartile] = self.percentile(0.75)
    summary_statistics[:max] = self.max
    summary_statistics[:median] = self.median 
    summary_statistics[:mode] = self.mode
    summary_statistics[:mean] = self.average
    summary_statistics[:standard_deviation] = self.standard_deviation
    summary_statistics[:sum] = self.sum
    summary_statistics[:sample_variance] = self.sample_variance
    summary_statistics[:elbow] = self.elbow
    summary_statistics[:n] = self.length
    summary_statistics
  end

  ##
  # Normalize the set into a set from 0 to 1
  def normalize(min=0, max=1)
    current_min = self.min.to_f
    current_max = self.max.to_f
    res = self.map {|n| val = (min + (n - current_min) * (max - min) / (current_max - current_min));val.is_nan? ? 0 : val}
  end
  
  ##
  # Return the ranking of a hypothetical value - eg, [1,2,3,4,5].rank(2) => 4 since 2 is the fourth highest value possible given that set and that value.
  def rank(number)
    ranking = 1
    self.sort.reverse.each do |val|
      break if val <= number
      ranking += 1
    end
    return ranking
  end
  alias :elbow :elbow_cutoff  
  
  def top(n=20)
    Hash[self.counts.sort_by{|k,v| v}.reverse].keys.first(n)
  end
end

class Array
  include ArrayStats
end
