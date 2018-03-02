import Widget from require "lapis.html"

class extends Widget
  content: =>
    form {
      action: @url_for "user_admin"
      method: "POST"
      enctype: "multipart/form-data"
    }, ->
      p "Selected User: #{@user_editing.name} (#{@user_editing.id})"
      element "table", ->
        tr ->
          td "Switch (by name)?"
          td -> input type: "text", name: "change_via_name", placeholder: @user_editing.name
        tr ->
          td "Switch (by ID)?"
          td -> input type: "number", name: "change_via_id", value: @user_editing.id
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit"
    hr!

    form {
      action: @url_for "user_admin"
      method: "POST"
      enctype: "multipart/form-data"
    }, ->
      text "Change username? "
      input type: "text", name: "name", value: @user_editing.name, autocomplete: "username"
      br!
      input type: "hidden", name: "id", value: @user_editing.id
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit"
    hr!

    form {
      action: @url_for "user_admin"
      method: "POST"
      enctype: "multipart/form-data"
    }, ->
      text "Change email? "
      input type: "text", name: "email", value: @user_editing.email
      br!
      input type: "hidden", name: "id", value: @user_editing.id
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit"
    hr!

    form {
      action: @url_for "user_admin"
      method: "POST"
      enctype: "multipart/form-data"
    }, ->
      text "Change password? "
      input type: "password", name: "password"
      br!
      input type: "hidden", name: "id", value: @user_editing.id
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit"
    hr!

    form {
      action: @url_for "user_admin"
      method: "POST"
      enctype: "multipart/form-data"
      onsubmit: "return confirm('Are you sure you want to do this?');"
    }, ->
      text "Administrator? "
      input type: "checkbox", name: "admin", checked: @user_editing.admin
      br!
      input type: "hidden", name: "id", value: @user_editing.id
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit"

    form {
      action: @url_for "user_admin"
      method: "POST"
      enctype: "multipart/form-data"
      onsubmit: "return confirm('Are you sure you want to do this?');"
    }, ->
      text "Delete user? "
      input type: "checkbox", name: "delete"
      br!
      input type: "hidden", name: "id", value: @user_editing.id
      input type: "hidden", name: "csrf_token", value: @csrf_token
      input type: "submit"
