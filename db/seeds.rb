# seeds.rb

require 'open-uri'
require 'json'
stderr_original = $stderr.dup
$stderr.reopen(File::NULL)
require "image_processing/vips"
$stderr.reopen(stderr_original)

User.destroy_all
Profile.destroy_all
Post.destroy_all
Follow.destroy_all
Like.destroy_all
Comment.destroy_all

# 仅适用于 SQLite3，重置自增 ID 的计数器
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='users';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='profiles';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='posts';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='follows';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='likes';")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='comments';")

# 清空 ActiveStorage 附件记录
ActiveStorage::Attachment.destroy_all
ActiveStorage::Blob.destroy_all

# 清空本地存储的实际文件
require 'fileutils'
FileUtils.rm_rf(Rails.root.join("storage"))

# 读取假用户数据
fake_users = JSON.parse(File.read(Rails.root.join("app/assets/json/fake_users_30.json")))
# 读取帖子标题和内容的 JSON 文件
posts_data = JSON.parse(File.read(Rails.root.join('app/assets/json/posts_title_content_1-60.json')))

# 创建用户、资料和帖子
# fake_users.each_with_index do |user_data, i|
#   user = User.create!(
#     username: user_data["username"],
#     email: user_data["email"],
#     password: "123"
#   )
#
#   profile = user.build_profile(bio: user_data["bio"])
#   avatar_path = Rails.root.join("app/assets/images/avatars/avatar_#{i + 1}.jpg")
#   profile.avatar.attach(
#     io: File.open(avatar_path),
#     filename: "avatar_#{i + 1}.jpg",
#     content_type: "image/jpg"
#   )
#   profile.save!
#
#   # 每人只发 1 篇帖子
#   post_image_path = Rails.root.join("app/assets/images/posts_images/post#{i + 1}.jpg")
#   post_data_key = "post#{i + 1}.jpg"
#
#   post = user.posts.create!(
#     title: posts_data[post_data_key]["title"],
#     content: posts_data[post_data_key]["content"]
#   )
#
#   post.image.attach(
#     io: File.open(post_image_path),
#     filename: "post_image#{i + 1}.jpg",
#     content_type: "image/jpg"
#   )
#   post.image.analyze
# end

fake_users.each_with_index do |user_data, i|
  user = User.create!(
    username: user_data["username"],
    email: user_data["email"],
    password: "123456"
  )

  # profile = user.build_profile(bio: user_data["bio"])
  #
  # avatar_path = Rails.root.join("app/assets/images/avatars/avatar_#{i + 1}.jpg")
  # profile.avatar.attach(
  #   io: File.open(avatar_path),
  #   filename: "avatar_#{i + 1}.jpg",
  #   content_type: "image/jpg"
  # )
  # profile.save!

  profile = user.profile || user.build_profile
  profile.update!(
    bio: user_data["bio"]
  )

  # 上传头像到 ActiveStorage 并立即分析
  avatar_path = Rails.root.join("app/assets/images/avatars/avatar_#{i + 1}.jpg")
  profile.avatar.attach(
    io: File.open(avatar_path),
    filename: "avatar_#{i + 1}.jpg",
    content_type: "image/jpg"
  )
  profile.avatar.analyze

  # 每人只发 1 篇帖子
  post_image_path = Rails.root.join("app/assets/images/posts_images/post#{i + 1}.jpg")
  post_data_key = "post#{i + 1}.jpg"

  post = user.posts.create!(
    title: posts_data[post_data_key]["title"],
    content: posts_data[post_data_key]["content"]
  )

  post.image.attach(
    io: File.open(post_image_path),
    filename: "post_image#{i + 1}.jpg",
    content_type: "image/jpg"
  )
  post.image.analyze
end

# 10.times do |i|
#   user = User.create!(
#     username: "user#{i + 1}",
#     email: "user#{i + 1}@example.com",
#     password: "123"
#   )
#
#   profile = user.profile || user.build_profile
#   profile.update!(
#     bio: "This is my bio"
#   )
#
#   # 上传头像到 ActiveStorage 并立即分析
#   avatar_path = Rails.root.join("app/assets/images/avatars/avatar_#{i + 1}.jpg")
#   profile.avatar.attach(
#     io: File.open(avatar_path),
#     filename: "avatar_#{i + 1}.jpg",
#     content_type: "image/jpg"
#   )
#   profile.avatar.analyze
#
#   3.times do |j|
#     post_index = i * 3 + j + 1
#     post_image_path = Rails.root.join("app/assets/images/posts_images/post#{post_index}.jpg")
#     post_data_key = "post#{post_index}.jpg"
#
#     post = user.posts.create!(
#       title: posts_data[post_data_key]["title"],
#       content: posts_data[post_data_key]["content"]
#     )
#
#     # 压缩图片后上传到 ActiveStorage
#     # compressed = ImageProcessing::Vips
#     #                .source(post_image_path)
#     #                .resize_to_limit(260.5, 347)
#     #                .saver(quality: 70)
#     #                .call
#     #
#     # post.image.attach(
#     #   io: File.open(compressed.path),
#     #   filename: "post_image#{post_index}.jpg",
#     #   content_type: "image/jpg"
#     # )
#     # post.image.analyze
#
#     post.image.attach(
#       io: File.open(post_image_path),
#       filename: "post_image#{post_index}.jpg",
#       content_type: "image/jpg"
#     )
#     post.image.analyze
#
#   end
# end

users = User.all
posts = Post.all

users.each do |user|
  ActiveRecord::Base.transaction do
    # 关注 15 个别人（不包括自己）
    other_users = users.where.not(id: user.id).sample(15)
    other_users.each do |target|
      Follow.find_or_create_by!(follower: user, followed: target)
    end

    # 点赞 15 个帖子
    liked_posts = posts.sample(15)
    liked_posts.each do |post|
      Like.find_or_create_by!(user: user, post: post)
    end
  end
end

# users.each do |user|
#   ActiveRecord::Base.transaction do
#     # 关注 15 个其他用户
#     users.where.not(id: user.id).sample(15).each do |target|
#       Follow.find_or_create_by!(follower: user, followed: target)
#     end
#
#     # 点赞 15 个帖子（不是自己的）
#     posts.reject { |p| p.user_id == user.id }.sample(15).each do |post|
#       Like.find_or_create_by!(user: user, post: post)
#     end
#   end
# end

# 💬 加载 20 条评论模板（适用于所有帖子）
comment_library = JSON.parse(File.read(Rails.root.join("app/assets/json/comment_library.json")))

posts.each do |post|
  # 每个帖子生成 3～6 条评论
  comment_count = rand(3..6)

  # 找到可以评论的用户（不能是作者）
  available_users = users.reject { |u| u.id == post.user_id }.shuffle

  # 选出不重复的评论用户和评论内容
  selected_users = available_users.first(comment_count)
  selected_comments = comment_library.shuffle.first(comment_count)

  # 创建评论
  selected_users.each_with_index do |user, index|
    days_ago = rand(1..7)
    minutes_offset = rand(0..59)
    created_time = days_ago.days.ago + minutes_offset.minutes

    Comment.create!(
      user: user,
      post: post,
      content: selected_comments[index],
      created_at: created_time,
      updated_at: created_time
    )
  end

end


puts "✅ seeds created successfully!！"
