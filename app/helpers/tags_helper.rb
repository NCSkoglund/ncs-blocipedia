module TagsHelper

  # for use in tags#index and tags#show
  def is_wiki_viewable?(current_user, wiki)
    return true if !wiki.private
    return true if current_user && (current_user.level?(:premium) || current_user.level?(:admin))
    return false
  end

end
