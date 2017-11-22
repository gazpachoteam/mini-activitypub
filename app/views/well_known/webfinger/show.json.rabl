object @account

node(:subject) { @canonical_account_uri }

node(:aliases) do
  [short_account_url(@account), account_url(@account)]
end

node(:links) do
  [
    { rel: 'http://webfinger.net/rel/profile-page', type: 'text/html', href: short_account_url(@account) },
    { rel: 'self', type: 'application/activity+json', href: account_url(@account) },
  ]
end
