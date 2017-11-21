port     = ENV['PORT'] || 3000
host     = ENV['LOCAL_DOMAIN'] || "localhost:#{port}"
web_host = ENV['WEB_DOMAIN'] || host
https    = ENV['LOCAL_HTTPS'] == 'true'

Rails.application.configure do
  config.x.local_domain = host
  config.x.web_domain   = web_host
  config.x.use_https    = https
end
