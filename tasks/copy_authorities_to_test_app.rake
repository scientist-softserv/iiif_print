namespace :engine_cart do
  desc "Copy custom rights_statement and license questioning authority YAML files into the test app"
  task copy_authorities: :generate do
    test_app_path = ENV['ENGINE_CART_DESTINATION'] || File.expand_path(".internal_test_app", File.dirname(__FILE__))
    src_dir = File.expand_path("../spec/fixtures/authorities", __dir__)
    dest_dir = File.join(test_app_path, "config/authorities")

    FileUtils.mkdir_p(dest_dir)
    FileUtils.cp_r("#{src_dir}/.", dest_dir)
  end
end
