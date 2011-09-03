require "digest"


class Member < ActiveRecord::Base
  belongs_to :photo
  has_many :links
  
  validates_length_of :password, :within => (6..20), :allow_nil => true, :if => :new_record?
  validates_length_of :name, :minimum => 1
  validate :fname, :lname, :nickname, :presence =>true
  attr_accessor :password, :password_confirmation
  attr_accessible :fname, :lname, :password, :password_confirmation, :nickname, :position, :image, :is_alumni, :degree, :summary, :grad_year, :phone, :email, :links
  
  before_save :set_password
  
  def validate    
    if @password
      errors.add(:password_confirmation,"Confirmation password does not match") unless @password==@password_confirmation
    end
    
    if self.new_record? and !@password
      errors.add(:password,"You must enter a password for a new member")
    end
  end
  
  def name
    "#{self.fname} #{self.lname}"
  end
  
  before_save :save_image
  def save_image
    self.photo.save! if self.photo and self.photo.new_record?
  end
  
  
  #this function returns a user if both the username and password match. otherwise it returns nil. usernames must be unique.
  def self.authenticate(name,password)
    mem = self.find(:first, :conditions => ['fname LIKE ? OR lname LIKE ? OR nickname LIKE ?', name, name, name])
    if(mem.blank? ||
      Digest::SHA1.hexdigest(password + mem.password_salt)!= mem.password_hash)
      return nil
    end
    mem    
  end
  
  def image=(photo_params)
    unless photo_params[:image].blank?
      self.photo.destroy if self.photo
      self.photo = Photo.new(photo_params)
    end
  end
    
  protected
  
  def set_password
    return if @password.blank? or @password!=@password_confirmation
    salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp
    self.password_salt, self.password_hash = 
      salt, Digest::SHA1.hexdigest(@password + salt)
  end
  
end
