class Ragoon::Services::Notification < Ragoon::Services
  RETRIEVE_OPTIONS = {
    date:       Date.today,
    module_ids: %w[grn.schedule grn.workflow],
  }.freeze

  def retrieve(options = {})
    options = RETRIEVE_OPTIONS.dup.merge(options)
    results = options[:module_ids].each_with_object({}) do |module_id, result|
      result[module_id] = notification_get_notification_versions(module_id, options[:date])
      client.reset
    end

    items = results.each_with_object([]) do |(module_id, notifications), result|
      notifications.xpath('//notification_item').each do |notification|
        result.push(
          {
            module_id: module_id,
            item: notification.xpath('notification_id').first[:item]
          }
        )
      end
    end

    notifications = notification_get_notifications_by_id(items)
    first_item = notifications.xpath('//notification').first
    return [] if first_item.nil?
    keys = first_item.attributes.keys.map(&:to_sym)

    notifications.xpath('//notification').each_with_object([]) do |notification, result|
      result.push(
        keys.each_with_object({}) { |key, hash| hash[key] = notification[key] }
      )
    end
  end

  def notification_get_notification_versions(module_id, date)
    action_name = 'NotificationGetNotificationVersions'
    body_node   = Ragoon::XML.create_node(action_name)
    target_date = Ragoon::Services.start_and_end(date)

    parameter_node = Ragoon::XML.create_node(
      'parameters',
      start:     target_date[:start].strftime('%FT%T'),
      end:       target_date[:end].strftime('%FT%T'),
      module_id: module_id,
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
          item:      notification_item[:item]
        )
      )
    end

    body_node.add_child(parameter_node)

    client.request(action_name, body_node)
    client.result_set
  end
end
