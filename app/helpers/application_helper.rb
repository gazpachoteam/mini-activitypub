module ApplicationHelper
  def login_helper style = ''
    if user_signed_in?
      (link_to "Edit", edit_user_registration_path, class: style) + ' ' +
      (link_to "Logout", destroy_user_session_path, class: style, method: :delete)
    else
      (link_to "Register", new_user_registration_path, class: style) + ' ' +
      (link_to "Login", new_user_session_path, class: style)
    end
  end
end
