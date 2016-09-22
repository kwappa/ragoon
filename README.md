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

### Workflow

```
service = Ragoon::Services::Workflow.new
service.workflow_get_requests(
  request_form_id: 41,
  filter: 'All',
  start_request_date:  Time.new(2011,  6, 19, 13, 30),
  end_request_date:    Time.new(2014, 12,  1, 19, 50),
  start_approval_date: Time.new(2011,  6,  1, 19, 40),
  end_approval_date:   Time.new(2014, 12, 31,  9, 45),
  applicant:           14,
  last_approval:       6,
  start_to_get_information_from: 2,
  maximum_request_amount_to_get: 10
)

=> [
{:id=>"33",
  :number=>"33",
  :priority=>"0",
  :subject=>"12月7日休日出勤",
  :status=>"承認",
  :applicant=>"14",
  :last_approver=>"6",
  :request_date=>2014-12-01 19:40:26 +0900}
]

service.workflow_get_requests_by_id([33])

=> [
 {:id=>"33",
  :number=>"33",
  :name=>"休日出勤申請（12月7日休日出勤）",
  :processing_step=>"97",
  :status=>"承認",
  :urgent=>"false",
  :version=>"1417430538",
  :date=>2014-12-01 19:40:26 +0900,
  :status_type=>"approved",
  :applicant=>{:id=>"14", :name=>"松田 環奈"},
  :items=>
   [{:name=>"社員番号", :value=>"3110342"}],
  :steps=>
   [{:id=>"97",
     :name=>"経理担当者",
     :type=>"回覧",
     :is_approval_step=>"0",
     :processors=>
      [{:id=>"13", :name=>"加藤 美咲", :comment=>nil}]}]}
]

service.workflow_get_sent_application_versions([
    {id: 23, version: 1306486544},
    {id: 20, version: 1306486544},
    {id: 22, version: 1306486533},
  ],
  start_date: Time.new(2011, 5, 25, 18, 50),
  end_date:   Time.new(2011, 6, 26, 18,  0)
)

=> [
 {:id=>"22", :version=>"1306486534", :operation=>"modify"},
 {:id=>"23", :version=>"0", :operation=>"remove"},
 {:id=>"21", :version=>"1415185979", :operation=>"add"}
]

service.workflow_get_sent_applications_by_id([21])

=> [{:id=>"21",
  :number=>"21",
  :name=>"休日出勤申請（休日出勤申請）",
  :processing_step=>"65",
  :status=>"承認",
  :urgent=>"false",
  :version=>"1415185979",
  :date=>2011-05-27 16:10:41 +0900,
  :status_type=>"approved",
  :applicant=>{:id=>"6", :name=>"佐藤 昇"},
  :items=>
   [{:name=>"社員番号", :value=>"3110334"}],
  :steps=>
   [{:id=>"63",
     :name=>"部長",
     :type=>"承認（全員）",
     :is_approval_step=>"1",
     :processors=>[{:id=>"6", :name=>"佐藤 昇", :comment=>nil}]}]}]
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
