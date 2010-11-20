class Micropost
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessible :content

  field :content, :type => String
  index :created_at

  referenced_in :user, :inverse_of => :micropost

  validates :content, :presence => true, :length => { :maximum => 140 }

  # default_scope :order => 'microposts.created_at DESC'
  self.scope_stack << order_by(:created_at.desc)

  # Return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }

  private

  def self.followed_by(user)
#     followed_ids = %(SELECT followed_id FROM relationships
#                      WHERE follower_id = :user_id)
#     where("user_id IN (#{followed_ids}) OR user_id = :user_id",
#           { :user_id => user })
    following = User.only(:_id).in(:following => [user])
    Micropost.where(:user.in => [following])
  end
end
