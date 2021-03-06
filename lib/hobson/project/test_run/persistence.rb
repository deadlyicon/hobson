class Hobson::Project::TestRun

  MAX_AGE = 172800 # 2 days

  delegate :redis, :to => :project
  delegate :[], :[]=, :keys, :to => :redis_hash

  def redis_key
    "TestRun:#{id}"
  end

  def redis_hash
    @redis_hash ||= Hobson::RedisHash.new(redis, redis_key)
  end

  def save!
    created!
    project.redis.zadd(:test_runs, created_at.to_f, id)
    redis_hash.redis.expire(redis_hash.key, MAX_AGE) unless requested_by_ci?
  end

  def delete!
    project.redis.zrem(:test_runs, id)
    redis.del(redis_key)
    true
  end

  def reload!
    project, id = @project, @id
    instance_variables.each{|iv| instance_variable_set(iv, nil) }
    @project, @id = project, id
    self
  end

  def new_record?
    redis.type(redis_key) == "none"
  end

  def data
    redis_hash.to_hash
  end

  %w{sha requestor ci_project_ref_id fast_lane number_of_jobs}.each do |attribute|
    class_eval <<-RUBY, __FILE__, __LINE__
      def #{attribute}
        self[:#{attribute}]
      end

      def #{attribute}= value
        self[:#{attribute}] = value
      end
    RUBY
  end

  alias_method :fast_lane?, :fast_lane

  def ci_project_ref
    @ci_project_ref ||= Hobson::CI::ProjectRef.find(ci_project_ref_id) if ci_project_ref_id.present?
  end

  def ci_project_ref= ci_project_ref
    @ci_project_ref = ci_project_ref
    self.ci_project_ref_id = ci_project_ref.id
  end

end
