class User < ActiveRecord::Base
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :cas_authenticatable, :trackable

  before_validation :fetch_attributes_from_ldap

  has_many :assignments, :dependent => :destroy
  has_many :roles, :through => :assignments
  has_many :requests
  has_many :video_workflows, :foreign_key => 'workflow_state_change_user'

  # Setup accessible (or protected) attributes for your model
#  attr_accessible :email, :username, :last_name, :first_name, :role_ids, :display_name, :roles

  validates :username, :email, :uniqueness => true
  validates_presence_of :email, :username, :first_name, :last_name, :display_name
  validate :must_exist_in_ldap

  scope :username, lambda { | username |  where(username: username) }

  store :admin_preferences, accessors: [ :libraries, :types, :reserve_type, :instructor_range_begin, :instructor_range_end ]

  def name
    "#{first_name} #{last_name}"
  end


  def username
    self[:username].to_s.downcase.strip
  end

  # roles
  def has_role?(role_sym)
    roles.any? { |r| r.name.split.join.to_s.underscore.to_sym == role_sym }
  end


  def requester_display
    "#{self.display_name} (#{self.username})"
  end


  def admin?
    self.admin || ['rfox2', 'jhartzle', 'fboze', 'dwolfe2'].include?(self.username)
  end


  def wse_admin?
    ['rfox2', 'jhartzle', 'dwolfe2'].include?(self.username)
  end


  def set_admin!
    self.admin = true
    self.save!
  end


  def revoke_admin!
    self.admin = false
    self.save!
  end


  def self.get_affiliation(ldap_result)
    # This is engineered to get the most important affiliation in
    # LDAP for authorization purposes. The order of preference, if someone
    # falls into multiple categories is: staff -> faculty -> graduate student
    # -> undergrad

    total_affiliation = []
    ldap_result[:edupersonalaffiliation].each {|a| total_affiliation.push(a.downcase)}
    ldap_result[:ndaffiliation].each {|a| total_affiliation.push(a.downcase)}
    ldap_result[:edupersonprimaryaffiliation].each {|a| total_affiliation.push(a.downcase)}
    ldap_result[:ndprimaryaffiliation].each {|a| total_affiliation.push(a.downcase)}
    total_affiliation.flatten!
    secondary_affiliation = []
    ldap_result[:ndtitle].each {|s| secondary_affiliation.push(s.downcase)}
    ldap_result[:title].each {|s| secondary_affiliation.push(s.downcase)}
    ldap_result[:ndlevel].each {|s| secondary_affiliation.push(s.downcase)}
    secondary_affiliation.flatten!
    final_affiliation = ''
    temp_affiliation = ''
    case
    when total_affiliation.include?('student')
      temp_affiliation = 'student'
    when total_affiliation.include?('staff')
      final_affiliation = 'staff'
    when total_affiliation.include?('faculty')
      final_affiliation = 'faculty'
    else
      final_affiliation = 'unknown'
    end

    case temp_affiliation
    when 'student'
      secondary_array = secondary_affiliation.grep /grad/i
      if secondary_array.empty? == false
        final_affiliation = 'grad'
      elsif secondary_affiliation.include?('senior')
        final_affiliation = 'undergrad'
      elsif secondary_affiliation.include?('junior')
        final_affiliation = 'undergrad'
      elsif secondary_affiliation.include?('sophomore')
        final_affiliation = 'undergrad'
      elsif secondary_affiliation.include?('freshman')
        final_affiliation = 'undergrad'
      end
    end

    final_affiliation
  end

  # ldap
  def self.ldap_lookup(username)
    return nil if username.blank?
    ldap = Net::LDAP.new :host => Rails.application.secrets.ldap["host"],
                         :port => Rails.application.secrets.ldap["port"],
                         :auth => { :method   => :simple,
                                    :username => Rails.application.secrets.ldap["service_dn"],
                                    :password => Rails.application.secrets.ldap["service_password"]
                                  },
                         :encryption => :simple_tls
    results = ldap.search(
      :base          => Rails.application.secrets.ldap["base_dn"],
      :attributes    => [
                         'cn',
                         'givenname',
                         'sn',
                         'mail',
                         'displayname',
                         'ndaffiliation',
                         'edupersonprimaryaffiliation',
                         'ndprimaryaffiliation',
                        ],
      :filter        => Net::LDAP::Filter.eq( 'cn', username ),
      :return_result => true
    )
    if results.empty?
      raise LDAPException.new("LDAP Lookup failed for '#{username}'")
    end
    results.first
  end


  def self.generate_imported_user
    User.new(display_name: 'Imported')
  end

  private

  def must_exist_in_ldap
    if Rails.configuration.ldap_lookup_flag
      if !User.ldap_lookup(username)
        errors.add(:username, "not valid username")
      end
    end
  end

  def fetch_attributes_from_ldap
    if Rails.configuration.ldap_lookup_flag
      attributes = User.ldap_lookup(username)
      self.first_name = attributes[:givenname].first
      self.last_name = attributes[:sn].first      
      self.email = attributes[:mail].first
      self.display_name = attributes[:displayname].first
    end
  end

  class LDAPException < Exception
  end
end