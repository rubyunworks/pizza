module EntropicCompression

  # Binary pseudo-random iterator.
  class Rb

    attr :seed

    attr :length

    attr :cache

    def initialize(seed, length)
      @seed   = seed
      @length = length

      #@cache  = []
    end

    def [](i)
      srand(i * seed)
      e = "%#{length}s" % [rand(2**length).to_s(2)]
      e = e.gsub(' ', '0')
    end

    # Returns matching index.
    def index(pattern)
      i, c = 0, self[0]
      until c == pattern
        i += 1
        c = self[i]
      end
      return i
    end

    # Returns a float betwee 0 and 1.
    #   0 less random
    #   1 more random
    def randomness?(i)
      entropy_halves(i) * 0.7 + entropy_sparse(i) * 0.3
    end

    #
    def entropy_sparse(i)
      f = 0.0
      self[i].scan('01'){ f += 1 }
      f / (length / 2)
    end

    #
    def entropy_halves(i)
      r0, r1 = 0, 0
      self[i].scan('0'){ r0 += 1 }
      self[i].scan('1'){ r1 += 1 }
      d = (r0 - r1).abs
      return 1 if d == 0
      return (length - d).to_f / length
    end

    #
    def encode(pattern)
      raise ArgumentError unless pattern.size == length
      pattern = pattern.gsub('.', '0').gsub('#', '1')
      index(pattern)
    end

    #
    def bounds(i)
      c = randomness?(i)
      q = i
      until(randomness?(q) < c || q == (i + 1000))  # TODO: what limit?
        q += 1
      end
      e = q
      q = i
      until(randomness?(q) < c || q == 0)
        q -= 1
      end
      b = q
      return(b..e)
    end

    #def to_s
    #  s = ''
    #  @cache.each_with_index{ |e, i| s << "%3d %s\n" % [i, e] }
    #  s
    #end

    def zone(i)
      bounds(i).map do |x|
        [x, self[x], randomness?(x)]
      end
    end

  end

end

