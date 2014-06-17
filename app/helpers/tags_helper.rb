module TagsHelper

  # for use in tags#index and tags#show views
  def is_wiki_viewable?(current_user, wiki)
    if wiki.private == false
      true
    else wiki.scope_helper(current_user)
    end
  end

end
