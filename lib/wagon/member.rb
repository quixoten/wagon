class Member
  attr_reader :household, :name, :email
  
  def initialize(household, name, email)
      @household, @name, @email = household, name, email
  end
  
  def to_s
    [name, household.name, email.to_s.empty? ? nil : "<#{email}>"].compact.join(" ")
  end
end