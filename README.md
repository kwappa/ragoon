# Ragoon

Ragoon is simple Garoon 3 API Client.

- https://cybozudev.zendesk.com/hc/ja/categories/200157760-Garoon-API

## Usage

```
service = Ragoon::Services::Schedule.new
events = service.schedule_get_event

=> [
  {:title=>"セクションMTG", :start_at=>"2015-11-29 15:00:00 +0900", :end_at=>"2015-11-29 15:30:00 +0900", :plan=>"社内MTG", :facilities=>["会議室1"], :private=>true, :allday=>false},
  {:title=>"エンジニア共有会", :start_at=>"2015-11-29 16:00:00 +0900", :end_at=>"2015-11-29 16:30:00 +0900" :plan=>"社内MTG", :facilities=>["会議室1", "会議室2"], :private=>true, :allday=>false},
  {:title=>"監査対応", :start_at=>nil, :end_at=>nil, :plan=>"作業", :facilities=>[], :private=>false, :allday=>true}
]

```
## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
