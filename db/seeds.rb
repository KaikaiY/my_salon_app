# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  User.find_or_create_by!(email: ENV["ADMIN_EMAIL"]) do |user|
    user.name = "管理者"
    user.password = ENV["ADMIN_PASSWORD"]
    user.password_confirmation = ENV["ADMIN_PASSWORD"]
    user.role = :admin
  end
end
