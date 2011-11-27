# Custom VestalVersion::Version that sets +user+
class RacingOnRails::Version < VestalVersions::Version
  before_save :set_user
  
  def set_user
    unless user.present?
      self.user = Person.current
    end
  end
end
