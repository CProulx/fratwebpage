class Member < ActiveRecord::Base
  belongs_to :photo
  
  validates_length_of :password, :within => (6..20), :allow_nil => true, :if => :new_record?
  validates_length_of :name, :minimum => 1
  
  attr_accessor :password, :password_confirmation
  attr_accessible :name, :password, :password_confirmation, :nickname, :position, :image
  
  before_save :set_password
  
  def validate    
    if @password
      errors.add(:password_confirmation,"Confirmation password does not match") unless @password==@password_confirmation
    end
    
    if self.new_record? and !@password
      errors.add(:password,"You must enter a password for a new member")
    end
  end
  
  before_save :save_image
  def save_image
    self.photo.save! if self.photo and self.photo.new_record?
  end
  
  
  #this function returns a user if both the username and password match. otherwise it returns nil. usernames must be unique.
  def self.authenticate(name,password)
    mem = self.find(:first, :conditions => ['name = ? OR nickname = ?', name, name])
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
    return unless @password
    salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp
    self.password_salt, self.password_hash = 
      salt, Digest::SHA1.hexdigest(@password + salt)
  end
  
end
