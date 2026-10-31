$base = "https://restful-booker.herokuapp.com"
$json = @{
  firstname = "Ivan"; lastname = "Petrov"; totalprice = 150; depositpaid = $true
  bookingdates = @{ checkin = "2026-12-01"; checkout = "2026-12-05" }
  additionalneeds = "Breakfast"
} | ConvertTo-Json
$jsonUpdated = $json -replace "Ivan", "Georgi"

function Call-Api {
  param($Method, $Path, $Body = $null, $Session = $null)
  $p = @{ Uri = "$base$Path"; Method = $Method; Headers = @{ "Accept" = "application/json" }; UseBasicParsing = $true; TimeoutSec = 30 }
  if ($Body) { $p["Body"] = $Body; $p["ContentType"] = "application/json" }
  if ($Session) { $p["WebSession"] = $Session }
  try {
    $r = Invoke-WebRequest @p
    return [pscustomobject]@{ Status = [int]$r.StatusCode; Body = $r.Content }
  } catch {
    $code = "no response"
    if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
    return [pscustomobject]@{ Status = $code; Body = "" }
  }
}

$rows = @()
function Add-Row($n, $name, $expected, $allowed, $res) {
  if ($allowed -contains $res.Status) { $c = "As expected" }
  else { $c = "Differs from convention: expected $expected, got $($res.Status) (possible quirk)" }
  $script:rows += [pscustomobject]@{ N = $n; Request = $name; Expected = $expected; Status = $res.Status; Comment = $c }
}

Add-Row 1 "GET /ping" "200" @(200) (Call-Api GET "/ping")
$list = Call-Api GET "/booking"
Add-Row 2 "GET /booking" "200, list of IDs" @(200) $list
$firstId = ($list.Body | ConvertFrom-Json)[0].bookingid
Add-Row 3 "GET /booking/$firstId" "200, booking JSON" @(200) (Call-Api GET "/booking/$firstId")

$created = Call-Api POST "/booking" $json
Add-Row 4 "POST /booking" "201 Created" @(201) $created
$id = ($created.Body | ConvertFrom-Json).bookingid
$auth = Call-Api POST "/auth" '{"username":"admin","password":"password123"}'
Add-Row 5 "POST /auth" "200, token" @(200) $auth
$token = ($auth.Body | ConvertFrom-Json).token

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.Cookies.Add((New-Object System.Net.Cookie("token", $token, "/", "restful-booker.herokuapp.com")))

Add-Row 6 "PUT /booking/$id (token)" "200, updated booking" @(200) (Call-Api PUT "/booking/$id" $jsonUpdated $session)
Add-Row 7 "PATCH /booking/$id (token)" "200, only given field changed" @(200) (Call-Api PATCH "/booking/$id" '{"firstname":"Changed"}' $session)
Add-Row 8 "DELETE /booking/$id (token)" "200 or 204" @(200, 204) (Call-Api DELETE "/booking/$id" $null $session)
Add-Row 9 "GET /booking/$id after delete" "404" @(404) (Call-Api GET "/booking/$id")

$second = Call-Api POST "/booking" $json
$id2 = ($second.Body | ConvertFrom-Json).bookingid
Add-Row 10 "PUT /booking/$id2 (no token)" "401 or 403" @(401, 403) (Call-Api PUT "/booking/$id2" $json)

$rows | Format-Table N, Request, Expected, Status, Comment -AutoSize

$md = @()
$md += "# Day 3: Restful-Booker, first manual API requests"
$md += ""
$md += "Base URL: https://restful-booker.herokuapp.com"
$md += ""
$md += "| # | Request | Expected (REST convention) | Actual | Comment |"
$md += "|---|---|---|---|---|"
foreach ($r in $rows) { $md += "| $($r.N) | $($r.Request) | $($r.Expected) | $($r.Status) | $($r.Comment) |" }
$md += ""
$md += "## Quirks and possible bugs"
$q = $rows | Where-Object { $_.Comment -ne "As expected" }
if ($q) { foreach ($r in $q) { $md += "- Row $($r.N) $($r.Request): expected $($r.Expected), got $($r.Status)" } }
else { $md += "- None found in this run" }
$md += ""
$md += "## What I learned and debugging notes"
$md += "- Bookings disappear after a few minutes on the shared server, so a test must create its own data."
$md += "- I got 404 and 405 on PUT when the booking no longer existed."
$md += "- I got 403 on PUT until the token was fresh and the Cookie header was typed exactly as token=<value>."
$md += "- PUT, PATCH and DELETE need a token; the POST /auth response body contains it."
$md += "- A scripted request needed the token sent as a proper cookie; sending it as a plain header was rejected with 403."
$md | Set-Content -Path "$PSScriptRoot\day3-notes.md" -Encoding UTF8
Write-Host "Saved: $PSScriptRoot\day3-notes.md"
