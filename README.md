# Rails API Backend with JWT

JWT認証を含めたRailsによるAPIバックエンドの実装である。
テストはRSpecで実装してある。

Minitestテストを含めず、API専用のRailsプロジェクトを作成する。

``` bash
rails new mybackend --api -T
```

Gemfileに以下を記述する。

``` Gemfile
gem 'bcrypt'
gem 'rack-cors'
gem "jwt"
group :development, :test do
  gem "rspec-rails"
end
```

インストールする。

``` bash
bundle install
```

`config/initializer/cors.rb`に以下の内容を記述する。

``` ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "localhoset:3000"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: ["Authorization"]
  end
end
```

RSpecを初期化する。

``` bash
bin/rails generate rspec:install
```

モデル、コントローラを生成する。

```
bin/rails g model User username:string password_digest:string
bin/rails g controller api/v1/Users create
bin/rails g controller api/v1/Sessions create
bin/rails g scaffold Task title:string description:text completed:boolean
bin/rails db:migrate
```

Taskコントローラを`app/controllers/api/v1`へ移動する。
合わせて以下のように修正する。

``` ruby
class Api::V1::TasksController < ApplicationController
  ...
end
```

`routes.rb`も以下のように修正する。

``` ruby
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "signup", to: "users#create"
      post "signin", to: "sessions#create"
      resources :tasks
    end
  end
  ...
end
```

モデルへのバリデーションの追加、コントローラにJWT認証を実装する。

### RSpecによるAPIテスト

`spec/routing/tasks_routing_spec.rb`でルーティングの確認を行なっているが、namespaceを考慮するように修正する必要がある。

`spec/requests/api/v1/tasks_spec.rb`が実際にAPI呼び出しによるテストを実施している。


## 参考文献

* API
    * https://medium.com/@oliver.seq/creating-a-rest-api-with-rails-2a07f548e5dc
* 認証
    * https://www.nightswinger.dev/2022/09/create-api-with-json-web-token-using-rails/
    * https://rightcode.co.jp/blogs/42797
    * https://fusionauth.io/blog/building-protected-api-with-rails-and-jwt
    * https://tejal-panjwani.medium.com/api-authentication-with-rails-cf5c410c78ed
    * https://zenn.dev/forge422/articles/c24fc1674f8076
* RSpec APIテスト
    * https://rubyyagi.com/rspec-request-spec/