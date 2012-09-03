# -*- encoding : utf-8 -*-
class Cpanel::ScopesController < CpanelController
  layout 'cpanel_oauth' 
  before_filter :admin?
  before_filter :find_resource, only: ["show", "edit", "update", "destroy"]
  after_filter  :sync_existing_scopes, only: ["update", "destroy"] 

  def index
    @scopes = Scope.all
  end

  def show
  end

  def new
    @scope = Scope.new
  end

  def create
    # Note: consider seeds.rb
    @scope        = Scope.new(params[:scope])
    @scope.uri    = @scope.base_uri(request)
    @scope.values = @scope.normalize(params[:scope][:values])

    if @scope.save
      redirect_to(cpanel_scope_path(@scope), notice: "Resource was successfully created.")
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    @scope.values = @scope.normalize(params[:scope][:values])

    if @scope.update_attributes(params[:scope])
      render("show", notice: "Resource was successfully updated.")
    else
      render action: "edit"
    end
  end

  def destroy
    @scope.destroy
    redirect_to(cpanel_scopes_url, notice: "Resource was successfully destroyed.")
  end


  private

    def find_resource
      @scope = Scope.criteria.find(params[:id])
      unless @scope
        redirect_to root_path, alert: "Resource not found."
      end        
    end

    # TODO: put into a background process
    def sync_existing_scopes
      Client.sync_clients_with_scope(@scope.name)
    end

    def admin?
      unless current_user.admin?
        flash.alert = "Unauthorized access."
        redirect_to root_path
        return false
      end
    end

end
