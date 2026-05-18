# frozen_string_literal: true

require "test_helper"

module BPMN
  describe :extensions do
    let(:sources) { fixture_source("extension_elements_test.bpmn") }
    let(:context) { BPMN::Context.new(sources) }

    describe :definition do
      let(:process) { context.process_by_id("ZeebeExtensionsTest") }
      let(:start_event) { process.element_by_id("Start") }
      let(:user_task) { process.element_by_id("UserTask") }
      let(:user_task_form_id) { process.element_by_id("UserTaskFormID") }
      let(:user_task_external) { process.element_by_id("UserTaskExternal") }
      let(:business_rule_task) { process.element_by_id("BusinessRuleTask") }
      let(:service_task) { process.element_by_id("ServiceTask") }
      let(:script_task) { process.element_by_id("ScriptTask") }
      let(:call_activity) { process.element_by_id("CallActivity") }
      let(:end_event) { process.element_by_id("End") }

      describe :assignment_definition do
        let(:assignment_definition) { user_task.extension_elements.assignment_definition }

        it "should parse the assignment definition" do
          _(assignment_definition.assignee).must_equal "bill@somewhere.com"
          _(assignment_definition.candidate_groups).must_equal "maintenance"
          _(assignment_definition.candidate_users).must_equal "bill@somewhere.com jill@somewhere.com"
        end
      end

      describe :called_element do
        let(:called_element) { call_activity.extension_elements.called_element }

        it "should parse the called element" do
          _(called_element.process_id).must_equal "CallActivityCalleeTest"
          _(called_element.propagate_all_child_variables).must_equal false
        end
      end

      describe :called_decision do
        let(:called_decision) { business_rule_task.extension_elements.called_decision }

        it "should parse the called decision" do
          _(called_decision.decision_id).must_equal "ChooseGreeting"
          _(called_decision.result_variable).must_equal "greeting"
        end
      end

      describe :form_definition_job_worker do
        let(:form_definition) { user_task.extension_elements.form_definition }

        it "should parse the job worker form definition" do
          _(form_definition.form_key).must_equal "some_form"
        end
      end

      describe :form_definition_camunda_form do
        let(:form_definition_form_id) { user_task_form_id.extension_elements.form_definition }
        let(:form_definition_external) { user_task_external.extension_elements.form_definition }

        it "should parse the camunda form definition" do
          _(form_definition_form_id.form_id).must_equal "form_id"
          _(form_definition_external.external_reference).must_equal "external_reference"
        end
      end

      describe :io_mapping do
        let(:io_mapping) { service_task.extension_elements.io_mapping }

        describe :inputs do
          let(:inputs) { io_mapping.inputs }

          it "should parse inputs" do
            _(inputs.size).must_equal 1
            _(inputs.first.source).must_equal "=first_name + \" \" + last_name"
            _(inputs.first.target).must_equal "name"
          end
        end

        describe :outputs do
          let(:outputs) { io_mapping.outputs }

          it "should parse outputs" do
            _(outputs.size).must_equal 1
            _(outputs.first.source).must_equal "=response.body.fortune"
            _(outputs.first.target).must_equal "fortune"
          end
        end
      end

      describe :properties do
        let(:properties) { start_event.extension_elements.properties }

        it "should parse properties" do
          _(properties.keys.size).must_equal 1
          _(properties["camundaModeler:exampleOutputJson"]).must_equal "{ \"greeting\": \"Hello\" }"
        end
      end

      describe :script do
        let(:script) { script_task.extension_elements.script }

        it "should parse the form definition" do
          _(script.expression).must_equal "=\"Hello \" + name + \" \" + fortune"
        end
      end

      describe :task_definition do
        let(:task_definition) { service_task.extension_elements.task_definition }

        it "should parse the form definition" do
          _(task_definition.type).must_equal "service_type"
        end
      end

      describe :task_schedule do
        let(:task_schedule) { user_task.extension_elements.task_schedule }

        it "should parse the form definition" do
          _(task_schedule.due_date).must_equal "=now() + duration(\"PT8H\")"
          _(task_schedule.follow_up_date).must_equal "=now() + duration(\"PT2D\")"
        end
      end
    end
  end
end
