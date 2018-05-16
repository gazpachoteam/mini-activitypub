port     = ENV['PORT'] || 3000
host     = ENV['LOCAL_DOMAIN'] || "localhost:#{port}"
web_host = ENV['WEB_DOMAIN'] || host
https    = ENV['LOCAL_HTTPS'] == 'false'

Rails.application.configure do
  config.x.local_domain = host
  config.x.web_domain   = web_host
  config.x.use_https    = https

  config.action_mailer.default_url_options = { host: web_host, protocol: https ? 'https://' : 'http://', trailing_slash: false }
default_url_options
end

Rails.application.routes.default_url_options[:host] = host
