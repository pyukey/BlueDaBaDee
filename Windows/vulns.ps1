param([Parameter(Mandatory=$true)][ValidateSet('plant','check')][string]$action, [string]$modules='all', [ValidateSet(1,2,3,4,5)][int]$minDifficulty=1, [ValidateSet(1,2,3,4,5)][int]$maxDifficulty=5)

$ESC = [char]27
$RED = "$ESC[31;1m"
$GREEN = "$ESC[32;1m"
$CLEAR = "$ESC[0m"

$vulns = [pscustomobject]@{
	Name = 'meow1'
	Module = 'cat'
	Difficulty = 1
}, [pscustomobject]@{
	Name = 'meow2'
	Module = 'cat'
	Difficulty = 2
}, [pscustomobject]@{
	Name = 'woof1'
	Module = 'dog'
	Difficulty = 1
}, [pscustomobject]@{
	Name = 'woof2'
	Module = 'dog'
	Difficulty = 2
}

$plantVulns = @{
	'meow1' = { Write-Host "${RED}Planting${CLEAR} meow1 vulnerability" }
	'meow2' = { Write-Host "${RED}Planting${CLEAR} meow2 vulnerability" }
	'woof1' = { Write-Host "${RED}Planting${CLEAR} woof1 vulnerability" }
	'woof2' = { Write-Host "${RED}Planting${CLEAR} woof2 vulnerability" }
}

$checkVulns = @{
	'meow1' = { Write-Host "${GREEN}Checking${CLEAR} meow1 vulnerability" }
	'meow2' = { Write-Host "${GREEN}Checking${CLEAR} meow2 vulnerability" }
	'woof1' = { Write-Host "${GREEN}Checking${CLEAR} woof1 vulnerability" }
	'woof2' = { Write-Host "${GREEN}Checking${CLEAR} woof2 vulnerability" }
}

Write-Host "${GREEN}Minimum Difficulty:${CLEAR} ${minDifficulty}"
Write-Host "${GREEN}Maximum Difficulty:${CLEAR} ${maxDifficulty}"

$nameArray = $modules.split(",") | ForEach-Object { $_.Trim() }

If ($modules -eq 'all') {
	$filter = $vulns | where{($_.Difficulty -ge $minDifficulty) -and ($_.Difficulty -le $maxDifficulty)}
} else {
	$filter = $vulns | where{($_.Difficulty -ge $minDifficulty) -and ($_.Difficulty -le $maxDifficulty) -and (($nameArray -contains $_.Name) -or ($nameArray -contains $_.Module))}
}
foreach( $v in $filter ) {
	If ($action -eq 'plant') {
		& $plantVulns[$v.Name]
	} ElseIf ($action -eq 'check') {
		& $checkVulns[$v.Name]
	}
}
