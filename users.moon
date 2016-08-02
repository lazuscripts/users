lapis = require "lapis"
csrf = require "lapis.csrf"
config = require("lapis.config").get!

crypto = require "crypto"
bcrypt = require "bcrypt"

import respond_to from require "lapis.application"

Users = require "users.models.Users"

class extends lapis.Application
    @path: "/users"
    @name: "user_"

    [new: "/new"]: respond_to {
        GET: =>
            if @session.id
                return redirect_to: @url_for "index"

            csrf_token = csrf.generate_token @

            @html ->
                form {
                    action: @url_for "user_new"
                    method: "POST"
                    enctype: "multipart/form-data"
                    class: "pure-form"
                }, ->
                    input type: "hidden", name: "csrf_token", value: csrf_token
                    p ->
                        text "Username: "
                        input type: "text", name: "name"
                    p ->
                        text "Password: "
                        input type: "password", name: "password"
                    p ->
                        input class: "pure-button", type: "submit"

        POST: =>
            csrf.assert_token @
            if #@params.password < 8
                return "Your password must be at least 8 characters long."

            salt = crypto.pkey.generate("rsa", 4096)\to_pem!
            digest = bcrypt.digest @params.password .. salt, config.digest_rounds

            user, errMsg = Users\create {
                name: @params.name
                salt: salt
                digest: digest
            }

            if user
                @session.id = user.id
                if tonumber(Users\count!) < 2
                    user\update { admin: true }
                return redirect_to: @url_for "index"
            else
                return errMsg, status: 500
    }

    [edit: "/edit"]: respond_to {
        GET: =>
            unless @session.id
                return redirect_to: @url_for "index"

            csrf_token = csrf.generate_token @
            user = Users\find id: @session.id

            @html ->
                form {
                    action: @url_for "user_edit"
                    method: "POST"
                    enctype: "multipart/form-data"
                    class: "pure-form"
                }, ->
                    input type: "hidden", name: "csrf_token", value: csrf_token
                    p ->
                        text "Change username? "
                        input type: "text", name: "name", placeholder: user.name
                    p ->
                        input class: "pure-button", type: "submit"
                hr!

                form {
                    action: @url_for "user_edit"
                    method: "POST"
                    enctype: "multipart/form-data"
                    class: "pure-form"
                }, ->
                    input type: "hidden", name: "csrf_token", value: csrf_token
                    p "Change password?"
                    p ->
                        text "Old password: "
                        input type: "password", name: "oldpassword"
                    p ->
                        text "New password: "
                        input type: "password", name: "password"
                    p ->
                        input class: "pure-button", type: "submit"
                hr!

                form {
                    action: @url_for "user_edit"
                    method: "POST"
                    enctype: "multipart/form-data"
                    class: "pure-form"
                    onsubmit: "return confirm('Are you sure you want to do this?');"
                }, ->
                    input type: "hidden", name: "csrf_token", value: csrf_token
                    p ->
                        input class: "pure-checkbox", type: "checkbox", name: "delete"
                        text "Delete user?"
                    input class: "pure-button", type: "submit"

        POST: =>
            csrf.assert_token @
            user = Users\find id: @session.id

            if @params.name != ""
                user\update { name: @params.name }
                return redirect_to: @url_for "index"

            elseif @params.password != ""
                if bcrypt.verify @params.oldpassword .. user.salt, user.digest
                    salt = crypto.pkey.generate("rsa", 4096)\to_pem!
                    digest = bcrypt.digest @params.password .. salt, config.digest_rounds

                    user\update {
                        salt: salt
                        digest: digest
                    }
                else
                    return status: 401, "Incorrect password."

            elseif @params.delete
                if user\delete!
                    @session.id = nil
                    return @url_for "index" --TODO have some way to send along a message... just set @sessions.alertMsg and have layout with if statement to render a closeable box with the message, then redirect_to any page! duh!
                else
                    return status: 500, "Error deleting your account."

            return redirect_to: @url_for "user_edit" --add error message or info about not doing anything?
    }

    [login: "/login"]: respond_to {
        GET: =>
            if @session.id
                return redirect_to: @url_for "index"

            csrf_token = csrf.generate_token @

            @html ->
                form {
                    action: @url_for "user_login"
                    method: "POST"
                    enctype: "multipart/form-data"
                    class: "pure-form"
                }, ->
                    input type: "hidden", name: "csrf_token", value: csrf_token
                    p ->
                        text "Username: "
                        input type: "text", name: "name"
                    p ->
                        text "Password: "
                        input type: "password", name: "password"
                    p ->
                        input class: "pure-button", type: "submit"

        POST: =>
            csrf.assert_token @
            if user = Users\find name: @params.user
                if bcrypt.verify @params.password .. user.salt, user.digest
                    @session.id = user.id

            return redirect_to: @url_for "index"
    }

    [logout: "/logout"]: =>
        @session.id = nil
        return redirect_to: @url_for "index"
