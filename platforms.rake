desc 'List available project platforms.'
task :platforms do
  COLLECTION_PROJECT_PLATFORMS.each do |platform_path|
    platform = File.basename(platform_path, '.yml')
    variants = @ceedling[PLATFORMS_SYM].platform_variants(platform).map {|path| File.basename(path, '.yml')}
    if !variants.nil? && variants.length > 0
      puts "#{platform}: #{variants.join(', ')}"
    else
      puts platform
    end
  end
end

namespace :platform do
  COLLECTION_PROJECT_PLATFORMS.each do |platform_path|
    platform = File.basename(platform_path, '.yml')

    desc "Build for '#{platform}' platform."
    task platform.to_sym, [:variant] do |t, args|
      variant = args[:variant]
      if variant.nil?
        @ceedling[PLATFORMS_SYM].setup_platform(platform_path)
      else
        platform_variants = @ceedling[PLATFORMS_SYM].platform_variants(platform)
        filename = variant + '.yml'
        filelist = platform_variants.map {|s| File.basename(s)}
        @ceedling[:file_finder].find_file_from_list(filename, filelist, :error)
        variant_path = platform_variants.detect {|path| File.basename(path, '.yml') == variant}
        @ceedling[PLATFORMS_SYM].setup_platform(platform_path, variant_path)
      end
    end
  end
  
  rule /^platform:.*/ do |t, args|
    filename = t.to_s.split(':')[-1] + '.yml'
    filelist = COLLECTION_PROJECT_PLATFORMS.map {|s| File.basename(s)}
    @ceedling[:file_finder].find_file_from_list(filename, filelist, :error)
  end
end
