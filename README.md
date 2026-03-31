# README

# テーブル設計

## users テーブル

| Column             | Type        | Options     |
| ------------------ | ----------- | ----------- |
| email              | string      | null: false, unique: true |
| encrypted_password | string      | null: false |
| name               | string      | null: false |
| role               | integer     | null: false |
| company_id         | references  | null: true, foreign_key: true |
| active             | boolean     | null: false, default: true |

### Association
- belongs_to :company, optional: true
- has_many :created_treatment_days, class_name: "TreatmentDay", foreign_key: :created_by_id
- has_many :assigned_treatment_days, class_name: "TreatmentDay", foreign_key: :therapist_id
- has_many :reservations



## companies テーブル

| Column              | Type        | Options     |
| ------------------- | ----------- | ----------- |
| company_name        | string      | null: false |
| email               | string      | null: false |
| phone               | string      | null: false |
| active              | boolean     | null: false, default: true |

### Association
- has_many :users
- has_many :treatment_days
- has_many :reservations, through: :treatment_days


## treatment_days テーブル

| Column              | Type        | Options     |
| ------------------- | ----------- | ----------- |
| date                | date        | null: false |
| booking_source      | integer     | null: false |
| status              | integer     | null: false |
| note                | text        | null: true  |
| company_id          | references  | null: false, foreign_key: true |
| therapist_id        | references  | null: true, foreign_key: { to_table: :users } |
| created_by_id       | references  | null: false, foreign_key: { to_table: :users } |

### Association
- has_many :time_slots
- belongs_to :company
- belongs_to :therapist, class_name: "User", foreign_key: :therapist_id, optional: true
- belongs_to :created_by, class_name: "User", foreign_key: :created_by_id
- has_many :reservations, through: :time_slots


## time_slots テーブル

| Column              | Type        | Options     |
| ------------------- | ----------- | ----------- |
| start_time          | time        | null: false |
| end_time            | time        | null: false |
| treatment_day_id    | references  | null: false, foreign_key: true |

### Association
- belongs_to :treatment_day
- has_many :reservations


## reservations テーブル

| Column              | Type        | Options     |
| ------------------- | ----------- | ----------- |
| status              | integer     | null: false |
| cancel_reason       | text        | null: true  |
| note                | text        | null: true  |
| user_id             | references  | null: false, foreign_key: true |
| time_slot_id        | references  | null: false, foreign_key: true |

### Association
- belongs_to :user
- belongs_to :time_slot
- has_one :treatment_day, through: :time_slot

## ER図
<img width="926" height="605" alt="Image" src="https://github.com/user-attachments/assets/d471a506-5dfb-4cb3-a719-f7942a5e04d2" />

# 設計ルール

## ユーザー権限
- role は `admin / therapist / company_manager / employee` を想定
- `admin` は company_id を持たない
- `therapist` は company_id を持たない
- `company_manager` は company_id 必須
- `employee` は company_id 必須

## 予約ルール
- 利用者は所属会社の予約枠のみ予約できる
- 1つの `time_slot` に対する予約は1件まで
- キャンセル時は `status` を更新し、必要に応じて `cancel_reason` を保持する
- 予約対象者は `users` テーブルのうち利用者ロールを想定する

## 施術日・時間枠ルール
- `treatment_day` は会社単位で作成する
- `time_slot` は `treatment_day` に紐づく
- `start_time` は `end_time` より前であること
- 同一 `treatment_day` 内で時間枠が重複しないようにする
- `therapist_id` は未割当を許可する

## ステータス管理
- `users.role` は enum で管理する
- `treatment_days.status` は enum で管理する
- `treatment_days.booking_source` は enum で管理する
- `reservations.status` は enum で管理する

## 削除・無効化方針
- ユーザーと会社は原則 `active` で有効/無効を管理する
- 予約実績のあるデータは物理削除を避ける
- 関連データがある場合の削除可否は今後要検討

## 今後詰めること
- status / booking_source の候補値
- 会社責任者が代理予約できるか
- キャンセル済み予約を一意制約の対象外にするか


# Enum定義

## 各種enum
```ruby
# User
enum role: {
  admin: 0,
  therapist: 1,
  company_manager: 2,
  employee: 3
}

# TreatmentDay.booking_source
enum booking_source: {
  app: 0,
  phone: 1,
  email: 2,
  admin_input: 3
}

# TreatmentDay.status
enum status: {
  pending: 0,
  confirmed: 1,
  cancelled: 2
}

# Reservation
enum status: {
  reserved: 0,
  cancelled: 1,
  completed: 2
}


```






# 福利厚生マッサージ予約管理アプリ

## アプリ概要
企業向け福利厚生マッサージの予約を管理するRailsアプリです。  
管理者、施術者、会社責任者、利用者ごとに閲覧できる画面と操作範囲を分けています。

## 想定ユーザー
- 管理者
- 施術者
- 会社責任者
- 利用者

## 主な機能
- 権限別ログイン機能
- 管理者による全体管理
- 施術者による担当予約確認
- 会社責任者による日付予約
- 利用者による時間予約
- 会社ごとの予約データ分離

## 権限
### 管理者
- 全体管理
- 会社・施術者・予約情報の管理

### 施術者
- 自分の担当予約の確認

### 会社責任者
- 自社向け施術日の予約
- 利用状況の確認

### 利用者
- 自社に開放された日付から時間予約

## 使用技術
- Ruby
- Ruby on Rails
- PostgreSQL
- Devise
- Tailwind CSS

## 工夫した点
- roleによる画面制御と認可制御を実装
- company_idを自由入力させず、不正な他社所属登録を防止
- 日付予約と時間予約を分け、企業利用に合わせた予約フローを設計

## 今後の課題
- メール通知機能の追加
- カレンダーUIの改善
- 予約変更・キャンセル機能の強化

<!-- ## セットアップ
```bash
git clone リポジトリURL
cd アプリ名
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails s -->

