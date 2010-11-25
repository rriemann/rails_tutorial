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
    Micropost.criteria.where(:user_id.in => user.following_ids << user.id)
  end
end
