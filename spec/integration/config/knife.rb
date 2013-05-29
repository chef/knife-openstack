current_dir = File.dirname(__FILE__)
node_name                "chef0"
client_key               "#{current_dir}/validation.pem"
validation_client_name   "validation"
validation_key           "#{current_dir}/validation.pem"
chef_server_url          "http://localhost:8889"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/chef-repo/cookbooks"]
