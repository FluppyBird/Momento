class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist


  # has_secure_password

  has_one_attached :avatar
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  after_create :create_default_profile

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  has_many :active_relationships, class_name: "Follow",
           foreign_key: "follower_id",
           dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: "Follow",
           foreign_key: "followed_id",
           dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  private

  def create_default_profile
    self.create_profile(bio: "This is default bio")
  end
end
