require 'open-uri'
require 'json'
require 'fileutils'
require "image_processing/vips"

puts "🌱 Starting to seed..."

# 🔥 删除所有数据
Comment.destroy_all
Like.destroy_all
Follow.destroy_all
Post.destroy_all
Profile.destroy_all
User.destroy_all
ActiveStorage::Attachment.destroy_all
ActiveStorage::Blob.destroy_all
FileUtils.rm_rf(Rails.root.join("storage"))

# ✅ PostgreSQL 自增 ID 重置
if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
  %w[users profiles posts follows likes comments].each do |table_name|
    ActiveRecord::Base.connection.reset_pk_sequence!(table_name)
  end
end

# 📦 读取 JSON 文件
fake_users = JSON.parse(File.read(Rails.root.join("app/assets/json/fake_users_30.json")))
posts_data = JSON.parse(File.read(Rails.root.join("app/assets/json/posts_title_content_1-60.json")))

# 禁用 User 的 after_create 回调
User.skip_callback(:create, :after, :create_default_profile)

# 🧑‍🤝‍🧑 创建用户 + 头像 + 帖子
fake_users.each_with_index do |user_data, i|
  user = User.create!(
    username: user_data["username"],
    email: user_data["email"],
    password: "123456"
  )

  profile = user.build_profile(bio: user_data["bio"])
  avatar_path = Rails.root.join("app/assets/images/avatars/avatar_#{i + 1}.jpg")
  profile.avatar.attach(io: File.open(avatar_path), filename: "avatar_#{i + 1}.jpg", content_type: "image/jpg")
  profile.save!

  post_data_key = "post#{i + 1}.jpg"
  post = user.posts.create!(
    title: posts_data[post_data_key]["title"],
    content: posts_data[post_data_key]["content"]
  )

  post_image_path = Rails.root.join("app/assets/images/posts_images/post#{i + 1}.jpg")
  post.image.attach(io: File.open(post_image_path), filename: "post_image#{i + 1}.jpg", content_type: "image/jpg")
  post.image.analyze
end


# seed 执行完后恢复回调（可选）
User.set_callback(:create, :after, :create_default_profile)

# ➕ 社交互动数据
users = User.all
posts = Post.all

users.each do |user|
  ActiveRecord::Base.transaction do
    # 关注 15 个其他用户
    users.where.not(id: user.id).sample(3).each do |target|
      Follow.find_or_create_by!(follower: user, followed: target)
    end

    # 点赞 15 个帖子
    posts.sample(3).each do |post|
      Like.find_or_create_by!(user: user, post: post)
    end
  end
end

# 💬 加载评论内容
comment_library = JSON.parse(File.read(Rails.root.join("app/assets/json/comment_library.json")))

posts.each do |post|
  comment_count = rand(3..6)
  available_users = users.where.not(id: post.user_id).shuffle
  selected_users = available_users.first(comment_count)
  selected_comments = comment_library.shuffle.first(comment_count)

  selected_users.each_with_index do |user, index|
    created_time = rand(1..7).days.ago + rand(0..59).minutes
    Comment.create!(
      user: user,
      post: post,
      content: selected_comments[index],
      created_at: created_time,
      updated_at: created_time
    )
  end
end

puts "✅ seeds created successfully!"
