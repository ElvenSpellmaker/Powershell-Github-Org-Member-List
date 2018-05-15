# This script doesn't abide by Github's best practices with
# regards to ETAG caching, please don't spam this script!

$TOKEN = 'My PAT with `read:org` access'
$ORG = 'Acme-Company'

######## NO NEED TO TOUCH BELOW THIS LINE! ########

$urlEndpoint = "https://api.github.com/orgs/$ORG/members"
# Due to the Hack below we need an opening bracket ^-^
$fullContent = '['
$page = 1

do `
{
	$membersResponse = curl $urlEndpoint `
		-Headers @{
			'Authorization'="token $TOKEN";
			'Accept'='application/vnd.github.v3+json';
		}

	# HACK HACK HACK, no idea how to add Powerhell objects together easily, so this'll do...
	$partialContent = $membersResponse.Content -replace '^\[(.*)','$1'
	$fullContent = ($fullContent -replace '(.*)]$','$1,') + $partialContent

	$urlEndpoint = $membersResponse.Headers.Link -replace '<(.*?)>;.*','$1'
	$nextPage = $urlEndpoint -replace ".*page=(.*)",'$1'
	$page++
} until ($page -ne $nextPage)

($fullContent | ConvertFrom-Json) | Out-GridView