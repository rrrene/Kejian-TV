# -*- encoding : utf-8 -*-
class AccountConfirmationsController < Devise::ConfirmationsController
  def new
    super
    render "new"
  end
  def create
      self.resource = resource_class.send_confirmation_instructions(resource_params)

      if successfully_sent?(resource)
        respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
      else
        respond_with(resource) do |format|
          format.html{render "new"}
        end
      end
  end
  def show
    self.resource = User.find_or_initialize_with_error_by(:confirmation_token, params[:confirmation_token])
    if resource.encrypted_password.present?
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])

      if resource.errors.empty?
        set_flash_message(:notice, :confirmed) if is_navigational_format?
        sign_in(resource_name, resource);sign_in_others
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
      else
        respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render "new" }
      end
      return
    end
    if 'GET'==request.method
      if resource.errors.empty?
        render "show"
      else
        flash[:notice]=resource.errors.full_messages.first
        respond_with_navigational(resource.errors,:status => :unprocessable_entity){ render "new" }
      end
      return
    end
    # 安全覆写™
    resource.during_registration = true
    resource.name_unknown = false
    resource.email_unknown = false
    # Now we are at the business
    resource.password = params[:user][:password]
    resource.password_confirmation = params[:user][:password_confirmation]
    if resource.save
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      if resource.errors.empty?
        set_flash_message(:notice, :confirmed) if is_navigational_format?
        sign_in(resource_name, resource);sign_in_others
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
      else
        respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render "show" }
      end
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render "show" }
    end
  end
  
end
