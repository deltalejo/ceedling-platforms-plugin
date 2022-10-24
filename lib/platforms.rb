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
    
    config_hash = @ceedling[:setupinator].config_hash
    @ceedling[:setupinator].reset_defaults(config_hash)
    
    config_paths.each do |path|
      next if path.nil?
      config = @ceedling[:yaml_wrapper].load(path)
      config_hash.deep_merge!(config)
    end
    
    config_hash[:plugins][:enabled].delete(PLATFORMS_ROOT_NAME)
    @ceedling[:setupinator].do_setup(config_hash)
    
    constants_to_remove.each do |const|
      Object.send(:remove_const, const)
    end
    
    flat_hash = @ceedling[:configurator].project_config_hash
    
    # load(File.join(CEEDLING_LIB, 'ceedling', 'tasks_base.rake'))
    load(File.join(CEEDLING_LIB, 'ceedling', 'tasks_filesystem.rake'))
    # load(File.join(CEEDLING_LIB, 'ceedling', 'tasks_tests.rake'))
    # load(File.join(CEEDLING_LIB, 'ceedling', 'tasks_vendor.rake'))
    load(File.join(CEEDLING_LIB, 'ceedling', 'rules_tests.rake'))
    
    load(File.join(CEEDLING_LIB, 'ceedling', 'rules_cmock.rake')) if (flat_hash[:project_use_mocks])
    load(File.join(CEEDLING_LIB, 'ceedling', 'rules_preprocess.rake')) if (flat_hash[:project_use_test_preprocessor])
    load(File.join(CEEDLING_LIB, 'ceedling', 'rules_tests_deep_dependencies.rake')) if (flat_hash[:project_use_deep_dependencies])
    # load(File.join(CEEDLING_LIB, 'ceedling', 'tasks_tests_deep_dependencies.rake')) if (flat_hash[:project_use_deep_dependencies])
    
    load(File.join(CEEDLING_LIB, 'ceedling', 'rules_release_deep_dependencies.rake')) if (flat_hash[:project_release_build] and flat_hash[:project_use_deep_dependencies])
    load(File.join(CEEDLING_LIB, 'ceedling', 'rules_release.rake')) if (flat_hash[:project_release_build])
    # load(File.join(CEEDLING_LIB, 'ceedling', 'tasks_release_deep_dependencies.rake')) if (flat_hash[:project_release_build] and flat_hash[:project_use_deep_dependencies])
    # load(File.join(CEEDLING_LIB, 'ceedling', 'tasks_release.rake')) if (flat_hash[:project_release_build])
    
    @ceedling[:configurator].rake_plugins.each {|plugin| load(plugin)}
  end  
end
