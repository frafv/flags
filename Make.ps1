# Flag-set-generating make script

$indir = ".\src\flags"
$outdir = ".\flags"
$overlaydir = ".\src\overlays"
$imagemagick = "." # PATH
$composite = Join-Path $imagemagick "composite.exe"

$sizes = @(16, 24, 32, 48, 64)

$flags = (Get-ChildItem $indir -Directory).Name

$square = $flags | Where {$_ -in 'Switzerland','Vatican-City'}
$nepal = $flags | Where {$_ -in 'Nepal'}
$normal = $flags | Where {$_ -notin $square -and $_ -notin $nepal}

$flag_files = @()

# a lot of the files are just renames of other generated
# files. This is the least messy way I can find to do it.
function Copy-File {
	param(
		[string]$Source,
		[string]$Destination
	)

	New-Item -ItemType File -Path $Destination -Force
	Copy-Item -Path $Source -Destination $Destination
}

function Process-Flag {
	param(
		[string]$Source,
		[string]$Flat,
		[string]$Shiny,
		[string]$FlatISO,
		[string]$ShinyISO,
		[string]$Mask,
		[int]$Size
	)

# flat normal
	New-Item -ItemType File -Path $Flat -Force
	Copy-File -Source $Source -Destination $Flat

# shiny normal
	New-Item -ItemType File -Path $Shiny -Force
	& $composite $overlaydir\$Mask\$Size.png $Flat $Shiny

# iso
	Copy-File -Source $Flat -Destination $FlatISO
	Copy-File -Source $Shiny -Destination $ShinyISO

	$flag_files += $Flat, $Shiny, $FlatISO, $ShinyISO
}

function Define-Flag {
	param(
		[string]$Country,
		[string]$Code,
		[string]$Mask
	)

	ForEach($size in $sizes) {
		Process-Flag `
			-Source "$indir\$Country\$size.png" `
			-Flat "$outdir\flags\flat\$size\$Country.png" `
			-Shiny "$outdir\flags\shiny\$size\$Country.png" `
			-FlatISO "$outdir\flags-iso\flat\$size\$Code.png" `
			-ShinyISO "$outdir\flags-iso\shiny\$size\$Code.png" `
			-Mask $Mask `
			-Size $size
	}
}

ForEach($flag in $normal) {
	$code = Get-Content "$indir\$flag\code"
	Define-Flag -Country $flag -Code $code -Mask "normal"
}

ForEach($flag in $square) {
	$code = Get-Content "$indir\$flag\code"
	Define-Flag -Country $flag -Code $code -Mask "square"
}

ForEach($flag in $nepal) {
	$code = Get-Content "$indir\$flag\code"
	Define-Flag -Country $flag -Code $code -Mask "nepal"
}

$flag_files
