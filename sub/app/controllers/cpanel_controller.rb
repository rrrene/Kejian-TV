class CpanelController < ApplicationController
  layout "cpanel"
  before_filter :require_admin
end
