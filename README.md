# Ragoon

[![Build Status](https://travis-ci.org/kwappa/ragoon.svg?branch=master)](https://travis-ci.org/kwappa/ragoon)

Ragoon is simple Garoon 3 API Client.

- https://cybozudev.zendesk.com/hc/ja/categories/200157760-Garoon-API

## Usage

### Schedule

```
service = Ragoon::Services::Schedule.new
events = service.schedule_get_events

=> [
{:id=>"1334236", :url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/schedule/view?event=1334236", :title=>"ログ収集システムについて", :start_at=>"2016-01-15 13:30:00 +0900", :end_at=>"2016-01-15 14:00
:00 +0900", :plan=>"社内MTG", :facilities=>["会議室 12-8"], :private=>true, :allday=>false},
{:id=>"1336040", :url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/schedule/view?event=1336040", :title=>"スプリントMTG", :start_at=>"2016-01-15 14:00:00 +0900", :end_at=>"2016-01-15 15:00:00
+0900", :plan=>"社内MTG", :facilities=>["会議室 13-e","会議室 13-f"], :private=>false, :allday=>false},
]

service.schedule_add_event(
  title: 'プロジェクトキックオフ',
  description: '新規プロジェクト概要説明',
  start_at: Time.new(2016, 1, 15, 13, 0),
  end_at: Time.new(2016, 1, 15, 13, 30),
  plan: '社内MTG',
  users: [1],
  private: false,
  allday: false
)

=> {:id=>"1338211", :url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/schedule/view?event=1338211", :title=>"プロジェクトキックオフ", :start_at=>"2016-01-15 13:00:00 +0900", :end_at=>"2016-01-15 13:30:00+0900", :plan=>"社内MTG", :facilities=>[], :users=>[{:id => 1, :name => "田中　太郎"}], :private=>false, :allday=>false}
```

### Notification

```
service = Ragoon::Services::Notification.new
notifications = service.retreive

=> [
{:module_id=>"grn.schedule",
:item=>"1336866",
:status=>"update",
:is_history=>"true",
:version=>"1452843025",
:read_datetime=>"2016-01-15T07:30:25Z",
:receive_datetime=>"2016-01-15T07:30:25Z",
:subject=>"17:00 社内MTG:技術部定例",
:subject_url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/schedule/view?uid=3436&event=1336866&bdate=2016-01-15&nid=3912164",
:abstract=>"変更",
:abstract_url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/schedule/view?uid=3436&event=1336866&bdate=2016-01-15&nid=3912164",
:sender_name=>"岡部 倫太郎",
:sender_id=>"1189",
:sender_url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/grn/user_view?uid=1189",
:attached=>"false"},
{:module_id=>"grn.workflow",
:item=>"181876",
:status=>"create",
:is_history=>"true",
:version=>"1452855447",
:read_datetime=>"2016-01-15T10:57:27Z",
:receive_datetime=>"2016-01-15T10:57:27Z",
:subject=>"本番環境サイトID発行申請",
:subject_url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/workflow/handle?fid=12762&pid=181876&nid=3914948",
:abstract=>"【共通】アカウントセンター認証インターフェース利用申請",
:abstract_url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/workflow/handle?fid=12762&pid=181876&nid=3914948",
:sender_name=>"橋田 至",
:sender_id=>"1358",
:sender_url=>"https://example.co.jp/cgi-bin/cbgrn/grn.cgi/grn/user_view?uid=1358",
:attached=>"false"}
]
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
