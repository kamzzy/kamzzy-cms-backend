# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include TokenGenerator
  include CompareDates

  # Determine if user is authenticated
  def authorized_user?
    json_response({ errors: 'Account not Authorized' }, 401) unless current_user
  end

  # Determine if user is authenticated administrator
  def authorized_admin?
    authorized_user?
    json_response({ errors: 'Insufficient Administrative Rights' }, 401) unless @current_user.admin_level.positive?
  end

  private

  # Sets a global @current_user variable if possible
  def current_user
    return nil unless access_token.present?

    @current_user ||= User.find_by(token: access_token)
    return nil unless @current_user
    return nil if token_expire?(@current_user.token_date)

    @current_user
  end

  # Determines if token is expired based on the amount of time between the token_date and server date
  # Default expiration date is 1 day after creation
  def token_expire?(token_date, days = 1, hours = 24, minutes = 0, seconds = 0)
    date_diff = compare_dates(token_date)

    if date_diff[:days] >= days && date_diff[:hrs] >= hours &&
       date_diff[:mins] >= minutes && date_diff[:secns] >= seconds
      true
    end

    false
  end

  # Grabs the token placed in the HTTP Request Header, "Authorization"
  def access_token
    request.headers[:Authorization]
  end
end
