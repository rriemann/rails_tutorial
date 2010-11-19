class Relationship
  include Mongoid::Document

  attr_accessible :followed_id

  field :follower_id, :type => Integer
  field :followed_id, :type => Integer

  referenced_in :follower, :class_name => "User"
  referenced_in :followed, :class_name => "User"

  validates :follower_id, :presence => true
  validates :followed_id, :presence => true
end
