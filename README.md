# WebAuthn Passkey 検証用リポジトリ

Rails 8 + Devise + WebAuthn を使用したパスキー認証の検証用プロジェクトです。

## 技術スタック

- Ruby on Rails 8.1.1
- PostgreSQL
- Devise(ユーザー認証)
- webauthn gem(パスキー実装)
- Propshaft(アセットパイプライン)
- Importmap(JavaScript管理)

## 機能

- パスキー(WebAuthn)による登録・認証
- Deviseとの統合
- 複数パスキーの登録対応

## セットアップ

### インストール

```bash
# 依存関係のインストール
bundle install

# データベースの作成、マイグレーション
bundle exec rails db:create
bundle exec rails db:migrate

# サーバー起動
bundle exec rails s -b 0.0.0.0 -p 3000
```

## アーキテクチャ

### データベース構成

```
users
├── id
├── email
├── webauthn_id(WebAuthn用識別子)
└── ...(Devise標準カラム)

credentials
├── id
├── user_id(FK)
├── external_id(認証器ID)
├── public_key(公開鍵)
├── sign_count(署名カウンター)
└── friendly_name(認証器の名前)
```

### 認証フロー

```
[パスキー登録]
ユーザーログイン → 登録画面 → Challenge生成 → 認証器登録 → Credential保存

[パスキー認証]
メールアドレス入力 → Challenge生成 → 認証器認証 → 検証 → セッション確立
```

## 参考資料

- [WebAuthn Guide](https://webauthn.guide/)
- [webauthn-ruby gem](https://github.com/cedarcode/webauthn-ruby)
- [Devise](https://github.com/heartcombo/devise)
