class Hobson::Project::TestRuntimes < Hobson::RedisHash

  MAX_REMEMBERED_RUNTIMES =  10

  attr_reader :project

  include Enumerable

  def initialize project
    @project = project
    super project.redis, :test_runtimes
  end

  # test_runtimes['foo_spec.rb'] # => #<Runtimes foo_spec.rb 76.0 [12, 100, 100, 100, 88.0, 56.0]>
  def [] test_name
    Runtimes.new(self, test_name, super || [])
  end

  def each &block
    keys.map{|key| self[key] }.each(&block)
  end

  class Runtimes < Struct.new(:test_runtimes, :test_name, :runtimes)

    include Enumerable

    def to_a
      runtimes.clone
    end

    def each &block
      to_a.each(&block)
    end

    private :runtimes

    def average
      @average ||= runtimes.size > 0.0 ? runtimes.sum / runtimes.size : 0.0
    end
    alias_method :to_f, :average

    def to_i
      to_f.to_i
    end

    def << runtime
      @runtimes = (test_runtimes.get(test_name) || []) + [runtime.to_f]
      @runtimes = @runtimes.last(MAX_REMEMBERED_RUNTIMES)
      test_runtimes[test_name] = @runtimes
    end

    def inspect
      "#<#{self.class} #{test_name} #{average} #{runtimes.inspect}>"
    end
    alias_method :to_s, :inspect
  end

end