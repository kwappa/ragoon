#
# Workflow API Service
# https://cybozudev.zendesk.com/hc/ja/articles/202270284
#
class Ragoon::Services::Workflow < Ragoon::Services

  #
  # for admin only
  #

  def workflow_get_requests(request_form_id:, **options)
    action_name = 'WorkflowGetRequests'

    options[:request_form_id] = request_form_id
    [ :start_request_date, :end_request_date,
      :start_approval_date, :end_approval_date ].each do |key|
      options[key] = to_datetime(options[key]) if options.has_key?(key)
    end

    body_node = Ragoon::XML.create_node(action_name)
    parameter_node = Ragoon::XML.create_node('parameters')
    body_node.add_child(parameter_node)

    manage_parameter_node = Ragoon::XML.create_node(
      'manage_request_parmeter', options)
    parameter_node.add_child(manage_parameter_node)

    client.request(action_name, body_node)

    client.result_set.xpath('//manage_item_detail').map do |item|
      {
        id: item[:pid],
        number: item[:number],
        priority: item[:priority],
        subject: item[:subject],
        status: item[:status],
        applicant: item[:applicant], # user_id
        last_approver: item[:last_approver],
        request_date: parse_time(item[:request_date]),
      }
    end
  ensure
    client.reset
  end

  def workflow_get_requests_by_id(ids)
    action_name = 'WorkflowGetRequestById'

    body_node = Ragoon::XML.create_node(action_name)
    parameter_node = Ragoon::XML.create_node('parameters')
    body_node.add_child(parameter_node)

    ids.each do |id|
      request_id_node = Ragoon::XML.create_node('request_id')
      request_id_node.content = id
      parameter_node.add_child(request_id_node)
    end

    client.request(action_name, body_node)

    client.result_set.xpath('//application').map do |app|
      parse_application(app)
    end
  ensure
    client.reset
  end

  #
  # unprocessed
  #

  def workflow_get_unprocessed_application_versions(id_versions = [])
    get_application_versions(
      'WorkflowGetUnprocessedApplicationVersions',
      nil, nil,
      id_versions
    )
  end

  def workflow_get_unprocessed_applications_by_id(ids)
    get_applications_by_id('WorkflowGetUnprocessedApplicationsById', ids)
  end

  #
  # sent
  #

  def workflow_get_sent_application_versions(id_versions = [], start_date:, end_date: nil)
    get_application_versions(
      'WorkflowGetSentApplicationVersions',
      start_date, end_date,
      id_versions
    )
  end

  def workflow_get_sent_applications_by_id(ids)
    get_applications_by_id('WorkflowGetSentApplicationsById', ids)
  end

  #
  # recieved
  #

  def workflow_get_received_application_versions(id_versions = [], start_date:, end_date: nil)
    get_application_versions(
      'WorkflowGetReceivedApplicationVersions',
      start_date, end_date,
      id_versions
    )
  end

  def workflow_get_received_applications_by_id(ids)
    get_applications_by_id('WorkflowGetReceivedApplicationsById', ids)
  end

  private

  def get_application_versions(action_name, start_date, end_date, id_versions)
    body_node = Ragoon::XML.create_node(action_name)

    attributes = {}
    attributes['start'] = to_datetime(start_date) unless start_date.nil?
    attributes['end'] = to_datetime(end_date) unless end_date.nil?
    parameter_node = Ragoon::XML.create_node('parameters', attributes)
    body_node.add_child(parameter_node)

    id_versions.each do |item|
      parameter_node << Ragoon::XML.create_node(
        'application_item',
        id: item[:id], version: item[:version]
      )
    end

    client.request(action_name, body_node)

    client.result_set.xpath('//application_item').map do |item|
      {
        id: item['id'],
        version: item['version'],
        operation: item['operation']
      }
    end
  ensure
    client.reset
  end

  def get_applications_by_id(action_name, ids)
    body_node = Ragoon::XML.create_node(action_name)

    parameter_node = Ragoon::XML.create_node('parameters')
    body_node.add_child(parameter_node)

    ids.each do |id|
      id_node = Ragoon::XML.create_node('application_id')
      id_node.content = id
      parameter_node.add_child(id_node)
    end

    client.request(action_name, body_node)

    client.result_set.xpath('//application').map do |app|
      parse_application(app)
    end
  ensure
    client.reset
  end

  def parse_application(app)
    {
      id: app['id'],
      number: app['number'],
      name: app['name'],
      processing_step: app['processing_step'],
      status: app['status'],
      urgent: app['urgent'],
      version: app['version'],
      date: parse_time(app['date']),
      status_type: app['status_type'],

      applicant: app.xpath('wf:applicant', wf: 'http://schemas.cybozu.co.jp/workflow/2008').map {|applicant|
        {
          id: applicant['id'],
          name: applicant['name']
        }
      }.first,

      items: app.xpath('wf:items/wf:item', wf: 'http://schemas.cybozu.co.jp/workflow/2008').map {|item|
        {
          name: item['name'],
          value: item['value']
        }
      },

      steps: app.xpath('wf:steps/wf:step', wf: 'http://schemas.cybozu.co.jp/workflow/2008').map {|step|
        {
          id: step['id'],
          name: step['name'],
          type: step['type'],
          is_approval_step: step['is_approval_step'],
          processors: step.xpath('wf:processor', wf: 'http://schemas.cybozu.co.jp/workflow/2008').map {|pro|
            {
              id: pro['id'],
              name: pro['processor_name'],
              comment: pro['comment']
            }
          }
        }
      }
    }
  end

  def parse_time(time)
    Time.parse(time).localtime
  end

  def to_datetime(str)
    str.utc.strftime('%FT%TZ')
  end

end
