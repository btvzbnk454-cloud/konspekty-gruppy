# Local preview: http://localhost:8080 (site) or -Root . -Port 8081 (whole repo, for drafts)
param([string]$Root = "site", [int]$Port = 8080)
$root = (Resolve-Path (Join-Path $PSScriptRoot $Root)).Path
$l = New-Object Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
Write-Host "Serving $root on http://localhost:$Port/"
$types = @{ ".html"="text/html; charset=utf-8"; ".txt"="text/plain; charset=utf-8"; ".css"="text/css"; ".js"="text/javascript"; ".png"="image/png"; ".jpg"="image/jpeg" }
while ($l.IsListening) {
  $c = $l.GetContext()
  $p = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath).TrimStart("/")
  if ($p -eq "" -or $p.EndsWith("/")) { $p += "index.html" }
  $f = Join-Path $root $p
  if (Test-Path $f -PathType Leaf) {
    $b = [IO.File]::ReadAllBytes($f)
    $ext = [IO.Path]::GetExtension($f)
    $c.Response.ContentType = if ($types[$ext]) { $types[$ext] } else { "application/octet-stream" }
    $c.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $c.Response.StatusCode = 404 }
  $c.Response.Close()
}
