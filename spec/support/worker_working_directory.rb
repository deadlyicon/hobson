require File.expand_path('../working_directory', __FILE__ )

module WorkerWorkingDirectory

  extend WorkingDirectory
  extend self

  def path
    TMP + 'worker_working_directory'
  end

  def config_path
    path + 'config.yml'
  end

  def projects_path
    path + 'projects'
  end

  def example_project_path
    projects_path + 'example_hobson_project'
  end

  def example_project_current_sha
    git('rev-parse HEAD').split("\n").last
  end

  def reset!
    projects_path.mkpath unless projects_path.exist?
    write_config! DEFAULT_CONFIG
    git "reset --hard origin/master"
    git "clean -df"
    git("config --get remote.origin.url").chomp.should == ExampleProject::ORIGIN
  end

  def git cmd
    sh "git clone #{ExampleProject::ORIGIN} #{example_project_path}" unless example_project_path.exist?
    sh %[cd "#{example_project_path}" && git --git-dir="#{example_project_path+'.git'}" #{cmd}]
  end

end
