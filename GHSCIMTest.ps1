[Net.ServicePointManager]::SecurityProtocol = 
  [Net.SecurityProtocolType]::Tls12 -bor `
  [Net.SecurityProtocolType]::Tls11 -bor `
  [Net.SecurityProtocolType]::Tls
  Accept: application/vnd.github.inertia-preview+json
  application/vnd.github.jean-grey-preview+json
  application/vnd.github.hellcat-preview+json
 Invoke-RestMethod -Uri "https://api.github.com/orgs/NBIM/teams" -Method GET