Rails.application.routes.draw do
  # 自動生成ルート（config/routes/openapi.rb）
  draw :openapi

  namespace :auth do
    post "signup", to: "signup#create"
  end
end
