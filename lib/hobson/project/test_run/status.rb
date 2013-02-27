class Hobson::Project::TestRun

  extend Hobson::Landmarks
  landmark :created, :enqueued_build, :started_building, :enqueued_jobs, :errored, :aborted

  def status
    complete? ?
      errored?           ? 'errored'             :
      aborted?           ? 'aborted'             :
      hung?              ? 'hung'                :
      failed?            ? 'failed'              :
      passed?            ? 'passed'              :
    'complete' :
    running?             ? 'running tests'       :
    enqueued_jobs?       ? 'waiting to be run'   :
    started_building?    ? 'building'            :
    enqueued_build?      ? 'waiting to be built' :
    'waiting...'
  end

  alias_method :abort!,     :aborted!
  alias_method :started?,   :enqueued_jobs?
  alias_method :started_at, :enqueued_jobs_at

  def should_abort?
    # bypass the redis_hash cache and check if we've been aborted
    # or if anything errored anywhere
    redis_hash.get('aborted_at').present? || redis_hash.get('errored_at').present?
  end

  def running?
    started? && (jobs.any?(&:running?) && !jobs.all?(&:complete?))
  end

  def errored?
    errored_at.present? || jobs.any?(&:errored?)
  end

  def complete?
    started? && (aborted? || errored? || jobs.all?(&:complete?))
  end

  def complete_at
    jobs.map(&:complete_at).compact.max if complete?
  end

  def done_running_tests?
    started? && tests.none?(&:needs_run?)
  end

  def passed?
    done_running_tests? && tests.all?(&:pass?)
  end

  def failed?
    done_running_tests? && tests.any?{|t| !t.pass? }
  end

  def hung?
    done_running_tests? && tests.any?(&:hung?)
  end

  def requested_by_ci?
    ci_project_ref.present?
  end

end
