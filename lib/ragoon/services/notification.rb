class Ragoon::Services::Notification < Ragoon::Services
  def notification_get_notification_versions
    action_name = 'NotificationGetNotificationVersions'
    body_node = Ragoon::XML.create_node(action_name)
    today = Ragoon::Services.start_and_end

    parameter_node = Ragoon::XML.create_node(
      'parameters',
      start:     today[:start].strftime('%FT%T'),
      end:       today[:end].strftime('%FT%T'),
      module_id: 'grn.schedule',
    )

    body_node.add_child(parameter_node)

    client.request(action_name, body_node)
    client.result_set
  end

  def notification_get_notifications_by_id(notification_items)
    action_name = 'NotificationGetNotificationsById'
    body_node = Ragoon::XML.create_node(action_name)
    today = Ragoon::Services.start_and_end

    parameter_node = Ragoon::XML.create_node('parameters')

    notification_items.each do |notification_item|
      parameter_node.add_child(
        Ragoon::XML.create_node(
        'notification_id',
        module_id: notification_item[:module_id],
        item:      notification_item[:item],
      )
      )
    end

    body_node.add_child(parameter_node)

    client.request(action_name, body_node)
    client.result_set
  end
end
