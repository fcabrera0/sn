require 'mongoid'
require 'bson'

class User
  include Mongoid::Document

  field :email, type: String
  field :password, type: Hash
  field :status, type: Integer, default: 0
  field :verification, type: String, default: -> { SecureRandom.base64 }
  field :timestamp, type: DateTime, default: -> { DateTime.now }

  has_one :profile
  has_many :sessions

  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :sessions
end

class Profile
  include Mongoid::Document

  field :identity, type: Hash
  field :about, type: Hash
  field :privacy, type: Hash
  
  belongs_to :user
end

class Message
  include Mongoid::Document

  field :content, type: String
  field :timestamp, type: DateTime, default: -> { DateTime.now }

  has_one :from, class_name: 'User'
  has_many :dest, class_name: 'User'
end

class Session
  include Mongoid::Document
  
  field :ip, type: String
  field :status, type: Integer, default: 0
  field :timestamp, type: DateTime, default: -> { DateTime.now }

  belongs_to :user
end