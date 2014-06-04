class TagPolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    if user && user.present? && (user.level?(:premium) || user.level?(:admin))
        true
    else
      # does the tag have one or more public wikis?  
      @int = 0
      record.wikis.each do |w|
        if w.private == false 
          @int += 1
        end
      end
      @int > 0 ? true : false 
    end
  end

end
