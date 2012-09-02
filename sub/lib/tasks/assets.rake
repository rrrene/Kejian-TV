namespace :precompile do
  def internal_precompile(digest=nil)
    unless Rails.application.config.assets.enabled
      warn "Cannot precompile assets if sprockets is disabled. Please set config.assets.enabled to true"
      exit
    end

    # Ensure that action view is loaded and the appropriate
    # sprockets hooks get executed
    _ = ActionView::Base

    config = Rails.application.config
    config.assets.compile = true
    config.assets.digest  = digest unless digest.nil?
    config.assets.digests = {}

      
    env      = Rails.application.assets
    target   = File.join(Rails.public_path, config.assets.prefix)

    # psvr overriding
    return if false==digest
    puts "PreCompiling with Rails.env=#{Rails.env}"
    target = File.join(Rails.public_path, "../../_assets_sub")
    config.assets.prefix = ''
    config.action_controller.asset_host = ''
    # --------------
    compiler = Sprockets::StaticCompiler.new(env,
                                             target,
                                             config.assets.precompile,
                                             :manifest_path => config.assets.manifest,
                                             :digest => config.assets.digest,
                                             :manifest => digest.nil?)
    compiler.compile
  end
end
