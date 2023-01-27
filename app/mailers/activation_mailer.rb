# frozen_string_literal: true

class ActivationMailer < ApplicationMailer
  default from: 'kamzzyCMS@notifications.com'

  def welcome_email
    @user = params[:user]
    # @activation_key = @user.activation_key
    # @url = "https://#{site}/registrations/#{@user.id}/activate_account"
    mail(to: @user.email, subject: 'Welcome to kamzzyCMS demo')
  end

  def password_reset_email
    # site = 'base url'
    @user = params[:user]
    # @activation_key = @user.activation_key
    # @url = "https://#{site}/registrations/#{@user.id}/activate_account"
    mail(to: @user.email, subject: 'Forgot your password?')
  end
end
