# frozen_string_literal: true

require "test_helper"

module BPMN
  describe "Repeating Task" do
    let(:sources) { fixture_source("repeat_task_test.bpmn") }
    let(:context) { BPMN.new(sources) }

    describe :definition do
      let(:process) { context.process_by_id("RepeatTaskTest") }
      let(:task) { process.element_by_id("Task") }
      let(:gateway) { process.element_by_id("Gateway") }

      it "should parse the process" do
        _(task).wont_be_nil
        _(gateway).wont_be_nil
      end
    end

    describe :execution do
      before { @execution = context.start }

      let(:execution) { @execution }
      let(:task_executions) { execution.children.select { |child| child.step.id == "Task" } }

      it "should wait at the task" do
        _(execution.ended?).must_equal false
        _(execution.waiting_tasks.length).must_equal 1
        _(execution.waiting_tasks.first.step.id).must_equal "Task"
      end

      describe :first_completion do
        before { execution.waiting_tasks.first.signal(repeat: true) }

        it "should loop back and wait at the task again" do
          _(execution.ended?).must_equal false
          _(execution.waiting_tasks.length).must_equal 1
          _(execution.waiting_tasks.first.step.id).must_equal "Task"
        end

        it "should preserve history of the first task execution" do
          _(task_executions.length).must_equal 2
          _(task_executions.first.ended?).must_equal true
          _(task_executions.last.waiting?).must_equal true
        end

        describe :second_completion do
          before { execution.waiting_tasks.first.signal(repeat: false) }

          it "should complete the process" do
            _(execution.ended?).must_equal true
          end

          it "should have two completed task executions" do
            _(task_executions.length).must_equal 2
            _(task_executions.all?(&:ended?)).must_equal true
          end
        end
      end
    end
  end

  describe "Repeating with Parallel Gateway" do
    let(:sources) { fixture_source("repeat_parallel_test.bpmn") }
    let(:context) { BPMN.new(sources) }

    describe :execution do
      before { @execution = context.start(variables: { repeat: true }) }

      let(:execution) { @execution }

      it "should wait at both tasks" do
        _(execution.ended?).must_equal false
        _(execution.waiting_tasks.length).must_equal 2
        _(execution.waiting_tasks.map { |t| t.step.id }.sort).must_equal ["TaskA", "TaskB"]
      end

      describe :first_iteration do
        before do
          execution.waiting_tasks.find { |t| t.step.id == "TaskA" }.signal
          execution.waiting_tasks.find { |t| t.step.id == "TaskB" }.signal
        end

        it "should loop back and wait at both tasks again" do
          _(execution.ended?).must_equal false
          _(execution.waiting_tasks.length).must_equal 2
          _(execution.waiting_tasks.map { |t| t.step.id }.sort).must_equal ["TaskA", "TaskB"]
        end

        describe :second_iteration do
          before do
            execution.waiting_tasks.find { |t| t.step.id == "TaskA" }.signal(repeat: false)
            execution.waiting_tasks.find { |t| t.step.id == "TaskB" }.signal
          end

          it "should complete the process" do
            _(execution.ended?).must_equal true
          end

          it "should have two completed executions per task" do
            task_a_executions = execution.children.select { |c| c.step.id == "TaskA" }
            task_b_executions = execution.children.select { |c| c.step.id == "TaskB" }
            _(task_a_executions.length).must_equal 2
            _(task_b_executions.length).must_equal 2
            _(task_a_executions.all?(&:ended?)).must_equal true
            _(task_b_executions.all?(&:ended?)).must_equal true
          end
        end
      end
    end
  end
end
