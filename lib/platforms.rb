require 'ceedling/plugin'
require 'ceedling/yaml_wrapper'

PLATFORMS_ROOT_NAME = 'platforms'.freeze
PLATFORMS_SYM       = PLATFORMS_ROOT_NAME.to_sym

class Platforms < Plugin
  def setup
    config = collect_project_platforms(@ceedling[:configurator].project_config_hash)
    @ceedling[:configurator].replace_flattened_config(config)
  end
  
  def collect_project_platforms(flat_hash)
    platforms = []
    
    flat_hash[:project_platforms_paths].each do |path|
      platforms << @ceedling[:file_wrapper].directory_listing(File.join(path, '*.yml'))
    end
    
    return {
      :collection_project_platforms => platforms.flatten
    }
  end
  
  def platform_variants(platform)
    platform_path = COLLECTION_PROJECT_PLATFORMS.detect {|path| File.basename(path, '.yml') == platform}
    platform_variants = @ceedling[:file_wrapper].directory_listing(File.join(File.dirname(platform_path), platform, '*.yml'))
    return platform_variants
  end
  
  def setup_platform(*config_paths)
    constants_to_remove = [
      "CLEAN",
      "CLOBBER",
      "REMOVE_FILE_PROC",
    ]
    
    Rake.application.clear
    @ceedling[:configurator].script_plugins.each do |plugin|
      @ceedling.instance_variable_get(:@cache).delete(plugin.to_s)
    end
    @ceedling[:plugin_manager].instance_variable_set(:@plugin_objects, [])
    
    constants_to_remove.each do |const|
      Object.send(:remove_const, const)
    end
    
    platform_config = @ceedling[:setupinator].load_project_files
    
    config_paths.each do |path|
      next if path.nil?
      config = @ceedling[:yaml_wrapper].load(path)
      platform_config = @ceedling[:project_file_loader].yaml_merger(platform_config, config)
    end
    
    platform_config[:plugins][:enabled].delete(PLATFORMS_ROOT_NAME)
    @ceedling[:setupinator].do_setup(platform_config)
    
    PROJECT_RAKEFILE_COMPONENT_FILES.each {|component| load(component)}
  end
end
