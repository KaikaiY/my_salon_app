# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...




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

