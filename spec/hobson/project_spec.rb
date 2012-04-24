require 'spec_helper'

describe Hobson::Project do

  subject { Factory.project }
  alias_method :project, :subject

  client_context do

    describe "create" do
      it "should discover homepage if origin is a github origin" do
        %w{
          git@github.com:deadlyicon/hobson.git
          git://github.com/deadlyicon/hobson.git
          https://deadlyicon@github.com/deadlyicon/hobson.git
        }.each{|origin|
          project = Hobson::Project.create(origin)
          project.homepage.should == 'https://github.com/deadlyicon/hobson'
          project.delete
        }
      end
    end

    describe "current" do
      it "should default to the name of the given git repo" do
        Hobson::Project.current.origin.should == ExampleProject::ORIGIN
        Hobson::Project.current.name.should == ExampleProject::NAME
        Hobson::Project.current.homepage.should == ExampleProject::HOMEPAGE
      end
    end

    describe "current_origin" do
      it "should return the git origin of the project withing Hobson.root" do
        Hobson::Project.current_origin.should == ExampleProject::ORIGIN
      end
    end


    describe "name_from_origin" do
      it "should convert git origins into project names" do
        %w{
          git@github.com:deadlyicon/hobson.git
          git://github.com/deadlyicon/hobson.git
          https://deadlyicon@github.com/deadlyicon/hobson.git
        }.each{|origin|
          Hobson::Project.name_from_origin(origin).should == 'hobson'
        }
      end
    end

    describe "#run_tests!" do

      it "should return a new Hobson::Project::TestRun pointing at the current sha" do
        test_run = project.run_tests!
        test_run.should be_a Hobson::Project::TestRun
        test_run.sha.should == ClientWorkingDirectory.current_sha
      end

      it "should enqueue 1 Hobson::Project::TestRun::Builder resque job" do
        Resque.should_receive(:enqueue).with(Hobson::Project::TestRun::Builder, ExampleProject::NAME, anything).once
        project.run_tests!
      end

    end

    describe "#workspace" do
      subject{ Factory.project.workspace }
      alias_method :workspace, :subject
      it { should_not exist }
    end

  end

  worker_context do

    describe "#workspace" do
      subject{ Factory.project.workspace }
      alias_method :workspace, :subject

      it { should be_a Hobson::Project::Workspace }
    end

  end

  either_context do

    describe "#redis" do

      subject{ Factory.project.redis }
      alias_method :redis, :subject

      it "should be a namespace" do
        redis.should be_a Redis::Namespace
        redis.should_not == Hobson.redis
        redis.namespace.should == "Project:#{ExampleProject::NAME}"
      end

    end

    describe "#test_runs" do

      it "should return an array of Hobson::Project::TestRun objects" do
        Factory.project.test_runs.should be_an Array
        test_runs = []
        test_runs << project.run_tests!
        Factory.project.test_runs.map(&:id).to_set.should == test_runs.map(&:id).to_set
        test_runs << project.run_tests!
        Factory.project.test_runs.map(&:id).to_set.should == test_runs.map(&:id).to_set
      end

      it "should return a test run when given an id" do
        test_run = project.run_tests!
        project.test_runs(test_run.id).should == test_run
        test_run = project.run_tests!
        project.test_runs(test_run.id).should == test_run
      end

    end

  end

  describe "#current_test_run" do

    it "should return the last test run" do
      Factory.project.current_test_run.should be_nil
      test_run = project.run_tests!
      Factory.project.current_test_run.should == test_run
    end

  end

  # describe "new" do

  #   context "when given no arguments" do

  #     before do
  #       Hobson.stub(:root).and_return(Pathname.new('/home/hobson/'))
  #       Hobson::Project.stub(:current_project_name).and_return('example_project')
  #       Hobson::Project.stub(:current_sha).and_return('5f0413d2a055f9ab69c4eb4c14a937c1869d60b7')
  #     end

  #     subject { Hobson::Project.new }

  #     it "should default to the name of the given git repo" do
  #       project.name.should == 'example_project'
  #     end

  #     it "should have a workspace" do
  #       project.workspace.should be_a Hobson::Project::Workspace
  #       project.workspace.root.should == Pathname.new('/home/hobson/projects/example_project')
  #     end

  #   end
  # end

  # describe "#redis" do

  #   subject{ Hobson::Project.new.redis }
  #   alias_method :redis, :subject

  #   it "should be in a namespace" do
  #     debugger;1
  #     redis.should be_a Redis::Namespace
  #     redis.should_not == Hobson.redis
  #     redis.namespace.should == "Project:#{WorkerHobsonDir::EXAMPLE_PROJECT_NAME}"
  #   end

  # end

  # describe "#run_tests!" do

  #   it "should return a new Hobson::Project::TestRun pointing at the current sha" do
  #     test_run = Hobson::Project.new.run_tests!
  #     test_run.should be_a Hobson::Project::TestRun
  #     test_run.sha.should == WorkerHobsonDir.current_sha
  #   end

  #   it "should enqueue 1 Hobson::BuildTestRun resque job" do
  #     Resque.should_receive(:enqueue).with(Hobson::BuildTestRun, 'random_project', anything).once
  #     Hobson::Project.new('random_project').run_tests!
  #   end

  # end

  # describe "#test_runs" do

  #   it "should return an array of Hobson::Project::TestRun objects" do

  #     Hobson::Project.new.test_runs.should be_an Array
  #     test_runs = []
  #     test_runs << project.run_tests!
  #     Hobson::Project.new.test_runs.should == test_runs.sort_by(&:id)
  #     test_runs << project.run_tests!
  #     Hobson::Project.new.test_runs.should == test_runs.sort_by(&:id)
  #   end

  #   it "should return a test run when given an id" do
  #     test_run = project.run_tests!
  #     project.test_runs(test_run.id).should == test_run
  #     test_run = project.run_tests!
  #     project.test_runs(test_run.id).should == test_run
  #   end

  # end

  # # it "should debug" do
  # #   debugger;1
  # # end

end
