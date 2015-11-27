# Ragoon

Ragoon is simple Garoon 3 API Client.

- https://cybozudev.zendesk.com/hc/ja/categories/200157760-Garoon-API

## Usage

```
service = Ragoon::Services::Schedule.new
events = service.schedule_get_event

=> [
  {:title=>"予定あり", :period=>"13:00〜14:00", :plan=>"作業", :facility=>""},
  {:title=>"セクションMTG", :period=>"15:00〜15:30", :plan=>"社内MTG", :facility=>["会議室"]},
  {:title=>"予定あり", :period=>"終日", :plan=>"", :facility=>""}
]

```
## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
