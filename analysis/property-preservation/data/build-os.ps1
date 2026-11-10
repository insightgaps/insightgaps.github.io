# build-os.ps1 - Rebuilds the Property Preservation OS app (analysis/property-preservation/)
# from the frozen Demo OS snapshot (data/demo-os-2026-11-10/). Fictional demo data only.
# Run from the repo root: powershell -ExecutionPolicy Bypass -File analysis\property-preservation\data\build-os.ps1
#
# DESIGN (blueprint sec 5 + sec 10): ONE design system across every page. Options collected:
# 1 Google-Sheets-like plain grid (too raw, no hierarchy) | 2 dark ops console (figures lost in decoration)
# 3 card-heavy dashboard (violates one-metric-per-line) | 4 MINIMAL WHITE OS (CHOSEN) - white page,
# navy ink, hairline rules, one metric per line, plain tables, status chips, left nav
# 5 timeline/scrollytelling (wrong for an ops tool) | 6 kanban boards (wrong for money tables)
# 7 map-first (no geo data in the snapshot) | 8 print-brief style (too static, not interactive).
# The chosen system copies the real OS dashboard: plain, quiet, every number traceable to a row.
#
# OPEN QUESTIONS (blueprint sec 8) - recommended defaults used, all listed in the final report:
# Q1 Visual Twin: counts-only twin, no fake photographs (sec 3 / 4.11).
# Q2 Quo: Questions (82) as the labelled needs-answer proxy; no response rate, no unanswered queue.
# Q3 Refresh: daily snapshot + rebuild; the app serves the last good snapshot stamped with its as-of date.
# Q4 After 2026-12-31: freeze as-of 2026-11-10 (the snapshot date); the feed ends there.
# Q5 Growth: structure-only board - no invented prospect rows.
# Q6 Team Access: role table as structure only - no fictional roster, crew pay never shown.
# Q7 URL: the section index URL becomes the app entry (Dashboard); sections live under os/.
# Q8 Class + Test: the app is standalone; class and fresher test keep working, linked from the site
#    homepage/footer, never from inside the app (no Vault, no gate, no class-hub link on app pages).
# No submit / send / record / RFO button exists anywhere in the app. The demo reads; it never acts.
$ErrorActionPreference = 'Stop'
$AsOf = [datetime]'2026-11-10'
$Root = 'analysis\property-preservation'
$DataDir = Join-Path $Root 'data\demo-os-2026-11-10'
$Site = 'https://www.insightgaps.com'
$Base = '/analysis/property-preservation'
function Load-Table($name) { return (Get-Content (Join-Path $DataDir "$name.json") -Raw | ConvertFrom-Json).rows }
$Props = Load-Table 'properties'; $Clients = Load-Table 'clients'; $Crew = Load-Table 'crew'
$WOs = Load-Table 'work_orders'; $Bids = Load-Table 'bids'; $Invoices = Load-Table 'invoices'
$Payments = Load-Table 'payments'; $Msgs = Load-Table 'crew_messages'; $Problems = Load-Table 'problems'
$Manifest = Get-Content (Join-Path $DataDir 'manifest.json') -Raw | ConvertFrom-Json
function H($s) { return [System.Net.WebUtility]::HtmlEncode("$s") }
Remove-Item Alias:H -ErrorAction SilentlyContinue
function Money([decimal]$v) { return '$' + $v.ToString('N0') }
function MoneySigned([decimal]$v) { if ($v -lt 0) { return '-$' + (-$v).ToString('N0') }; return '$' + $v.ToString('N0') }
function Pct1([double]$v) { return ($v).ToString('N1') + '%' }
function D([string]$s) { if ("$s" -eq '') { return $null }; return [datetime]$s }
function SumF([object[]]$rows, [string]$field) { [decimal]($rows | ForEach-Object { [decimal]$_.$field } | Measure-Object -Sum).Sum }
function GroupCount([object[]]$rows, [string]$field) { $h = @{}; $rows | Group-Object $field | ForEach-Object { $h["$($_.Name)"] = $_.Count }; return $h }
# lookups
$PropById = @{}; $Props | ForEach-Object { $PropById[$_.'Property ID'] = $_ }
$ClientById = @{}; $Clients | ForEach-Object { $ClientById[$_.'Client ID'] = $_ }
$CrewById = @{}; $Crew | ForEach-Object { $CrewById[$_.'Crew ID'] = $_ }
$WoById = @{}; $WOs | ForEach-Object { $WoById[$_.'WO Number'] = $_ }
$BidById = @{}; $Bids | ForEach-Object { $BidById[$_.'Bid ID'] = $_ }
$InvById = @{}; $Invoices | ForEach-Object { $InvById[$_.'Invoice ID'] = $_ }
$WOsByProp = @{}; $WOs | Group-Object 'Property ID' | ForEach-Object { $WOsByProp[$_.Name] = $_.Group }
$BidsByWo = @{}; $Bids | Group-Object 'WO Number' | ForEach-Object { $BidsByWo[$_.Name] = $_.Group }
$InvByWo = @{}; $Invoices | Group-Object 'WO Number' | ForEach-Object { $InvByWo[$_.Name] = $_.Group }
$PayByInv = @{}; $Payments | Group-Object 'Invoice ID' | ForEach-Object { $PayByInv[$_.Name] = $_.Group }
$MsgByWo = @{}; $Msgs | Group-Object 'WO Number' | ForEach-Object { $MsgByWo[$_.Name] = $_.Group }
$MsgByProp = @{}; $Msgs | Group-Object 'Property ID' | ForEach-Object { $MsgByProp[$_.Name] = $_.Group }
# --- computed aggregates (all recomputed from the snapshot rows; nothing invented) ---
$OpenWOs = $WOs | Where-Object { $_.Status -in 'Assigned','In Progress','Ready for Office' }
$PastDue = $OpenWOs | Where-Object { [datetime]$_.'Due Date' -le $AsOf }
$DueToday = $OpenWOs | Where-Object { [datetime]$_.'Due Date' -eq $AsOf }
$Due48 = $OpenWOs | Where-Object { [datetime]$_.'Due Date' -gt $AsOf -and [datetime]$_.'Due Date' -le $AsOf.AddDays(2) }
$Due7 = $OpenWOs | Where-Object { [datetime]$_.'Due Date' -gt $AsOf -and [datetime]$_.'Due Date' -le $AsOf.AddDays(7) }
$Billed = SumF $Invoices 'Amount'; $Received = SumF $Invoices 'Amount Received'; $Outstanding = SumF $Invoices 'Balance'
$OverdueBal = SumF ($Invoices | Where-Object { [datetime]$_.'Due Date' -lt $AsOf -and [decimal]$_.Balance -gt 0 }) 'Balance'
$OverdueStatusBal = SumF ($Invoices | Where-Object { $_.Status -eq 'Overdue' }) 'Balance'
$PartialOverdueBal = SumF ($Invoices | Where-Object { $_.Status -eq 'Partially Paid' -and [datetime]$_.'Due Date' -lt $AsOf }) 'Balance'
$NotYetDueBal = $Outstanding - $OverdueBal
$PaySum = SumF $Payments 'Amount'
$ApprovalRate = [math]::Round((($Bids | Where-Object { $_.Status -in 'Approved','Cut' }).Count / $Bids.Count) * 100, 1)
$CutTotal = [decimal](($Bids | Where-Object { $_.Status -eq 'Cut' } | ForEach-Object { [decimal]$_.'Bid Amount' - [decimal]$_.'Approved Amount' } | Measure-Object -Sum).Sum)
$AboveCeil = $Bids | Where-Object { [decimal]$_.'Bid Amount' -gt [decimal]$_.'Client Ceiling' }
$AboveCeilExposure = [decimal](($AboveCeil | ForEach-Object { [decimal]$_.'Bid Amount' - [decimal]$_.'Client Ceiling' } | Measure-Object -Sum).Sum)
$BidGaps = ($WOs | Where-Object { $_.'Bid Needed' -eq 'Y' -and $_.Status -ne 'Cancelled' }) | Where-Object { $_.'WO Number' -notin ($Bids | ForEach-Object { $_.'WO Number' }) }
$Chains = $WOs | Where-Object { "$($_.'Supersedes WO')" -ne '' }
$PhotoGate = $WOs | Where-Object { $_.'WO Type' -eq 'Winterization' -and $_.'Pressure Test Photo' -eq 'Missing' }
$MsgsToday = $Msgs | Where-Object { $_.Date -eq '2026-11-10' }
$WoToday = $WOs | Where-Object { $_.'Date Assigned' -eq '2026-11-10' }
$NewProps26 = $Props | Where-Object { [datetime]$_.'First Seen' -ge [datetime]'2026-01-01' }
# per-client money
$ClientTable = @()
foreach ($c in $Clients) {
  $id = $c.'Client ID'
  $cinvs = $Invoices | Where-Object { $_.'Client ID' -eq $id }
  $cbids = $Bids | Where-Object { $_.'Client ID' -eq $id }
  $cwos = $WOs | Where-Object { $_.'Client ID' -eq $id }
  $cprops = $Props | Where-Object { $_.'Client ID' -eq $id }
  $cbilled = SumF $cinvs 'Amount'; $creceived = SumF $cinvs 'Amount Received'; $cout = SumF $cinvs 'Balance'
  $coverdue = SumF ($cinvs | Where-Object { [datetime]$_.'Due Date' -lt $AsOf -and [decimal]$_.Balance -gt 0 }) 'Balance'
  $cpaid = ($cinvs | Where-Object { $_.Status -eq 'Paid' }).Count
  $cdecided = ($cbids | Where-Object { $_.Status -in 'Approved','Cut' }).Count
  $ccut = ($cbids | Where-Object { $_.Status -eq 'Cut' }).Count
  $ccutTotal = [decimal](($cbids | Where-Object { $_.Status -eq 'Cut' } | ForEach-Object { [decimal]$_.'Bid Amount' - [decimal]$_.'Approved Amount' } | Measure-Object -Sum).Sum)
  $cdays = @()
  foreach ($inv in ($cinvs | Where-Object { [decimal]$_.Balance -eq 0 })) { $pays = $PayByInv[$inv.'Invoice ID']; if ($pays) { $last = ($pays | ForEach-Object { [datetime]$_.'Payment Date' } | Measure-Object -Maximum).Maximum; $cdays += ($last - [datetime]$inv.'Invoice Date').Days } }
  $cavg = if ($cdays.Count -gt 0) { [math]::Round(($cdays | Measure-Object -Average).Average, 1) } else { $null }
  $cratio = if ($cbilled -gt 0) { [math]::Round($creceived / $cbilled, 3) } else { $null }
  $cverdict = if ($cratio -ge 0.75) { 'Scale' } elseif ($cratio -ge 0.5) { 'Monitor' } else { 'Reprice' }
  $ClientTable += [pscustomobject]@{ Id = $id; Name = $c.'Client Name'; Type = $c.Type; Terms = $c.'Payment Terms'; Contact = $c.'Contact Name'; WOs = $cwos.Count; Props = $cprops.Count; Billed = $cbilled; Received = $creceived; Outstanding = $cout; OverdueBal = $coverdue; Paid = $cpaid; Invoices = $cinvs.Count; Bids = $cbids.Count; ApprovalRate = if ($cbids.Count -gt 0) { [math]::Round($cdecided / $cbids.Count * 100, 1) } else { $null }; Cut = $ccut; CutTotal = $ccutTotal; AvgDays = $cavg; Ratio = $cratio; Verdict = $cverdict }
}
# per-crew workload
$CrewTable = @()
foreach ($m in $Crew) {
  $id = $m.'Crew ID'
  $mclosed = ($WOs | Where-Object { $_.'Crew ID' -eq $id -and $_.Status -eq 'Closed' }).Count
  $mopen = ($WOs | Where-Object { $_.'Crew ID' -eq $id -and $_.Status -in 'Assigned','In Progress','Ready for Office' }).Count
  $mmsgs = ($Msgs | Where-Object { $_.'Crew ID' -eq $id }).Count
  $mques = ($Msgs | Where-Object { $_.'Crew ID' -eq $id -and $_.Type -eq 'Question' }).Count
  $CrewTable += [pscustomobject]@{ Id = $id; Name = $m.Name; Role = $m.Role; Base = $m.'Home Base'; Phone = $m.Phone; Skills = $m.Skills; Since = $m.'Active Since'; Rating = $m.Rating; Jobs2025 = $m.'Jobs Completed 2025'; Closed = $mclosed; Open = $mopen; Messages = $mmsgs; Questions = $mques; Status = $m.Status }
}
$CrewTable = $CrewTable | Sort-Object Closed -Descending
# --- readiness checklist (submission queue), photo QC, intake series, war room, losses ---
function Get-RfoIssues($wo) {
  $issues = @()
  if ([int]$wo.'Photos Before' -eq 0) { $issues += 'No before photos' }
  if ([int]$wo.'Photos During' -eq 0) { $issues += 'No during photos' }
  if ([int]$wo.'Photos After' -eq 0) { $issues += 'No after photos' }
  if ($wo.'WO Type' -eq 'Winterization' -and $wo.'Pressure Test Photo' -eq 'Missing') { $issues += 'Pressure-test photo missing' }
  $b = $BidsByWo[$wo.'WO Number']
  if ($wo.'Bid Needed' -eq 'Y' -and -not $b) { $issues += 'Bid needed, no bid submitted' }
  elseif ($b -and -not ($b | Where-Object { "$($_.'Date Decided')" -ne '' })) { $issues += 'Bid decision still pending' }
  foreach ($p in $Problems) { if ($p.'Where to Look (exact IDs)' -match [regex]::Escape($wo.'WO Number')) { $issues += ("Open problem $($p.'Problem #') linked") } }
  return $issues
}
$RfoWOs = $OpenWOs | Where-Object { $_.Status -eq 'Ready for Office' }
$RfoChecks = @(); foreach ($w in $RfoWOs) { $iss = Get-RfoIssues $w; $RfoChecks += [pscustomobject]@{ WO = $w; Issues = $iss; Ready = ($iss.Count -eq 0) } }
$RfoReady = ($RfoChecks | Where-Object { $_.Ready }).Count
$ZeroBefore = ($WOs | Where-Object { [int]$_.'Photos Before' -eq 0 }).Count
$ZeroDuring = ($WOs | Where-Object { [int]$_.'Photos During' -eq 0 }).Count
$ZeroAfter = ($WOs | Where-Object { [int]$_.'Photos After' -eq 0 }).Count
$AnyZeroPhase = ($WOs | Where-Object { [int]$_.'Photos Before' -eq 0 -or [int]$_.'Photos During' -eq 0 -or [int]$_.'Photos After' -eq 0 }).Count
$TotalPhotosBefore = ($WOs | ForEach-Object { [int]$_.'Photos Before' } | Measure-Object -Sum).Sum
$TotalPhotosDuring = ($WOs | ForEach-Object { [int]$_.'Photos During' } | Measure-Object -Sum).Sum
$TotalPhotosAfter = ($WOs | ForEach-Object { [int]$_.'Photos After' } | Measure-Object -Sum).Sum
$AssignedByDay = @{}; $WOs | Group-Object 'Date Assigned' | ForEach-Object { $AssignedByDay[$_.Name] = $_.Count }
$MsgsByDay = @{}; $Msgs | Group-Object 'Date' | ForEach-Object { $MsgsByDay[$_.Name] = $_.Count }
$Questions = $Msgs | Where-Object { $_.Type -eq 'Question' }
$MsgByCrew = @{}; $Msgs | Group-Object 'Crew ID' | ForEach-Object { $MsgByCrew[$_.Name] = $_.Count }
$InvReceivedAny = ($Invoices | Where-Object { [decimal]$_.'Amount Received' -gt 0 }).Count
$InvClosedWo = ($Invoices | Where-Object { $WoById[$_.'WO Number'] -and $WoById[$_.'WO Number'].Status -eq 'Closed' }).Count
$PaidViaSuccessor = $InvById['DEMO-INV-3902']
$Chargebacks = ($Invoices | Where-Object { $_.Notes -match 'chargeback' }).Count
$Ageing = @{
  NotYetDue = 0; P1_30 = 0; P31_60 = 0; P61_90 = 0; P90Plus = 0
}
$AgeingAmt = @{ NotYetDue = [decimal]0; P1_30 = [decimal]0; P31_60 = [decimal]0; P61_90 = [decimal]0; P90Plus = [decimal]0 }
foreach ($inv in ($Invoices | Where-Object { [decimal]$_.Balance -gt 0 })) {
  $days = ($AsOf - [datetime]$inv.'Due Date').Days
  $band = if ($days -le 0) { 'NotYetDue' } elseif ($days -le 30) { 'P1_30' } elseif ($days -le 60) { 'P31_60' } elseif ($days -le 90) { 'P61_90' } else { 'P90Plus' }
  $Ageing[$band]++; $AgeingAmt[$band] += [decimal]$inv.Balance
}
# problem ages recomputed from snapshot date (old titles used 2026-02-28)
$PA1 = [datetime]$BidById['DEMO-B-2901'].'Date Submitted'
$PA2 = [datetime]$InvById['DEMO-INV-3901'].'Due Date'
$PA3 = [datetime]$InvById['DEMO-INV-3902'].'Due Date'
$PA4 = [datetime]'2025-09-16'
$PA5 = [datetime]($WoById['DEMO-WO-1907'] | ForEach-Object { $_.'Date Completed' })
$PA6 = [datetime]$BidById['DEMO-B-2906'].'Date Submitted'
$ProblemAges = @{ P1 = ($AsOf - $PA1).Days; P2 = ($AsOf - $PA2).Days; P3 = ($AsOf - $PA3).Days; P4 = ($AsOf - $PA4).Days; P5 = ($AsOf - $PA5).Days; P6 = ($AsOf - $PA6).Days }
$ProblemTitles = @{ P1 = 'Bid approval overdue'; P2 = 'Invoice unpaid, past due'; P3 = 'Looks unpaid - paid under a follow-up WO'; P4 = 'One crew, two jobs, same day'; P5 = 'Winterization closed with no pressure-test photo'; P6 = 'Bid above the client ceiling' }
# --- one design system (os.css) ---
$Css = @"
:root{--ink:#14202e;--muted:#5a6673;--line:#dfe4e8;--bg:#f4f6f7;--navy:#16324f;--navy2:#0f2438;--accent:#1b6ca8;--amber:#f5c518;--amberbg:#fdf3d7;--redbg:#fbe4e4;--red:#9b1c1c;--greenbg:#e2f2e4;--green:#1d5c2e;--amberbg2:#fdf0d3;--amber2:#8a6d00}
body{margin:0;font-family:system-ui,-apple-system,"Segoe UI",Roboto,Arial,sans-serif;background:var(--bg);color:var(--ink);font-size:15px;line-height:1.5}
.os-top{background:var(--navy2);color:#fff;padding:10px 16px;display:flex;gap:16px;align-items:baseline;flex-wrap:wrap}
.os-top a{color:#fff;text-decoration:none}
.os-top .brand{font-weight:700;font-size:17px}
.os-top .asof{color:#c7d3de;font-size:13px}
.os-demo{font-size:12px;background:var(--amber);color:#1a1a1a;padding:2px 8px;border-radius:10px;font-weight:700}
.os-banner{background:var(--amberbg);border-bottom:1px solid #e8d28a;padding:8px 16px;font-size:14px}
.os-wrap{display:grid;grid-template-columns:220px 1fr;min-height:100vh}
.os-nav{position:sticky;top:0;align-self:start;height:100vh;overflow:auto;background:#fff;border-right:1px solid var(--line);padding:14px 10px}
.os-nav h3{font-size:12px;text-transform:uppercase;letter-spacing:.06em;color:var(--muted);margin:16px 8px 6px}
.os-nav ul{list-style:none;margin:0;padding:0}
.os-nav a{display:block;padding:6px 8px;border-radius:6px;color:var(--ink);text-decoration:none}
.os-nav a:hover{background:var(--bg)}
.os-nav a[aria-current="page"]{background:#e7eef4;font-weight:700;color:var(--navy)}
main{padding:20px 24px 48px}
h1{font-size:24px;margin:0 0 4px}h2{font-size:19px;margin:28px 0 8px;border-bottom:1px solid var(--line);padding-bottom:4px}h3{font-size:16px;margin:20px 0 6px}
.lede{color:var(--muted);margin:0 0 16px}
.tiles{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:12px;margin:16px 0}
.tile{background:#fff;border:1px solid var(--line);border-radius:8px;padding:12px 14px}
.tile .k{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.05em}
.tile .v{font-size:26px;font-weight:700;font-variant-numeric:tabular-nums;line-height:1.2}
.tile .s{font-size:13px;color:var(--muted)}
table.os-table{width:100%;border-collapse:collapse;background:#fff;font-size:14px}
.os-table th,.os-table td{text-align:left;padding:7px 10px;border-bottom:1px solid var(--line);vertical-align:top}
.os-table thead th{position:sticky;top:0;background:#f0f2f4;border-bottom:2px solid var(--line)}
.os-table th[data-sort]{cursor:pointer}.os-table th[data-sort]:hover{color:var(--accent)}
.os-table tr:hover td{background:#f8fafb}
.os-table td.num,.os-table th.num,.num{text-align:right;font-variant-numeric:tabular-nums}
.chip{display:inline-block;padding:1px 8px;border-radius:10px;font-size:12px;font-weight:600;background:#eef1f3}
.chip.ok{background:var(--greenbg);color:var(--green)}
.chip.bad{background:var(--redbg);color:var(--red)}
.chip.warn{background:var(--amberbg2);color:var(--amber2)}
.chip.info{background:#e6edf3;color:var(--navy)}
.filterbar{display:flex;gap:8px;flex-wrap:wrap;margin:12px 0;align-items:center}
.filterbar input[type="search"],.filterbar select,.filterbar input[type="text"]{padding:7px 10px;border:1px solid var(--line);border-radius:6px;font:inherit;background:#fff;min-width:200px}
.note{background:#f7f9fa;border-left:3px solid var(--navy);padding:10px 14px;margin:16px 0;font-size:14px}
.note.warn{border-left-color:var(--amber)}
.note.bad{border-left-color:var(--red)}
.kv{width:100%;border-collapse:collapse;background:#fff;border:1px solid var(--line);font-size:14px}
.kv th{text-align:left;padding:8px 10px;background:#f0f2f4;border-bottom:1px solid var(--line);width:240px;vertical-align:top}
.kv td{padding:8px 10px;border-bottom:1px solid var(--line);vertical-align:top}
.kv tr:last-child th,.kv tr:last-child td{border-bottom:0}
details{margin:10px 0;background:#fff;border:1px solid var(--line);border-radius:8px;padding:10px 14px}
details summary{cursor:pointer;font-weight:600}
.os-foot{max-width:1180px;margin:0 auto;padding:24px 16px 48px;color:var(--muted);font-size:13px;border-top:1px solid var(--line)}
.os-foot a{color:var(--muted)}
.skip{position:absolute;left:-999px}
.skip:focus{left:8px;top:8px;background:#fff;padding:6px 10px;z-index:10}
.muted{color:var(--muted)}
.small{font-size:13px}
@media (max-width:860px){.os-wrap{grid-template-columns:1fr}.os-nav{position:static}.os-nav ul{display:flex;flex-wrap:wrap;gap:4px}.os-nav a{padding:4px 8px}}
@media print{.os-nav,.os-banner,.filterbar{display:none}.os-wrap{grid-template-columns:1fr}}
"@
New-Item -ItemType Directory -Force (Join-Path $Root 'os\assets') | Out-Null
Set-Content -Path (Join-Path $Root 'os\assets\os.css') -Value $Css -Encoding UTF8
Write-Output 'css section appended'

# --- client-side helpers (os.js) ---
$Js = @"
'use strict';
function oshort(s){return (s===null||s===undefined)?'':String(s);}
function norm(s){return oshort(s).toLowerCase();}
function esc(s){return oshort(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
function numVal(t){var c=oshort(t).replace(/[^0-9.\-]/g,'');var n=parseFloat(c);return isNaN(n)?NaN:n;}
function qsa(s,r){return Array.prototype.slice.call((r||document).querySelectorAll(s));}
function qs(s,r){return (r||document).querySelector(s);}
function money(n){return '$'+Number(n).toLocaleString('en-US',{minimumFractionDigits:0,maximumFractionDigits:0});}
function kv(k,v){return '<tr><th scope="row">'+esc(k)+'</th><td>'+v+'</td></tr>';}
document.addEventListener('DOMContentLoaded',function(){
  qsa('[data-filter-for]').forEach(function(inp){
    var tbl=document.getElementById(inp.getAttribute('data-filter-for'));
    if(!tbl)return;
    inp.addEventListener('input',function(){
      var q=norm(inp.value);
      qsa('tbody tr',tbl).forEach(function(tr){tr.style.display=(q===''||norm(tr.textContent).indexOf(q)>-1)?'':'none';});
    });
  });
  qsa('th[data-sort]').forEach(function(th){
    th.addEventListener('click',function(){
      var tbl=th.closest('table');var tb=qs('tbody',tbl);if(!tb)return;
      var idx=Array.prototype.indexOf.call(th.parentNode.children,th);
      var dir=th.getAttribute('data-dir')==='asc'?'desc':'asc';
      qsa('th[data-sort]',tbl).forEach(function(x){x.removeAttribute('data-dir');});
      th.setAttribute('data-dir',dir);
      var rows=qsa('tr',tb);
      rows.sort(function(a,b){
        var ta=a.children[idx]?a.children[idx].textContent.trim():'';
        var tb2=b.children[idx]?b.children[idx].textContent.trim():'';
        var na=numVal(ta),nb=numVal(tb2),cmp;
        if(!isNaN(na)&&!isNaN(nb)){cmp=na-nb;}else{cmp=ta.localeCompare(tb2);}
        return dir==='asc'?cmp:-cmp;
      });
      rows.forEach(function(r){tb.appendChild(r);});
    });
  });
  var c1=qs('#twin-a'),c2=qs('#twin-b');
  if(c1&&c2){
    var la=qs('#twin-a-label'),lb=qs('#twin-b-label');
    function upd(){
      qsa('[data-visit]').forEach(function(el){var v=el.getAttribute('data-visit');el.style.display=(v===c1.value||v===c2.value)?'':'none';});
      if(la)la.textContent=c1.options[c1.selectedIndex].textContent;
      if(lb)lb.textContent=c2.options[c2.selectedIndex].textContent;
    }
    c1.addEventListener('change',upd);c2.addEventListener('change',upd);upd();
  }
  var si=qs('#search-input');
  if(si){
    var res=qs('#search-results');var idx=null;
    fetch('/analysis/property-preservation/os/assets/search-index.json').then(function(r){return r.json();}).then(function(j){idx=j;});
    si.addEventListener('input',function(){
      var q=norm(si.value).trim();
      if(!q||!idx){if(res)res.innerHTML='';return;}
      var hits=idx.filter(function(it){return norm(it.t+' '+it.s+' '+it.k).indexOf(q)>-1;}).slice(0,60);
      var html=hits.map(function(it){return '<div class="search-hit"><a href="'+it.u+'">'+esc(it.t)+'</a> <span class="muted">'+esc(it.s)+'</span></div>';}).join('');
      if(res)res.innerHTML=hits.length?html:'<p class="muted">No matches.</p>';
      if(hits.length===0&&res)res.innerHTML='<p class="muted">No matches.</p>';
    });
  }
  var det=qs('#wo-detail');
  if(det){
    var wo=(new URLSearchParams(location.search)).get('wo')||'';
    var base='/analysis/property-preservation/data/demo-os-2026-11-10/';
    function load(n){return fetch(base+n).then(function(r){return r.json();}).then(function(j){return j.rows;});}
    Promise.all([load('work_orders.json'),load('bids.json'),load('invoices.json'),load('payments.json'),load('crew_messages.json')]).then(function(a){
      var wos=a[0],bids=a[1],invs=a[2],pays=a[3],msgs=a[4];
      var w2=null;
      for(var i=0;i<wos.length;i++){if(wos[i]['WO Number']===wo){w2=wos[i];break;}}
      if(!w2){det.innerHTML='<p class="note bad">Work order '+esc(wo)+' was not found in the snapshot.</p>';return;}
      var html='<h2>'+esc(w2['WO Number'])+' - '+esc(w2['WO Type'])+' - '+esc(w2['Status'])+'</h2>';
      html+='<table class="kv">';
      html+=kv('Property',esc(w2['Property ID']+' - '+w2['Property Address'])+' (<a href="/analysis/property-preservation/os/property-master/'+w2['Property ID']+'/">property page</a>)');
      html+=kv('Client',esc(w2['Client Name']+' ('+w2['Client ID']+')'));
      html+=kv('Crew',esc(w2['Crew Name']+' ('+w2['Crew ID']+')'));
      html+=kv('Scope',esc(w2['Scope / Description']));
      html+=kv('Assigned',esc(w2['Date Assigned']+' - due '+w2['Due Date']+(w2['Date Completed']?' - completed '+w2['Date Completed']:'')));
      html+=kv('Bid needed',esc(w2['Bid Needed']));
      html+=kv('Photos',esc('before '+w2['Photos Before']+' - during '+w2['Photos During']+' - after '+w2['Photos After']));
      html+=kv('Pressure-test photo',esc(w2['Pressure Test Photo']));
      if(w2['Supersedes WO']){html+=kv('Supersedes',esc(w2['Supersedes WO']));}
      html+='</table>';
      var bs=bids.filter(function(b){return b['WO Number']===wo;});
      html+='<h3>Bids ('+bs.length+')</h3>';
      if(bs.length){
        html+='<table class="os-table"><thead><tr><th>Bid</th><th>Scope</th><th class="num">Bid</th><th class="num">Ceiling</th><th class="num">Approved</th><th>Status</th><th>Submitted</th><th>Decided</th></tr></thead><tbody>';
        bs.forEach(function(b){html+='<tr><td>'+esc(b['Bid ID'])+'</td><td>'+esc(b['Item / Scope'])+'</td><td class="num">'+money(b['Bid Amount'])+'</td><td class="num">'+money(b['Client Ceiling'])+'</td><td class="num">'+money(b['Approved Amount'])+'</td><td>'+esc(b['Status'])+'</td><td>'+esc(b['Date Submitted'])+'</td><td>'+esc(b['Date Decided'])+'</td></tr>';});
        html+='</tbody></table>';
      } else { html+='<p class="muted">No bid submitted for this work order.</p>'; }
      var ivs=invs.filter(function(iv){return iv['WO Number']===wo;});
      html+='<h3>Invoices ('+ivs.length+')</h3>';
      if(ivs.length){
        html+='<table class="os-table"><thead><tr><th>Invoice</th><th>Date</th><th class="num">Amount</th><th>Due</th><th class="num">Received</th><th class="num">Balance</th><th>Status</th></tr></thead><tbody>';
        ivs.forEach(function(iv){html+='<tr><td>'+esc(iv['Invoice ID'])+'</td><td>'+esc(iv['Invoice Date'])+'</td><td class="num">'+money(iv['Amount'])+'</td><td>'+esc(iv['Due Date'])+'</td><td class="num">'+money(iv['Amount Received'])+'</td><td class="num">'+money(iv['Balance'])+'</td><td>'+esc(iv['Status'])+'</td></tr>';});
        html+='</tbody></table>';
      } else { html+='<p class="muted">No invoice for this work order.</p>'; }
      var ps=pays.filter(function(p){return p['WO Number']===wo;});
      html+='<h3>Payments ('+ps.length+')</h3>';
      if(ps.length){
        html+='<table class="os-table"><thead><tr><th>Payment</th><th>Invoice</th><th>Date</th><th class="num">Amount</th><th>Method</th><th>Reference</th></tr></thead><tbody>';
        ps.forEach(function(p){html+='<tr><td>'+esc(p['Payment ID'])+'</td><td>'+esc(p['Invoice ID'])+'</td><td>'+esc(p['Payment Date'])+'</td><td class="num">'+money(p['Amount'])+'</td><td>'+esc(p['Method'])+'</td><td>'+esc(p['Reference'])+'</td></tr>';});
        html+='</tbody></table>';
      } else { html+='<p class="muted">No payments recorded for this work order.</p>'; }
      var ms=msgs.filter(function(m){return m['WO Number']===wo;});
      html+='<h3>Crew messages ('+ms.length+')</h3>';
      if(ms.length){
        html+='<table class="os-table"><thead><tr><th>Date</th><th>Time</th><th>Crew</th><th>Type</th><th>Message</th></tr></thead><tbody>';
        ms.forEach(function(m){html+='<tr><td>'+esc(m['Date'])+'</td><td>'+esc(m['Time'])+'</td><td>'+esc(m['Crew Name'])+'</td><td>'+esc(m['Type'])+'</td><td>'+esc(m['Message'])+'</td></tr>';});
        html+='</tbody></table>';
      } else { html+='<p class="muted">No crew messages for this work order.</p>'; }
      det.innerHTML=html;
    }).catch(function(err){det.innerHTML='<p class="note bad">Could not load work-order data: '+esc(err.message)+'</p>';});
  }
});
"@
Set-Content -Path (Join-Path $Root 'os\assets\os.js') -Value $Js -Encoding UTF8
Write-Output 'js section appended'
# --- page shell helpers ---
$BilledStr = Money $Billed; $ReceivedStr = Money $Received; $OutstandingStr = Money $Outstanding; $OverdueStr = Money $OverdueBal; $NotYetDueStr = Money $NotYetDueBal
$NavGroups = @(
    @{ Group='Overview'; Items=@(@{Slug='';Label='Dashboard'},@{Slug='command-board';Label='Command Board'},@{Slug='meeting-brief';Label='Meeting Brief'}) },
    @{ Group='Work'; Items=@(@{Slug='intake';Label='Intake'},@{Slug='live-ops';Label='Live Ops'},@{Slug='deadlines';Label='Deadlines'},@{Slug='work-orders';Label='Work Orders'},@{Slug='bids';Label='Bids'},@{Slug='submission-queue';Label='Submission Queue'}) },
    @{ Group='Money'; Items=@(@{Slug='invoices';Label='Invoices'},@{Slug='payments';Label='Payments'},@{Slug='war-room';Label='War Room'},@{Slug='losses';Label='Losses'}) },
    @{ Group='Quality'; Items=@(@{Slug='photo-qc';Label='Photo QC'},@{Slug='visual-twin';Label='Visual Twin'}) },
    @{ Group='People'; Items=@(@{Slug='clients';Label='Clients'},@{Slug='crew';Label='Crew'},@{Slug='quo';Label='Quo'}) },
    @{ Group='Reference'; Items=@(@{Slug='property-master';Label='Property Master'},@{Slug='problems';Label='Problems to Solve'},@{Slug='growth';Label='Growth'},@{Slug='team-access';Label='Team Access'},@{Slug='search';Label='Search'}) }
)
function Get-NavHtml {
    param([string]$Current)
    $out = ''
    foreach ($g in $NavGroups) {
        $out += '<h3>' + (H $g.Group) + '</h3><ul>'
        foreach ($it in $g.Items) {
            $url = if ($it.Slug) { "$Base/os/$($it.Slug)/" } else { "$Base/" }
            $cur = if ($it.Slug -eq $Current) { ' aria-current="page"' } else { '' }
            $out += '<li><a href="' + $url + '"' + $cur + '>' + (H $it.Label) + '</a></li>'
        }
        $out += '</ul>'
    }
    return $out
}
function Tile {
    param([string]$K,[string]$V,[string]$S='')
    $sub = if ($S) { '<div class="s">' + (H $S) + '</div>' } else { '' }
    return '<div class="tile"><div class="k">' + (H $K) + '</div><div class="v">' + $V + '</div>' + $sub + '</div>'
}
function Tiles {
    param([object[]]$Items)
    $t = '<div class="tiles">'
    foreach ($it in $Items) { $t += Tile -K $it[0] -V $it[1] -S $it[2] }
    return $t + '</div>'
}
function Tbl {
    param([string]$Id,[string[]]$Headers,[object[]]$Rows,[switch]$NoFilter)
    $th = ''
    foreach ($h in $Headers) {
        if ($h.StartsWith('#')) { $th += '<th scope="col" data-sort class="num">' + (H $h.Substring(1)) + '</th>' }
        else { $th += '<th scope="col" data-sort>' + (H $h) + '</th>' }
    }
    $tr = ''
    foreach ($r in $Rows) {
        $tr += '<tr>'
      if ($r.Count -ne $Headers.Count) { throw ('Tbl ' + $Id + ': row has ' + $r.Count + ' cells but ' + $Headers.Count + ' headers; first cell = ' + $r[0]) }
        for ($i=0; $i -lt $r.Count; $i++) {
            $numCls = if ($Headers[$i].StartsWith('#')) { ' class="num"' } else { '' }
            $tr += '<td' + $numCls + '>' + $r[$i] + '</td>'
        }
        $tr += '</tr>'
    }
    $fb = if (-not $NoFilter) { '<div class="filterbar"><label class="small muted" for="f-' + $Id + '">Filter</label><input type="search" id="f-' + $Id + '" data-filter-for="' + $Id + '" placeholder="Type to filter this table"></div>' } else { '' }
    return $fb + '<table class="os-table" id="' + $Id + '"><thead><tr>' + $th + '</tr></thead><tbody>' + $tr + '</tbody></table>'
}
function KV {
    param([object[]]$Pairs)
    $out = '<table class="kv"><tbody>'
    foreach ($p in $Pairs) { $out += '<tr><th scope="row">' + (H $p[0]) + '</th><td>' + $p[1] + '</td></tr>' }
    return $out + '</tbody></table>'
}
function Chip {
    param([string]$Text,[string]$Kind='info')
    return '<span class="chip ' + $Kind + '">' + (H $Text) + '</span>'
}
function WoLink($wo){ return '<a href="' + $Base + '/os/work-orders/detail/?wo=' + $wo + '">' + (H $wo) + '</a>' }
function PropLink($propId){ return '<a href="' + $Base + '/os/property-master/' + $propId + '/">' + (H $propId) + '</a>' }
function Note {
    param([string]$Text,[string]$Kind='')
    $cls = if ($Kind) { 'note ' + $Kind } else { 'note' }
    return '<div class="' + $cls + '">' + $Text + '</div>'
}
function Details {
    param([string]$Summary,[string]$Body)
    return '<details><summary>' + (H $Summary) + '</summary>' + $Body + '</details>'
}
function Write-Page {
    param([string]$RelDir,[string]$FileName,[string]$Html)
    $dir = if ($RelDir) { Join-Path $Root $RelDir } else { $Root }
    New-Item -ItemType Directory -Force $dir | Out-Null
    Set-Content -Path (Join-Path $dir $FileName) -Value $Html -Encoding UTF8
}
function Page {
    param([string]$Slug,[string]$Title,[string]$Body,[string]$Desc)
    $urlPath = if ($Slug) { "$Base/os/$Slug/" } else { "$Base/" }
    $canon = "$Site$urlPath"
    $nav = Get-NavHtml -Current $Slug
    $descHtml = if ($Desc) { '<meta name="description" content="' + (H $Desc) + '">' } else { '' }
    $html = @"
<!doctype html>
<html lang="en-US">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$Title - Property Preservation OS (Demo)</title>
$descHtml
<link rel="canonical" href="$canon">
<link rel="stylesheet" href="$Base/os/assets/os.css">
</head>
<body>
<a class="skip" href="#main">Skip to main content</a>
<header class="os-top">
<a class="brand" href="$Base/">Property Preservation OS</a>
<span class="asof">Demo - fictional data - snapshot as of 2026-11-10</span>
<span class="os-demo">DEMO</span>
</header>
<div class="os-banner">This is a <strong>demo</strong> of a property preservation operations system. Every figure on this page is computed from the fictional Demo OS snapshot as of <strong>2026-11-10</strong>. No real properties, clients, crew, or money appear anywhere.</div>
<div class="os-wrap">
<nav class="os-nav" aria-label="OS sections">
$nav
</nav>
<main id="main">
$Body
</main>
</div>
<footer class="os-foot">
<p><strong>Method.</strong> All figures are computed from the Demo OS snapshot (10 JSON tables) as of 2026-11-10. Money reconciles: billed $BilledStr = received $ReceivedStr + outstanding $OutstandingStr. <a href="$Base/data/demo-os-2026-11-10/manifest.json">Snapshot manifest (JSON)</a> - <a href="$Base/data/demo-os-2026-11-10/">Snapshot data (JSON)</a>. Fictional data only.</p>
<p><a href="https://www.insightgaps.com/">InsightGaps</a> - Property Preservation OS demo - Snapshot as of 2026-11-10</p>
</footer>
<script src="$Base/os/assets/os.js"></script>
</body>
</html>
"@
    return $html
}
Write-Output 'shell helpers appended'
# --- Dashboard (section index) ---
$PaidInvoices = $Invoices | Where-Object { $_.Status -eq 'Paid' }
$DaysPaid = foreach ($inv in $PaidInvoices) { $ps = $PayByInv[$inv.'Invoice ID']; if ($ps) { $lastPay = ($ps | ForEach-Object { [datetime]$_.'Payment Date' } | Measure-Object -Maximum).Maximum; ($lastPay - [datetime]$inv.'Invoice Date').Days } }
$AvgDaysStr = (($DaysPaid | Measure-Object -Average).Average).ToString('F1')
$AvgInvStr = '$' + (($Billed / $Invoices.Count)).ToString('F2')
$ApprOk = ($Bids | Where-Object { $_.Status -eq 'Approved' }).Count
$ApprCut = ($Bids | Where-Object { $_.Status -eq 'Cut' }).Count
$ApprRateStr = ((($ApprOk + $ApprCut) / $Bids.Count) * 100).ToString('F1') + '%'
$PendBids = ($Bids | Where-Object { $_.Status -eq 'Pending' }).Count
$OvInvCount = ($Invoices | Where-Object { $_.Status -eq 'Overdue' }).Count
$PartInvCount = ($Invoices | Where-Object { $_.Status -eq 'Partially Paid' }).Count
$UnpaidInvCount = ($Invoices | Where-Object { $_.Status -eq 'Unpaid' }).Count
$OvStatusStr = Money $OverdueStatusBal; $PartOvStr = Money $PartialOverdueBal
$dash = '<h1>Dashboard</h1>'
$dash += '<p class="lede">The whole operation at a glance. Snapshot as of <strong>2026-11-10</strong> - every number below is computed from the Demo OS snapshot.</p>'
$dash += Note ('<strong>Needs attention:</strong> ' + $PastDue.Count + ' work orders past due (including 1 due today, ' + (H $DueToday[0].'WO Number') + '), ' + $PendBids + ' bids awaiting a decision, ' + $OvInvCount + ' invoices overdue (' + $OvStatusStr + '), ' + $PartInvCount + ' partially paid, ' + $UnpaidInvCount + ' unpaid, ' + $PhotoGate.Count + ' winterizations blocked on a missing pressure-test photo, ' + $BidGaps.Count + ' work orders need a bid, ' + $Problems.Count + ' problems open. See <a href="' + $Base + '/os/deadlines/">Deadlines</a>, <a href="' + $Base + '/os/bids/">Bids</a>, <a href="' + $Base + '/os/invoices/">Invoices</a> and <a href="' + $Base + '/os/problems/">Problems to Solve</a>.') 'bad'
$dash += Tiles -Items @(
    @('Properties', [string]$Props.Count, '92 Active - 12 Inactive - 4 Sold'),
    @('Work orders', [string]$WOs.Count,( $OpenWOs.Count.ToString() + ' open - ' + $PastDue.Count + ' past due')),
    @('Bids', [string]$Bids.Count,( $PendBids.ToString() + ' pending - approval rate ' + $ApprRateStr)),
    @('Invoices', [string]$Invoices.Count,( $OvInvCount.ToString() + ' overdue - ' + $PartInvCount + ' partially paid')),
    @('Billed', $BilledStr,( $Invoices.Count.ToString() + ' invoices')),
    @('Received', $ReceivedStr,( $Payments.Count.ToString() + ' payments')),
    @('Outstanding', $OutstandingStr,( 'overdue ' + $OverdueStr)),
    @('Avg invoice', $AvgInvStr,( 'avg days to pay ' + $AvgDaysStr)),
    @('Crew messages', [string]$Msgs.Count,( $Questions.Count.ToString() + ' questions')),
    @('Problems open', [string]$Problems.Count, '6 of 6 open'),
    @('Photo gate', [string]$PhotoGate.Count, 'winterizations missing pressure-test photo'),
    @('Bid gaps', [string]$BidGaps.Count, 'work orders needing a bid, none submitted')
)
$dash += '<h2>Money</h2>'
$dash += '<p>The money reconciles. Overdue balance is the Dashboard formula: the sum of invoice Balance where the due date is before 2026-11-10 and the balance is greater than zero.</p>'
$dash += KV -Pairs @(
    @('Billed (' + $Invoices.Count + ' invoices)', $BilledStr),
    @('Received (' + $Payments.Count + ' payments)', $ReceivedStr),
    @('Outstanding', $OutstandingStr),
    @('Overdue balance (due before 2026-11-10)', $OverdueStr),
    @('- of which: Overdue status', $OvStatusStr),
    @('- of which: Partially Paid, past due', $PartOvStr),
    @('Not yet due', $NotYetDueStr)
)
Write-Output 'dashboard part 1 appended'
$WoStatusRows = @($WOs | Group-Object Status | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count, ((($_.Count / $WOs.Count) * 100).ToString('F1') + '%')) })
$WoTypeRows = @($WOs | Group-Object 'WO Type' | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count, ((($_.Count / $WOs.Count) * 100).ToString('F1') + '%')) })
$BidStatusRows = @($Bids | Group-Object Status | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count, ((($_.Count / $Bids.Count) * 100).ToString('F1') + '%')) })
$InvStatusRows = @($Invoices | Group-Object Status | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count, ((($_.Count / $Invoices.Count) * 100).ToString('F1') + '%')) })
$MsgTypeRows = @($Msgs | Group-Object Type | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count, ((($_.Count / $Msgs.Count) * 100).ToString('F1') + '%')) })
$PropStateRows = @($Props | Group-Object State | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count) })
$dash += '<h2>Work orders by status</h2>'
$dash += '<p>Open = Assigned, In Progress, or Ready for Office. Past due = open with a due date on or before 2026-11-10.</p>'
$dash += Tbl -Id 'wo-status' -Headers @('Status','#Work orders','#Share') -Rows $WoStatusRows
$dash += '<h2>Work orders by type</h2>'
$dash += Tbl -Id 'wo-type' -Headers @('Type','#Work orders','#Share') -Rows $WoTypeRows
$dash += '<h2>Bids by status</h2>'
$dash += '<p>Approval rate = (Approved + Cut) / all bids = ' + $ApprRateStr + '. ' + $AboveCeil.Count + ' bids are above the client ceiling; the exposure is ' + (Money $AboveCeilExposure) + ' (sum of bid minus ceiling).</p>'
$dash += Tbl -Id 'bid-status' -Headers @('Status','#Bids','#Share') -Rows $BidStatusRows
$dash += '<h2>Invoices by status</h2>'
$dash += Tbl -Id 'inv-status' -Headers @('Status','#Invoices','#Share') -Rows $InvStatusRows
$dash += '<h2>Crew messages by type</h2>'
$dash += '<p>Questions (' + $Questions.Count + ') are the needs-answer proxy - see <a href="' + $Base + '/os/quo/">Quo</a>. The data does not record replies, so no response rate is computed.</p>'
$dash += Tbl -Id 'msg-type' -Headers @('Type','#Messages','#Share') -Rows $MsgTypeRows
$dash += '<h2>Properties by state</h2>'
$dash += Tbl -Id 'prop-state' -Headers @('State','#Properties') -Rows $PropStateRows -NoFilter
$dash += '<h2>Clients</h2>'
$dash += '<p>Income ratio = received / billed. Verdict rule: ratio 0.75 or more = Scale, 0.50-0.75 = Monitor, below 0.50 = Reprice. Approval rate = (Approved + Cut) / all bids for that client.</p>'
$ClientRows = @($ClientTable | ForEach-Object { ,@((H $_.Name), [string]$_.WOs, (Money $_.Billed), (Money $_.Received), (Money $_.Outstanding), (Money $_.OverdueBal), (($_.ApprovalRate).ToString('F1') + '%'), ($_.Ratio).ToString('F2'), (H $_.Verdict)) })
$dash += Tbl -Id 'clients' -Headers @('Client','#Work orders','#Billed','#Received','#Outstanding','#Overdue','#Approval rate','#Income ratio','Verdict') -Rows $ClientRows
$dash += '<h2>Crew - top 5 by closed work orders</h2>'
$CrewRows = @($CrewTable | Select-Object -First 5 | ForEach-Object { ,@((H $_.Name), (H $_.Role), (H $_.Base), [string]$_.Closed, [string]$_.Open, [string]$_.Messages, [string]$_.Questions) })
$dash += Tbl -Id 'crew-top' -Headers @('Crew','Role','Base','#Closed (to 2026-11-10)','#Open','#Messages','#Questions') -Rows $CrewRows -NoFilter
$dash += '<p>Closed counts cover 2026 work orders completed through 2026-11-10. See the full roster on the <a href="' + $Base + '/os/crew/">Crew</a> page.</p>'
$dash += '<h2>Today - 2026-11-10</h2>'
$dash += KV -Pairs @(
    @('Work orders assigned today', [string]$WoToday.Count),
    @('Crew messages today', [string]$MsgsToday.Count),
    @('Open work orders due today', ([string](@($DueToday).Count) + ' - ' + (H $DueToday[0].'WO Number'))),
    @('Open work orders due in the next 48 hours', [string]$Due48.Count),
    @('New properties first seen in 2026', [string]$NewProps26.Count)
)
$dash += '<h2>Snapshot data</h2>'
$dash += '<p>Every figure above comes from the public Demo OS snapshot as of 2026-11-10. Download the tables:</p><ul>'
foreach ($f in @('manifest.json','properties.json','clients.json','crew.json','work_orders.json','bids.json','invoices.json','payments.json','crew_messages.json','problems.json')) { $dash += '<li><a href="' + $Base + '/data/demo-os-2026-11-10/' + $f + '">' + $f + '</a></li>' }
$dash += '</ul>'
$dashHtml = Page -Slug '' -Title 'Dashboard' -Body $dash -Desc 'Property Preservation OS dashboard - fictional demo snapshot as of 2026-11-10: 108 properties, 664 work orders, billed $128,285.'
Write-Page -RelDir '' -FileName 'index.html' -Html $dashHtml
Write-Output 'dashboard written'
# --- Property Master ---
$PropStatusGroups = $Props | Group-Object Status
$NPropActive = ($PropStatusGroups | Where-Object { $_.Name -eq 'Active' }).Count
$NPropInactive = ($PropStatusGroups | Where-Object { $_.Name -eq 'Inactive' }).Count
$NPropSold = ($PropStatusGroups | Where-Object { $_.Name -eq 'Sold' }).Count
$StateSummary = (($PropStateRows | ForEach-Object { "$($_[0]) $($_[1])" }) -join ' - ')
$propRows = @($Props | Sort-Object 'Property ID' | ForEach-Object {
    $propId = $_.'Property ID'
    $detailUrl = $Base + '/os/property-master/' + $propId + '/'
    $stKind = if ($_.Status -eq 'Active') { 'ok' } elseif ($_.Status -eq 'Sold') { 'info' } else { 'warn' }
    ,@(
        (PropLink $propId),
        (H $_.Address),
        (H $_.City),
        (H $_.State),
        (H $_.ZIP),
        (H $_.'Property Type'),
        [string]$_.Bedrooms,
        [string]$_.'Year Built',
        (H $_.'Client Name'),
        (H $_.'First Seen'),
        (Chip $_.Status $stKind)
    )
})
$pm = '<h1>Property Master</h1>'
$pm += '<p class="lede">Every property in the Demo OS. Click a property ID for its full history - work orders, bids, invoices, payments, messages, and replacement chains.</p>'
$pm += Tiles -Items @(
    @('Properties', [string]$Props.Count, $StateSummary),
    @('Active', [string]$NPropActive,( $NPropInactive.ToString() + ' Inactive - ' + $NPropSold + ' Sold')),
    @('New in 2026', [string]$NewProps26.Count, 'first seen in 2026')
)
$pm += Tbl -Id 'properties' -Headers @('Property','Address','City','State','ZIP','Type','#Beds','#Year built','Client','First seen','Status') -Rows $propRows
$pmHtml = Page -Slug 'property-master' -Title 'Property Master' -Body $pm -Desc 'All 108 properties in the Demo OS property preservation snapshot.'
Write-Page -RelDir 'os\property-master' -FileName 'index.html' -Html $pmHtml
Write-Output 'property master written'
# --- property detail pages (108) ---
foreach ($prop in ($Props | Sort-Object 'Property ID')) {
    $propId = $prop.'Property ID'
    $pWos = @($WOsByProp[$propId])
    $pBids = @($Bids | Where-Object { $_.'Property ID' -eq $propId })
    $pInvs = @($Invoices | Where-Object { $_.'Property ID' -eq $propId })
    $pInvIds = @($pInvs.'Invoice ID')
    $pPays = @($Payments | Where-Object { $pInvIds -contains $_.'Invoice ID' })
    $pMsgs = @($MsgByProp[$propId])
    $pClosed = @($pWos | Where-Object { $_.Status -eq 'Closed' }).Count
    $pOpen = @($pWos | Where-Object { $_.Status -in 'Assigned','In Progress','Ready for Office' }).Count
    $pBidSum = ($pBids | Measure-Object 'Bid Amount' -Sum).Sum
    $pApprSum = ($pBids | Measure-Object 'Approved Amount' -Sum).Sum
    $pCeilSum = ($pBids | Measure-Object 'Client Ceiling' -Sum).Sum
    $pInvBilled = ($pInvs | Measure-Object 'Amount' -Sum).Sum
    $pInvRec = ($pInvs | Measure-Object 'Amount Received' -Sum).Sum
    $pInvOut = ($pInvs | Measure-Object 'Balance' -Sum).Sum
    $pPayTotal = ($pPays | Measure-Object 'Amount' -Sum).Sum
    $pChains = @($pWos | Where-Object { $_.'Supersedes WO' -ne '' })
    $d = '<h1>' + (H $propId) + ' - ' + (H $prop.Address) + '</h1>'
    $d += '<p class="lede">' + (H $prop.City) + ', ' + (H $prop.State) + ' ' + (H $prop.ZIP) + ' - ' + (H $prop.'Property Type') + ' - ' + $prop.Bedrooms + ' bedrooms - built ' + $prop.'Year Built' + ' - Client: ' + (H $prop.'Client Name') + '</p>'
    $d += KV -Pairs @(
        @('Property ID', (H $propId)),
        @('Address', (H $prop.Address)),
        @('City, State, ZIP',( (H $prop.City) + ', ' + (H $prop.State) + ' ' + (H $prop.ZIP))),
        @('Property type', (H $prop.'Property Type')),
        @('Bedrooms', [string]$prop.Bedrooms),
        @('Year built', [string]$prop.'Year Built'),
        @('Client',( (H $prop.'Client Name') + ' (' + (H $prop.'Client ID') + ')')),
        @('First seen', (H $prop.'First Seen')),
        @('Status', (Chip $prop.Status $(if ($prop.Status -eq 'Active') { 'ok' } elseif ($prop.Status -eq 'Sold') { 'info' } else { 'warn' }))),
        @('Notes', (H $prop.Notes))
    )
    $d += Tiles -Items @(
        @('Work orders', [string]$pWos.Count,( $pClosed.ToString() + ' closed - ' + $pOpen + ' open')),
        @('Bids', [string]$pBids.Count,( 'bid total ' + (Money $pBidSum))),
        @('Approved', (Money $pApprSum),( 'of ceilings ' + (Money $pCeilSum))),
        @('Invoiced', (Money $pInvBilled),( 'received ' + (Money $pInvRec) + ' - outstanding ' + (Money $pInvOut))),
        @('Payments', (Money $pPayTotal),( $pPays.Count.ToString() + ' payments')),
        @('Crew messages', [string]$pMsgs.Count, 'for this property')
    )
    $d += '<h2>Work orders (' + $pWos.Count + ')</h2>'
    if ($pWos.Count) {
        $woRows = @($pWos | Sort-Object 'Date Assigned' | ForEach-Object {
            $w = $_
            ,@(
                (WoLink $w.'WO Number'),
                (H $w.'WO Type'),
                (Chip $w.Status $(if ($w.Status -eq 'Closed') { 'ok' } elseif ($w.Status -eq 'Cancelled') { 'info' } else { 'warn' })),
                (H $w.'Date Assigned'),
                (H $w.'Due Date'),
                (H $w.'Date Completed'),
                (H $w.'Crew Name'),
                [string]$w.'Photos Before',
                [string]$w.'Photos During',
                [string]$w.'Photos After',
                (H $w.'Pressure Test Photo')
            )
        })
        $d += Tbl -Id ('wo-' + $propId) -Headers @('Work order','Type','Status','Assigned','Due','Completed','Crew','#Photos before','#Photos during','#Photos after','Pressure-test photo') -Rows $woRows
    } else { $d += '<p class="muted">No work orders for this property.</p>' }
    $d += '<h2>Bids (' + $pBids.Count + ')</h2>'
    if ($pBids.Count) {
        $bidRows = @($pBids | Sort-Object 'Date Submitted' | ForEach-Object {
            $b = $_
            ,@(
                (H $b.'Bid ID'),
                (WoLink $b.'WO Number'),
                (H $b.'Item / Scope'),
                (Money $b.'Bid Amount'),
                (Money $b.'Client Ceiling'),
                (Money $b.'Approved Amount'),
                (Chip $b.Status $(if ($b.Status -eq 'Approved') { 'ok' } elseif ($b.Status -eq 'Pending') { 'warn' } else { 'info' })),
                (H $b.'Date Submitted'),
                (H $b.'Date Decided')
            )
        })
        $d += Tbl -Id ('bids-' + $propId) -Headers @('Bid','Work order','Scope','#Bid','#Ceiling','#Approved','Status','Submitted','Decided') -Rows $bidRows
    } else { $d += '<p class="muted">No bids for this property.</p>' }
    $d += '<h2>Invoices (' + $pInvs.Count + ')</h2>'
    if ($pInvs.Count) {
        $invRows = @($pInvs | Sort-Object 'Invoice Date' | ForEach-Object {
            $iv = $_
            ,@(
                (H $iv.'Invoice ID'),
                (WoLink $iv.'WO Number'),
                (H $iv.'Invoice Date'),
                (Money $iv.Amount),
                (H $iv.'Due Date'),
                (Money $iv.'Amount Received'),
                (Money $iv.Balance),
                (Chip $iv.Status $(if ($iv.Status -eq 'Paid') { 'ok' } elseif ($iv.Status -eq 'Overdue') { 'bad' } elseif ($iv.Status -eq 'Partially Paid') { 'warn' } else { 'info' }))
            )
        })
        $d += Tbl -Id ('inv-' + $propId) -Headers @('Invoice','Work order','Date','#Amount','Due','#Received','#Balance','Status') -Rows $invRows
    } else { $d += '<p class="muted">No invoices for this property.</p>' }
    if ($pChains.Count) {
        $d += '<h2>Replacement chains</h2><ul>'
        foreach ($cw in $pChains) { $d += '<li>' + (H $cw.'WO Number') + ' supersedes ' + (H $cw.'Supersedes WO') + '.</li>' }
        $d += '</ul>'
    }
    $d += '<h2>Crew messages (' + $pMsgs.Count + ')</h2>'
    if ($pMsgs.Count) {
        $mRows = @($pMsgs | Sort-Object Date, Time -Descending | Select-Object -First 10 | ForEach-Object { ,@((H $_.Date), (H $_.Time), (H $_.'Crew Name'), (H $_.Type), (H $_.Message)) })
        $d += Tbl -Id ('msg-' + $propId) -Headers @('Date','Time','Crew','Type','Message') -Rows $mRows
        if ($pMsgs.Count -gt 10) { $d += '<p class="small muted">Showing the latest 10 of ' + $pMsgs.Count + ' messages. See all messages on the <a href="' + $Base + '/os/quo/">Quo</a> page.</p>' }
    } else { $d += '<p class="muted">No crew messages for this property.</p>' }
    $dHtml = Page -Slug ('property-master/' + $propId) -Title ($propId + ' - ' + $prop.Address) -Body $d -Desc ('Property ' + $propId + ' - ' + $prop.Address + ' - work orders, bids, invoices, payments and messages.')
    Write-Page -RelDir ('os\property-master\' + $propId) -FileName 'index.html' -Html $dHtml
}
Write-Output 'property detail pages written'
# --- Intake ---
$in = '<h1>Intake</h1>'
$in += '<p class="lede">Everything that arrived, in the order it arrived. Snapshot as of <strong>2026-11-10</strong>.</p>'
$in += Tiles -Items @(
    @('Assigned today (2026-11-10)', [string]$WoToday.Count, 'work orders'),
    @('Messages today', [string]$MsgsToday.Count, 'crew messages'),
    @('New properties in 2026', [string]$NewProps26.Count, 'first seen in 2026'),
    @('Open work orders', [string]$OpenWOs.Count,( $PastDue.Count.ToString() + ' past due'))
)
$in += '<h2>New work orders - latest 30 by date assigned</h2>'
$nwRows = @($WOs | Sort-Object 'Date Assigned', 'WO Number' -Descending | Select-Object -First 30 | ForEach-Object {
    $w = $_
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property Address'),
        (H $w.'WO Type'),
        (H $w.'Client Name'),
        (H $w.'Crew Name'),
        (H $w.'Date Assigned'),
        (H $w.'Due Date'),
        (Chip $w.Status $(if ($w.Status -eq 'Closed') { 'ok' } elseif ($w.Status -eq 'Cancelled') { 'info' } else { 'warn' }))
    )
})
$in += Tbl -Id 'intake-wo' -Headers @('Work order','Property','Type','Client','Crew','Assigned','Due','Status') -Rows $nwRows
$in += '<h2>New properties in 2026</h2>'
$npRows = @($NewProps26 | Sort-Object 'First Seen' -Descending | ForEach-Object {
    $p = $_
    ,@(
        (PropLink $p.'Property ID'),
        (H $p.Address),
        (H $p.City),
        (H $p.State),
        (H $p.'Client Name'),
        (H $p.'First Seen')
    )
})
$in += Tbl -Id 'intake-props' -Headers @('Property','Address','City','State','Client','First seen') -Rows $npRows
$in += '<h2>Latest crew messages</h2>'
$lmRows = @($Msgs | Sort-Object Date, Time -Descending | Select-Object -First 20 | ForEach-Object {
    $m = $_
    $lk = '<a href="' + $Base + '/os/work-orders/detail/?wo=' + $m.'WO Number' + '">' + (H $m.'WO Number') + '</a>'
    ,@(
        (H $m.Date),
        (H $m.Time),
        $lk,
        (H $m.'Crew Name'),
        (H $m.Type),
        (H $m.Message)
    )
})
$in += Tbl -Id 'intake-msgs' -Headers @('Date','Time','Work order','Crew','Type','Message') -Rows $lmRows
$in += '<h2>Due in the next 14 days</h2>'
$calEnd = $AsOf.AddDays(14)
$calRows = @($OpenWOs | Where-Object { [datetime]$_.'Due Date' -ge $AsOf -and [datetime]$_.'Due Date' -le $calEnd } | Sort-Object 'Due Date' | ForEach-Object {
    $w = $_
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property Address'),
        (H $w.'WO Type'),
        (H $w.'Due Date'),
        (Chip $w.Status 'warn'),
        (H $w.'Crew Name')
    )
})
$in += Tbl -Id 'intake-cal' -Headers @('Work order','Property','Type','Due','Status','Crew') -Rows $calRows
$in += '<h2>Work orders assigned per day - last 14 days</h2>'
$byDayRows = @($WOs | Group-Object 'Date Assigned' | Sort-Object Name -Descending | Select-Object -First 14 | ForEach-Object { ,@($_.Name, [string]$_.Count) })
$in += Tbl -Id 'intake-byday' -Headers @('Date','#Assigned') -Rows $byDayRows
$inHtml = Page -Slug 'intake' -Title 'Intake' -Body $in -Desc 'Intake feed - new work orders, new properties, latest crew messages and the due-date calendar.'
Write-Page -RelDir 'os\intake' -FileName 'index.html' -Html $inHtml
Write-Output 'intake written'
# --- Live Ops ---
$nAssigned = ($OpenWOs | Where-Object { $_.Status -eq 'Assigned' }).Count
$nInProg = ($OpenWOs | Where-Object { $_.Status -eq 'In Progress' }).Count
$nRfo = ($OpenWOs | Where-Object { $_.Status -eq 'Ready for Office' }).Count
$nClosed = ($WOs | Where-Object { $_.Status -eq 'Closed' }).Count
$nCanc = ($WOs | Where-Object { $_.Status -eq 'Cancelled' }).Count
$lo = '<h1>Live Ops</h1>'
$lo += '<p class="lede">What is in the field right now. Snapshot as of <strong>2026-11-10</strong>.</p>'
$lo += Tiles -Items @(
    @('Open', [string]$OpenWOs.Count,( $nAssigned.ToString() + ' Assigned - ' + $nInProg + ' In Progress - ' + $nRfo + ' Ready for Office')),
    @('Past due', [string]$PastDue.Count, 'open, due on or before 2026-11-10'),
    @('Closed', [string]$nClosed, 'work orders completed'),
    @('Cancelled', [string]$nCanc, 'work orders cancelled')
)
$lo += '<h2>Open work orders by status</h2>'
$opStatusRows = @($OpenWOs | Group-Object Status | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count) })
$lo += Tbl -Id 'lo-status' -Headers @('Status','#Open') -Rows $opStatusRows
$lo += '<h2>Open work orders by type</h2>'
$opTypeRows = @($OpenWOs | Group-Object 'WO Type' | Sort-Object Count -Descending | ForEach-Object { ,@($_.Name, [string]$_.Count) })
$lo += Tbl -Id 'lo-type' -Headers @('Type','#Open') -Rows $opTypeRows
$lo += '<h2>Load per crew</h2>'
$loadRows = @($CrewTable | Sort-Object Open -Descending | ForEach-Object {
    $c = $_
    $cPast = @($PastDue | Where-Object { $_.'Crew ID' -eq $c.Id }).Count
    ,@((H $c.Name), (H $c.Role), (H $c.Base), [string]$c.Open, [string]$cPast, [string]$c.Closed, [string]$c.Messages)
})
$lo += Tbl -Id 'lo-load' -Headers @('Crew','Role','Base','#Open','#Past due','#Closed (2026)','#Messages') -Rows $loadRows
$lo += '<h2>Longest-open work orders</h2>'
$longRows = @($OpenWOs | ForEach-Object { $w = $_; $days = ($AsOf - [datetime]$w.'Date Assigned').Days; [pscustomobject]@{ Wo=$w; Days=$days } } | Sort-Object Days -Descending | Select-Object -First 20 | ForEach-Object {
    $w = $_.Wo
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property Address'),
        (H $w.'WO Type'),
        (Chip $w.Status 'warn'),
        (H $w.'Date Assigned'),
        (H $w.'Due Date'),
        [string]$_.Days,
        (H $w.'Crew Name')
    )
})
$lo += Tbl -Id 'lo-long' -Headers @('Work order','Property','Type','Status','Assigned','Due','#Days open','Crew') -Rows $longRows
$loHtml = Page -Slug 'live-ops' -Title 'Live Ops' -Body $lo -Desc 'Live Ops - open work orders, load per crew, and the longest-open jobs.'
Write-Page -RelDir 'os\live-ops' -FileName 'index.html' -Html $loHtml
Write-Output 'live ops written'
# --- Deadlines ---
$de = '<h1>Deadlines</h1>'
$de += '<p class="lede">Every date the operation has to hit. Snapshot as of <strong>2026-11-10</strong>.</p>'
$de += Tiles -Items @(
    @('Past due', [string]$PastDue.Count, 'open work orders, due on or before 2026-11-10'),
    @('Due today', [string]$DueToday.Count,( $DueToday[0].'WO Number' + ' - ' + $DueToday[0].'WO Type')),
    @('Due in the next 48 hours', [string]$Due48.Count, '2026-11-11 to 2026-11-12'),
    @('Due in the next 7 days', [string]$Due7.Count, '2026-11-10 to 2026-11-17')
)
$de += Note '<strong>Escalation rule (stated operating rule).</strong> 48 hours before due: first reminder. 24 hours before due: dispatch check. 4 hours before due: escalate to the team lead. The snapshot records work orders and due dates; it does not record which reminders were sent.'
$de += '<h2>Past due - oldest first</h2>'
$pdRows = @($PastDue | Sort-Object 'Due Date' | ForEach-Object {
    $w = $_
    $daysOver = ($AsOf - [datetime]$w.'Due Date').Days
    $wInvs = @($InvByWo[$w.'WO Number'])
    $hasOv = @($wInvs | Where-Object { $_.Status -eq 'Overdue' }).Count
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property Address'),
        (H $w.'WO Type'),
        (Chip $w.Status 'warn'),
        (H $w.'Due Date'),
        [string]$daysOver,
        (H $w.'Crew Name'),
        $(if ($hasOv -gt 0) { 'Yes' } else { 'No' })
    )
})
$de += Tbl -Id 'de-pastdue' -Headers @('Work order','Property','Type','Status','Due','#Days past due','Crew','Has overdue invoice') -Rows $pdRows
$de += '<h2>Due today and in the next 48 hours</h2>'
$due48Rows = @($OpenWOs | Where-Object { [datetime]$_.'Due Date' -ge $AsOf -and [datetime]$_.'Due Date' -le ($AsOf.AddDays(2)) } | Sort-Object 'Due Date' | ForEach-Object {
    $w = $_
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property Address'),
        (H $w.'WO Type'),
        (Chip $w.Status 'warn'),
        (H $w.'Due Date'),
        (H $w.'Crew Name')
    )
})
$de += Tbl -Id 'de-next' -Headers @('Work order','Property','Type','Status','Due','Crew') -Rows $due48Rows
$de += '<h2>Payment risk - past-due work orders with an overdue invoice</h2>'
$riskRows = @()
foreach ($w in $PastDue) {
    foreach ($iv in @($InvByWo[$w.'WO Number'])) {
        if ($iv.Status -eq 'Overdue') {
            $riskRows += ,@(
                (WoLink $w.'WO Number'),
                (H $iv.'Invoice ID'),
                (H $iv.'Client ID'),
                (Money $iv.Amount),
                (Money $iv.Balance),
                (H $iv.'Due Date')
            )
        }
    }
}
$de += Tbl -Id 'de-risk' -Headers @('Work order','Invoice','Client','#Invoice amount','#Balance','Invoice due') -Rows $riskRows
$deHtml = Page -Slug 'deadlines' -Title 'Deadlines' -Body $de -Desc 'Deadlines - 130 past-due work orders, due today, the next 48 hours, and payment risk.'
Write-Page -RelDir 'os\deadlines' -FileName 'index.html' -Html $deHtml
Write-Output 'deadlines written'
# --- Work Orders ---
$wo = '<h1>Work Orders</h1>'
$wo += '<p class="lede">Every job the Demo OS has ever tracked. Snapshot as of <strong>2026-11-10</strong>.</p>'
$wo += Tiles -Items @(
    @('Work orders', [string]$WOs.Count,( $OpenWOs.Count.ToString() + ' open - ' + $nClosed + ' closed - ' + $nCanc + ' cancelled')),
    @('Past due', [string]$PastDue.Count, 'open, due on or before 2026-11-10'),
    @('Bid gaps', [string]$BidGaps.Count, 'need a bid, none submitted'),
    @('Replacement chains', [string]$Chains.Count, 'follow-up work orders supersede earlier ones')
)
$wo += '<p>Click a work order number for its full detail - bids, invoices, payments, and crew messages. Six work orders supersede earlier ones:</p><ul>'
foreach ($ch in $Chains) { $wo += '<li>' + (H $ch.Child) + ' supersedes ' + (H $ch.Parent) + '.</li>' }
$wo += '</ul>'
$woAllRows = @($WOs | Sort-Object 'Date Assigned' -Descending | ForEach-Object {
    $w = $_
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property Address'),
        (H $w.'WO Type'),
        (H $w.'Client Name'),
        (H $w.'Crew Name'),
        (H $w.'Date Assigned'),
        (H $w.'Due Date'),
        (H $w.'Date Completed'),
        (Chip $w.Status $(if ($w.Status -eq 'Closed') { 'ok' } elseif ($w.Status -eq 'Cancelled') { 'info' } elseif ($w.Status -eq 'Ready for Office') { 'info' } else { 'warn' }))
    )
})
$wo += Tbl -Id 'wo-all' -Headers @('Work order','Property','Type','Client','Crew','Assigned','Due','Completed','Status') -Rows $woAllRows
$woHtml = Page -Slug 'work-orders' -Title 'Work Orders' -Body $wo -Desc 'All 664 work orders in the Demo OS property preservation snapshot.'
Write-Page -RelDir 'os\work-orders' -FileName 'index.html' -Html $woHtml
$det = '<h1>Work order</h1>'
$det += '<p class="lede">Full detail for one work order - joined from the snapshot tables: bids, invoices, payments, and crew messages.</p>'
$det += '<div id="wo-detail"><p class="muted">Loading work order-</p></div>'
$det += Note 'This page reads the snapshot JSON files and joins the tables in the browser. Open it with a work-order number, for example <a href="?wo=DEMO-WO-2001">?wo=DEMO-WO-2001</a>.'
$detHtml = Page -Slug 'work-orders/detail' -Title 'Work order detail' -Body $det -Desc 'Work order detail - bids, invoices, payments and crew messages for one work order.'
Write-Page -RelDir 'os\work-orders\detail' -FileName 'index.html' -Html $detHtml
Write-Output 'work orders written'
# --- Bids ---
$CutSum = ($Bids | Where-Object { $_.Status -eq 'Cut' } | ForEach-Object { [decimal]$_.'Bid Amount' - [decimal]$_.'Approved Amount' } | Measure-Object -Sum).Sum
$bi = '<h1>Bids</h1>'
$bi += '<p class="lede">Every bid submitted, and what happened to it. Snapshot as of <strong>2026-11-10</strong>.</p>'
$bi += Tiles -Items @(
    @('Bids', [string]$Bids.Count, 'submitted in total'),
    @('Approved', [string]$ApprOk,( 'approval rate ' + $ApprRateStr + ' (Approved + Cut / all bids)')),
    @('Pending', [string]$PendBids, 'awaiting a decision'),
    @('Cut', [string]$ApprCut,( 'cut at approval, ' + (Money $CutSum) + ' cut in total')),
    @('Above ceiling', [string]$AboveCeil.Count,( 'exposure ' + (Money $AboveCeilExposure))),
    @('Bid gaps', [string]$BidGaps.Count, 'work orders needing a bid, none submitted')
)
$bi += Note '<strong>Instant-approval rule (stated rule).</strong> A bid is instant-approval eligible when its bid amount is at or below the client ceiling. The snapshot records bid amounts and ceilings; it does not record an approval flag. The -Instant-approval- column on this page applies that rule.'
$bidRows = @($Bids | Sort-Object 'Date Submitted' -Descending | ForEach-Object {
    $b = $_
    $elig = if ([decimal]$b.'Bid Amount' -le [decimal]$b.'Client Ceiling') { 'Yes' } else { 'No' }
    ,@(
        (H $b.'Bid ID'),
        (WoLink $b.'WO Number'),
        (H $b.'Property ID'),
        (H $b.'Client ID'),
        (H $b.'Item / Scope'),
        (Money $b.'Bid Amount'),
        (Money $b.'Client Ceiling'),
        (Money $b.'Approved Amount'),
        (Chip $b.Status $(if ($b.Status -eq 'Approved') { 'ok' } elseif ($b.Status -eq 'Pending') { 'warn' } else { 'info' })),
        (H $b.'Date Submitted'),
        (H $b.'Date Decided'),
        $elig
    )
})
$bi += Tbl -Id 'bids-all' -Headers @('Bid','Work order','Property','Client','Scope','#Bid','#Ceiling','#Approved','Status','Submitted','Decided','Instant-approval') -Rows $bidRows
$bi += '<h2>Bids above the client ceiling</h2>'
$acRows = @($AboveCeil | Sort-Object { [decimal]$_.'Bid Amount' - [decimal]$_.'Client Ceiling' } -Descending | ForEach-Object {
    $b = $_
    $over = [decimal]$b.'Bid Amount' - [decimal]$b.'Client Ceiling'
    ,@(
        (H $b.'Bid ID'),
        (WoLink $b.'WO Number'),
        (H $b.'Property ID'),
        (Money $b.'Bid Amount'),
        (Money $b.'Client Ceiling'),
        (Money $over),
        (Chip $b.Status $(if ($b.Status -eq 'Pending') { 'warn' } else { 'info' }))
    )
})
$bi += Tbl -Id 'bids-ceiling' -Headers @('Bid','Work order','Property','#Bid','#Ceiling','#Over ceiling','Status') -Rows $acRows
$bi += '<h2>Bid gaps - work orders that need a bid, have none</h2>'
$bgRows = @($BidGaps | Sort-Object 'Due Date' | ForEach-Object {
    $w = $_
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property ID'),
        (H $w.'WO Type'),
        (H $w.'Client Name'),
        (H $w.'Date Assigned'),
        (H $w.'Due Date'),
        (Chip $w.Status 'warn')
    )
})
$bi += Tbl -Id 'bids-gaps' -Headers @('Work order','Property','Type','Client','Assigned','Due','Status') -Rows $bgRows
$biHtml = Page -Slug 'bids' -Title 'Bids' -Body $bi -Desc 'All 487 bids in the Demo OS property preservation snapshot.'
Write-Page -RelDir 'os\bids' -FileName 'index.html' -Html $biHtml
Write-Output 'bids written'
# --- Invoices ---
$agN0=0;$agA0=[decimal]0;$agN30=0;$agA30=[decimal]0;$agN60=0;$agA60=[decimal]0;$agN90=0;$agA90=[decimal]0;$agN91=0;$agA91=[decimal]0
foreach ($iv in ($Invoices | Where-Object { [decimal]$_.Balance -gt 0 })) {
    $ddays = ($AsOf - [datetime]$iv.'Due Date').Days
    if ($ddays -le 0) { $agN0++; $agA0 += [decimal]$iv.Balance } elseif ($ddays -le 30) { $agN30++; $agA30 += [decimal]$iv.Balance } elseif ($ddays -le 60) { $agN60++; $agA60 += [decimal]$iv.Balance } elseif ($ddays -le 90) { $agN90++; $agA90 += [decimal]$iv.Balance } else { $agN91++; $agA91 += [decimal]$iv.Balance }
}
$iv = '<h1>Invoices</h1>'
$iv += '<p class="lede">Every invoice, what came in against it, and what is still owed. Snapshot as of <strong>2026-11-10</strong>.</p>'
$iv += Tiles -Items @(
    @('Invoices', [string]$Invoices.Count,( 'avg invoice ' + $AvgInvStr)),
    @('Billed', $BilledStr, 'in total'),
    @('Received', $ReceivedStr, 'against invoices'),
    @('Outstanding', $OutstandingStr,( 'overdue ' + $OverdueStr)),
    @('Paid', [string]$PaidInvoices.Count, 'invoices fully paid'),
    @('Overdue', [string]$OvInvCount,( $OvStatusStr + ' outstanding')),
    @('Partially paid', [string]$PartInvCount, 'some money in, balance owed'),
    @('Unpaid', [string]$UnpaidInvCount, 'nothing received')
)
$iv += Note 'Amount Received and Balance for every invoice are recomputed from the payments table, so the totals tie exactly to the <a href="' + $Base + '/os/payments/">Payments</a> page. Overdue balance is the Dashboard formula: sum of Balance where the due date is before 2026-11-10 and the balance is greater than zero.'
$iv += '<h2>Ageing of outstanding balances</h2>'
$ageRows = @(
    @('Not yet due', [string]$agN0, (Money $agA0)),
    @('1-30 days past due', [string]$agN30, (Money $agA30)),
    @('31-60 days past due', [string]$agN60, (Money $agA60)),
    @('61-90 days past due', [string]$agN90, (Money $agA90)),
    @('Over 90 days past due', [string]$agN91, (Money $agA91))
)
$iv += Tbl -Id 'inv-age' -Headers @('Ageing band','#Invoices','#Balance') -Rows $ageRows -NoFilter
$iv += '<h2>Ageing by client</h2>'
$ageClients = @()
foreach ($c in $Clients) {
    $cInvs = @($Invoices | Where-Object { $_.'Client ID' -eq $c.'Client ID' -and [decimal]$_.Balance -gt 0 })
    $bNot=0;$b30=0;$b60=0;$b90=0;$b91=0
    foreach ($ivv in $cInvs) {
        $dd2 = ($AsOf - [datetime]$ivv.'Due Date').Days
        if ($dd2 -le 0) { $bNot += [decimal]$ivv.Balance } elseif ($dd2 -le 30) { $b30 += [decimal]$ivv.Balance } elseif ($dd2 -le 60) { $b60 += [decimal]$ivv.Balance } elseif ($dd2 -le 90) { $b90 += [decimal]$ivv.Balance } else { $b91 += [decimal]$ivv.Balance }
    }
    $ageClients += ,@((H $c.'Client Name'), (Money $bNot), (Money $b30), (Money $b60), (Money $b90), (Money $b91))
}
$iv += Tbl -Id 'inv-age-client' -Headers @('Client','#Not yet due','#1-30 days','#31-60 days','#61-90 days','#Over 90 days') -Rows $ageClients -NoFilter
$iv += '<h2>All invoices</h2>'
$invRows = @($Invoices | Sort-Object 'Invoice Date' -Descending | ForEach-Object {
    $i2 = $_
    ,@(
        (H $i2.'Invoice ID'),
        (WoLink $i2.'WO Number'),
        (H $i2.'Bid ID'),
        (H $i2.'Property ID'),
        (H $i2.'Client ID'),
        (H $i2.'Invoice Date'),
        (Money $i2.Amount),
        (H $i2.'Due Date'),
        (Money $i2.'Amount Received'),
        (Money $i2.Balance),
        (Chip $i2.Status $(if ($i2.Status -eq 'Paid') { 'ok' } elseif ($i2.Status -eq 'Overdue') { 'bad' } elseif ($i2.Status -eq 'Partially Paid') { 'warn' } else { 'info' }))
    )
})
$iv += Tbl -Id 'inv-all' -Headers @('Invoice','Work order','Bid','Property','Client','Invoice date','#Amount','Due','#Received','#Balance','Status') -Rows $invRows
$ivHtml = Page -Slug 'invoices' -Title 'Invoices' -Body $iv -Desc 'All 297 invoices in the Demo OS property preservation snapshot, with ageing.'
Write-Page -RelDir 'os\invoices' -FileName 'index.html' -Html $ivHtml
Write-Output 'invoices written'
# --- Payments ---
$DaysPaid26 = foreach ($inv2 in ($PaidInvoices | Where-Object { [datetime]$_.'Invoice Date' -ge [datetime]'2026-01-01' })) { $ps2 = $PayByInv[$inv2.'Invoice ID']; if ($ps2) { $lp = ($ps2 | ForEach-Object { [datetime]$_.'Payment Date' } | Measure-Object -Maximum).Maximum; ($lp - [datetime]$inv2.'Invoice Date').Days } }
$AvgDays26Str = (($DaysPaid26 | Measure-Object -Average).Average).ToString('F1')
$pa = '<h1>Payments</h1>'
$pa += '<p class="lede">Every payment received. Snapshot as of <strong>2026-11-10</strong>.</p>'
$pa += Tiles -Items @(
    @('Payments', [string]$Payments.Count, 'received in total'),
    @('Received', $ReceivedStr, 'equals the payments total'),
    @('Avg invoice', $AvgInvStr, 'for this snapshot'),
    @('Avg days to pay', $AvgDaysStr, 'all fully-paid invoices'),
    @('Avg days to pay (2026)', $AvgDays26Str, 'fully-paid invoices dated in 2026')
)
$pa += Note 'Payments are recorded gross = net. No fees are recorded in the snapshot, and no fee is shown or assumed here.'
$pa += '<h2>Payments by method</h2>'
$payMethodRows = @($Payments | Group-Object Method | Sort-Object Count -Descending | ForEach-Object { $amt = ($_.Group | Measure-Object Amount -Sum).Sum; ,@($_.Name, [string]$_.Count, (Money $amt)) })
$pa += Tbl -Id 'pay-method' -Headers @('Method','#Payments','#Amount') -Rows $payMethodRows -NoFilter
$pa += '<h2>Payments by client</h2>'
$payClientRows = @($Payments | Group-Object 'Client ID' | Sort-Object { ($_.Group | Measure-Object Amount -Sum).Sum } -Descending | ForEach-Object { $cid = $_.Name; $amt = ($_.Group | Measure-Object Amount -Sum).Sum; ,@((H $ClientById[$cid].'Client Name'), [string]$_.Count, (Money $amt)) })
$pa += Tbl -Id 'pay-client' -Headers @('Client','#Payments','#Amount') -Rows $payClientRows -NoFilter
$pa += '<h2>All payments</h2>'
$payRows = @($Payments | Sort-Object 'Payment Date' -Descending | ForEach-Object {
    $p = $_
    ,@(
        (H $p.'Payment ID'),
        (H $p.'Invoice ID'),
        (WoLink $p.'WO Number'),
        (H $p.'Client ID'),
        (H $p.'Payment Date'),
        (Money $p.Amount),
        (H $p.Method),
        (H $p.Reference),
        (H $p.Status)
    )
})
$pa += Tbl -Id 'pay-all' -Headers @('Payment','Invoice','Work order','Client','Payment date','#Amount','Method','Reference','Status') -Rows $payRows
$paHtml = Page -Slug 'payments' -Title 'Payments' -Body $pa -Desc 'All 379 payments in the Demo OS property preservation snapshot.'
Write-Page -RelDir 'os\payments' -FileName 'index.html' -Html $paHtml
Write-Output 'payments written'
# --- Photo QC ---
$pq = '<h1>Photo QC</h1>'
$pq += '<p class="lede">Photo evidence per job, counted. Snapshot as of <strong>2026-11-10</strong>.</p>'
$pq += Tiles -Items @(
    @('Photos before', [string]$TotalPhotosBefore, 'in total across all work orders'),
    @('Photos during', [string]$TotalPhotosDuring, 'in total'),
    @('Photos after', [string]$TotalPhotosAfter, 'in total'),
    @('Missing a before photo', [string]$ZeroBefore.Count, 'work orders with 0 before photos'),
    @('Missing a during photo', [string]$ZeroDuring.Count, 'work orders with 0 during photos'),
    @('Missing an after photo', [string]$ZeroAfter.Count, 'work orders with 0 after photos'),
    @('Photo gate', [string]$PhotoGate.Count, 'winterizations missing a pressure-test photo')
)
$pq += Note 'The snapshot records photo <strong>counts</strong> per work order (before / during / after) - not the photos themselves. No photograph is stored or shown anywhere in this app.'
$pq += '<h2>Photo gate - winterizations missing a pressure-test photo</h2>'
$gateRows = @($PhotoGate | Sort-Object 'Due Date' | ForEach-Object {
    $w = $_
    $ginv = @($InvByWo[$w.'WO Number'])
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property ID'),
        (H $w.'Client Name'),
        (H $w.'Crew Name'),
        (H $w.'Date Assigned'),
        (H $w.'Due Date'),
        (Chip $w.Status $(if ($w.Status -eq 'Closed') { 'ok' } else { 'warn' })),
        $(if ($ginv.Count) { (H $ginv[0].'Invoice ID') } else { 'None yet' })
    )
})
$pq += Tbl -Id 'pq-gate' -Headers @('Work order','Property','Client','Crew','Assigned','Due','Status','Invoice') -Rows $gateRows
$pq += '<h2>Work orders with a missing photo phase</h2>'
$anyZeroList = @($WOs | Where-Object { [int]$_.'Photos Before' -eq 0 -or [int]$_.'Photos During' -eq 0 -or [int]$_.'Photos After' -eq 0 })
$anyZeroRows = @($anyZeroList | Sort-Object 'Date Assigned' -Descending | ForEach-Object {
    $w = $_
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property ID'),
        (H $w.'WO Type'),
        (H $w.'Client Name'),
        (H $w.'Crew Name'),
        (Chip $w.Status $(if ($w.Status -eq 'Closed') { 'ok' } elseif ($w.Status -eq 'Cancelled') { 'info' } else { 'warn' })),
        [string]$w.'Photos Before',
        [string]$w.'Photos During',
        [string]$w.'Photos After'
    )
})
$pq += Tbl -Id 'pq-zero' -Headers @('Work order','Property','Type','Client','Crew','Status','#Before','#During','#After') -Rows $anyZeroRows
$pq += '<h2>Photos per work order - all work orders</h2>'
$pqRows = @($WOs | Sort-Object 'Date Assigned' -Descending | ForEach-Object {
    $w = $_
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property ID'),
        (H $w.'WO Type'),
        (H $w.'Date Completed'),
        [string]$w.'Photos Before',
        [string]$w.'Photos During',
        [string]$w.'Photos After',
        (H $w.'Pressure Test Photo')
    )
})
$pq += Tbl -Id 'pq-all' -Headers @('Work order','Property','Type','Completed','#Before','#During','#After','Pressure-test photo') -Rows $pqRows
$pqHtml = Page -Slug 'photo-qc' -Title 'Photo QC' -Body $pq -Desc 'Photo QC - photo counts per work order and the winterization photo gate.'
Write-Page -RelDir 'os\photo-qc' -FileName 'index.html' -Html $pqHtml
Write-Output 'photo qc written'
# --- Visual Twin ---
$topPropGroup = $WOs | Group-Object 'Property ID' | Sort-Object Count -Descending | Select-Object -First 1
$topPid = $topPropGroup.Name
$topProp = $PropById[$topPid]
$topVisits = @($WOs | Where-Object { $_.'Property ID' -eq $topPid } | Sort-Object 'Date Completed','Date Assigned')
$vt = '<h1>Visual Twin</h1>'
$vt += '<p class="lede">A counts-only record of what was photographed on each visit. Snapshot as of <strong>2026-11-10</strong>.</p>'
$vt += Note 'The Visual Twin shows <strong>counts only</strong> - how many before, during, and after photos each visit produced. The snapshot does not contain photographs, and it does not record photos per room or area, so no room-by-room view is drawn and no photograph is shown.'
$vt += Tiles -Items @(
    @('Visits recorded', [string]$WOs.Count, 'one work order = one visit'),
    @('Photos before', [string]$TotalPhotosBefore, 'in total'),
    @('Photos during', [string]$TotalPhotosDuring, 'in total'),
    @('Photos after', [string]$TotalPhotosAfter, 'in total')
)
$vt += '<h2>Compare two visits - ' + (H $topPid) + ' (' + (H $topProp.Address) + ')</h2>'
$vt += '<p>This property has the most visits (' + $topVisits.Count + '). Choose two visits to compare their photo counts.</p>'
$vt += '<div class="filterbar"><label class="small muted" for="twin-a">Visit A</label><select id="twin-a">'
foreach ($v in $topVisits) { $vt += '<option value="' + $v.'WO Number' + '">' + (H ($v.'WO Number' + ' - ' + $v.'WO Type' + ' - ' + $v.'Date Assigned')) + '</option>' }
$vt += '</select><label class="small muted" for="twin-b">Visit B</label><select id="twin-b">'
foreach ($v in $topVisits) { $vt += '<option value="' + $v.'WO Number' + '">' + (H ($v.'WO Number' + ' - ' + $v.'WO Type' + ' - ' + $v.'Date Assigned')) + '</option>' }
$vt += '</select></div>'
$vt += '<p><strong>Visit A:</strong> <span id="twin-a-label"></span><br><strong>Visit B:</strong> <span id="twin-b-label"></span></p>'
$vt += '<table class="os-table"><thead><tr><th>Visit</th><th>Type</th><th>Assigned</th><th>Completed</th><th class="num">Before</th><th class="num">During</th><th class="num">After</th><th>Pressure-test photo</th></tr></thead><tbody>'
foreach ($v in $topVisits) {
    $vt += '<tr data-visit="' + $v.'WO Number' + '"><td><a href="' + $Base + '/os/work-orders/detail/?wo=' + $v.'WO Number' + '">' + (H $v.'WO Number') + '</a></td><td>' + (H $v.'WO Type') + '</td><td>' + (H $v.'Date Assigned') + '</td><td>' + (H $v.'Date Completed') + '</td><td class="num">' + $v.'Photos Before' + '</td><td class="num">' + $v.'Photos During' + '</td><td class="num">' + $v.'Photos After' + '</td><td>' + (H $v.'Pressure Test Photo') + '</td></tr>'
}
$vt += '</tbody></table>'
$vt += '<h2>All visits - photo counts per work order</h2>'
$vt += Tbl -Id 'vt-all' -Headers @('Work order','Property','Type','Completed','#Before','#During','#After','Pressure-test photo') -Rows $pqRows
$vtHtml = Page -Slug 'visual-twin' -Title 'Visual Twin' -Body $vt -Desc 'Visual Twin - counts-only photo record per visit, with a two-visit comparison.'
Write-Page -RelDir 'os\visual-twin' -FileName 'index.html' -Html $vtHtml
Write-Output 'visual twin written'
# --- Submission Queue ---
function Get-WoIssues {
    param($w)
    $iss = @()
    if ([int]$w.'Photos Before' -eq 0) { $iss += 'No before photo' }
    if ([int]$w.'Photos During' -eq 0) { $iss += 'No during photo' }
    if ([int]$w.'Photos After' -eq 0) { $iss += 'No after photo' }
    if ($w.'WO Type' -eq 'Winterization' -and $w.'Pressure Test Photo' -eq 'Missing') { $iss += 'Pressure-test photo missing' }
    if ($w.'Bid Needed' -eq 'Y') {
        $wb = @($BidsByWo[$w.'WO Number'])
        if (-not $wb.Count) { $iss += 'Bid needed, none submitted' }
        elseif (-not ($wb | Where-Object { $_.'Date Decided' -ne '' })) { $iss += 'Bid awaiting a decision' }
    }
    foreach ($pr in $Problems) {
        if ($pr.'Where to Look (exact IDs)' -match [regex]::Escape($w.'WO Number')) { $iss += 'Open problem ' + $pr.'Problem #' + ' - ' + $ProblemTitles[$pr.'Problem #'] }
    }
    return $iss
}
$readyRows = @(); $blockedRows = @()
foreach ($w in $RfoWOs) {
    $iss = @(Get-WoIssues $w)
    $link = '<a href="' + $Base + '/os/work-orders/detail/?wo=' + $w.'WO Number' + '">' + (H $w.'WO Number') + '</a>'
    if ($iss.Count -eq 0) {
        $readyRows += ,@($link, (H $w.'Property ID'), (H $w.'WO Type'), (H $w.'Client Name'), (H $w.'Crew Name'), (H $w.'Date Assigned'), (H $w.'Due Date'))
    } else {
        $blockedRows += ,@($link, (H $w.'Property ID'), (H $w.'WO Type'), (H $w.'Client Name'), (H $w.'Crew Name'), (H $w.'Date Assigned'), (H $w.'Due Date'), (H ($iss -join '; ')))
    }
}
$sq = '<h1>Submission Queue</h1>'
$sq += '<p class="lede">Work orders ready for the office - and the ones still blocked. Snapshot as of <strong>2026-11-10</strong>.</p>'
$sq += Tiles -Items @(
    @('Ready for Office', [string]$RfoWOs.Count, 'work orders'),
    @('Ready', [string]$readyRows.Count, 'all checks pass'),
    @('Blocked', [string]$blockedRows.Count, 'at least one check fails')
)
$sq += Note '<strong>Standing rule.</strong> A work order is ready when: (1) all photo phases are complete (before, during, and after photos all present), (2) a winterization has its pressure-test photo, (3) its bid has a decision (Date Decided is set), and (4) no open problem is linked to it. This page is read-only - there is no submit, send, or record button anywhere in this app.'
$sq += '<h2>Ready (' + $readyRows.Count + ')</h2>'
if ($readyRows.Count) { $sq += Tbl -Id 'sq-ready' -Headers @('Work order','Property','Type','Client','Crew','Assigned','Due') -Rows $readyRows }
$sq += '<h2>Blocked (' + $blockedRows.Count + ')</h2>'
if ($blockedRows.Count) { $sq += Tbl -Id 'sq-blocked' -Headers @('Work order','Property','Type','Client','Crew','Assigned','Due','Blocker') -Rows $blockedRows }
$sqHtml = Page -Slug 'submission-queue' -Title 'Submission Queue' -Body $sq -Desc 'Submission Queue - ready-for-office work orders, readiness checks and blockers.'
Write-Page -RelDir 'os\submission-queue' -FileName 'index.html' -Html $sqHtml
Write-Output 'submission queue written'
# --- War Room ---
$invOnClosed = @($Invoices | Where-Object { $WoById[$_.'WO Number'].Status -eq 'Closed' })
$invWithPay = @($Invoices | Where-Object { [decimal]$_.'Amount Received' -gt 0 })
$i5001 = $InvById['DEMO-INV-5001']; $i5005 = $InvById['DEMO-INV-5005']
$wr = '<h1>War Room</h1>'
$wr += '<p class="lede">Where the money is. Snapshot as of <strong>2026-11-10</strong>.</p>'
$wr += Tiles -Items @(
    @('Invoiced', [string]$Invoices.Count,( $BilledStr + ' billed')),
    @('With any payment', [string]$invWithPay.Count, 'invoices that received money'),
    @('Fully paid', [string]$PaidInvoices.Count, 'invoices'),
    @('Outstanding', $OutstandingStr,( 'overdue ' + $OverdueStr)),
    @('Crew paid - not tracked', '-', 'the snapshot does not record crew payments')
)
$wr += '<h2>The state machine</h2>'
$wr += KV -Pairs @(
    @('Invoiced',( $Invoices.Count.ToString() + ' invoices, ' + $BilledStr)),
    @('Received (any payment)',( $invWithPay.Count.ToString() + ' invoices, ' + $ReceivedStr)),
    @('Fully paid',( $PaidInvoices.Count.ToString() + ' invoices')),
    @('Partially paid',( $PartInvCount.ToString() + ' invoices')),
    @('Unpaid',( $UnpaidInvCount.ToString() + ' invoices')),
    @('Crew paid', 'NOT TRACKED - the snapshot does not record crew payments, so War Room does not claim a crew-paid state.'),
    @('Closed work orders with an invoice',( $invOnClosed.Count.ToString() + ' invoices on closed work orders'))
)
$wr += '<h2>Three ledgers</h2>'
$wr += KV -Pairs @(
    @('Client ledger - billed', $BilledStr),
    @('Client ledger - received', $ReceivedStr),
    @('Client ledger - outstanding', $OutstandingStr),
    @('Overdue balance', $OverdueStr),
    @('Not yet due', $NotYetDueStr)
)
$wr += '<h2>Worked examples - the money, end to end</h2>'
$wr += KV -Pairs @(
    @('Fully paid',( 'Invoice ' + (H $i5001.'Invoice ID') + ' - WO ' + (H $i5001.'WO Number') + ' - property ' + (H $i5001.'Property ID') + ': invoiced ' + (Money $i5001.Amount) + ', received ' + (Money $i5001.'Amount Received') + ', balance ' + (Money $i5001.Balance) + ' (' + (H $i5001.Status) + ').')),
    @('Partially paid',( 'Invoice ' + (H $i5005.'Invoice ID') + ' - WO ' + (H $i5005.'WO Number') + ' - property ' + (H $i5005.'Property ID') + ': invoiced ' + (Money $i5005.Amount) + ', received ' + (Money $i5005.'Amount Received') + ', balance ' + (Money $i5005.Balance) + ' (' + (H $i5005.Status) + ').'))
)
$wr += '<h2>Income ratio by client</h2>'
$wr += '<p>Income ratio = received / billed. Verdict rule: ratio 0.75 or more = Scale, 0.50-0.75 = Monitor, below 0.50 = Reprice.</p>'
$wrRows = @($ClientTable | Sort-Object Ratio -Descending | ForEach-Object { ,@((H $_.Name), (Money $_.Billed), (Money $_.Received), ($_.Ratio).ToString('F2'), (H $_.Verdict)) })
$wr += Tbl -Id 'wr-clients' -Headers @('Client','#Billed','#Received','#Income ratio','Verdict') -Rows $wrRows -NoFilter
$wrHtml = Page -Slug 'war-room' -Title 'War Room' -Body $wr -Desc 'War Room - invoiced, received, outstanding, income ratios and the three ledgers.'
Write-Page -RelDir 'os\war-room' -FileName 'index.html' -Html $wrHtml
Write-Output 'war room written'
# --- Losses ---
$inv3902 = $InvById['DEMO-INV-3902']; $inv3903 = $InvById['DEMO-INV-3903']
$lo2 = '<h1>Losses</h1>'
$lo2 += '<p class="lede">Where money leaks. Every figure below is fictional - the Demo OS is a fictional dataset. Snapshot as of <strong>2026-11-10</strong>.</p>'
$lo2 += Tiles -Items @(
    @('Overdue balance', $OverdueStr, 'invoices past due and unpaid in part'),
    @('Cut at approval', (Money $CutSum),( $ApprCut.ToString() + ' bids cut')),
    @('Above-ceiling exposure', (Money $AboveCeilExposure),( $AboveCeil.Count.ToString() + ' bids above ceiling')),
    @('Not yet due', $NotYetDueStr, 'outstanding but not overdue'),
    @('Chargebacks', [string]$Chargebacks.Count, 'in the snapshot - none')
)
$lo2 += '<h2>(a) Genuinely unpaid</h2>'
$lo2 += KV -Pairs @(
    @('Overdue invoices',( $OvInvCount.ToString() + ' invoices, ' + $OvStatusStr + ' outstanding')),
    @('Partially-paid invoices past due',( $PartInvCount.ToString() + ' invoices, ' + $PartOvStr + ' outstanding')),
    @('Overdue balance (Dashboard formula)', $OverdueStr),
    @('Unpaid - nothing received',( $UnpaidInvCount.ToString() + ' invoices')),
    @('Not yet due',( $NotYetDueStr + ' - outstanding, but the due date has not passed'))
)
$lo2 += '<h2>(b) Cut at approval</h2>'
$lo2 += '<p>' + $ApprCut + ' bids were approved for less than the bid amount. The cut total is ' + (Money $CutSum) + ' (sum of bid minus approved amount, over cut bids).</p>'
$cutRows = @($Bids | Where-Object { $_.Status -eq 'Cut' } | ForEach-Object { $c = [decimal]$_.'Bid Amount' - [decimal]$_.'Approved Amount'; [pscustomobject]@{ B=$_; CutAmt=$c } } | Sort-Object CutAmt -Descending | Select-Object -First 15 | ForEach-Object {
    $b = $_.B
    ,@(
        (H $b.'Bid ID'),
        (WoLink $b.'WO Number'),
        (H $b.'Property ID'),
        (Money $b.'Bid Amount'),
        (Money $b.'Approved Amount'),
        (Money $_.CutAmt)
    )
})
$lo2 += Tbl -Id 'loss-cut' -Headers @('Bid','Work order','Property','#Bid','#Approved','#Cut') -Rows $cutRows
$lo2 += '<h2>(c) Above the client ceiling</h2>'
$lo2 += '<p>' + $AboveCeil.Count + ' bids price above the client ceiling. Exposure is ' + (Money $AboveCeilExposure) + ' (sum of bid minus ceiling).</p>'
$lo2 += '<h2>(d) Paid under a follow-up work order</h2>'
$lo2 += '<p>Invoice ' + (H $inv3902.'Invoice ID') + ' (' + (H $inv3902.'WO Number') + ', ' + (Money $inv3902.Amount) + ') shows ' + (Money $inv3902.'Amount Received') + ' received - it looks unpaid. The client actually paid ' + (Money $inv3903.'Amount Received') + ' under the follow-up invoice ' + (H $inv3903.'Invoice ID') + ' (' + (H $inv3903.'WO Number') + ', invoiced ' + (Money $inv3903.Amount) + '). See problem P3 on the <a href="' + $Base + '/os/problems/">Problems to Solve</a> page.</p>'
$lo2 += '<h2>(e) Chargebacks</h2>'
$lo2 += '<p>No chargebacks are recorded in the snapshot (' + $Chargebacks.Count + ').</p>'
$lo2Html = Page -Slug 'losses' -Title 'Losses' -Body $lo2 -Desc 'Losses - unpaid, cut at approval, above ceiling, paid via follow-up, and chargebacks.'
Write-Page -RelDir 'os\losses' -FileName 'index.html' -Html $lo2Html
Write-Output 'losses written'
# --- Clients ---
$cl = '<h1>Clients</h1>'
$cl += '<p class="lede">The five clients who pay for this work. Snapshot as of <strong>2026-11-10</strong>.</p>'
$cl += Tiles -Items @(
    @('Clients', [string]$Clients.Count, 'in the snapshot'),
    @('Billed', $BilledStr, 'across all clients'),
    @('Received', $ReceivedStr, 'across all clients'),
    @('Outstanding', $OutstandingStr,( 'overdue ' + $OverdueStr))
)
$cl += '<p>Income ratio = received / billed. Verdict rule: ratio 0.75 or more = Scale, 0.50-0.75 = Monitor, below 0.50 = Reprice. Approval rate = (Approved + Cut) / all bids for that client. Average days to pay = last payment date minus invoice date, over fully-paid invoices.</p>'
$clRows = @($ClientTable | ForEach-Object {
    $c = $_
    ,@(
        (H $c.Name),
        (H $c.Type),
        (H $c.Contact),
        (H $c.Terms),
        [string]$c.WOs,
        [string]$c.Props,
        (Money $c.Billed),
        (Money $c.Received),
        (Money $c.Outstanding),
        (Money $c.OverdueBal),
        [string]$c.Paid,
        [string]$c.Invoices,
        (($c.ApprovalRate).ToString('F1') + '%'),
        [string]$c.Cut,
        (Money $c.CutTotal),
        $c.AvgDays.ToString('F1'),
        ($c.Ratio).ToString('F2'),
        (H $c.Verdict)
    )
})
$cl += Tbl -Id 'clients-all' -Headers @('Client','Type','Contact','Terms','#Work orders','#Properties','#Billed','#Received','#Outstanding','#Overdue','#Paid invoices','#Invoices','#Approval rate','#Cut','#Cut total','#Avg days to pay','#Income ratio','Verdict') -Rows $clRows
foreach ($c in $Clients) {
    $cid = $c.'Client ID'
    $ct = $ClientTable | Where-Object { $_.Id -eq $cid } | Select-Object -First 1
    $cl += '<h2>' + (H $c.'Client Name') + '</h2>'
    $cl += KV -Pairs @(
        @('Client ID', (H $cid)),
        @('Type', (H $c.Type)),
        @('Contact',( (H $c.'Contact Name') + ' - ' + (H $c.'Contact Email') + ' - ' + (H $c.Phone))),
        @('Payment terms', (H $c.'Payment Terms')),
        @('Notes', (H $c.Notes)),
        @('Work orders', [string]$ct.WOs),
        @('Properties', [string]$ct.Props),
        @('Billed', (Money $ct.Billed)),
        @('Received', (Money $ct.Received)),
        @('Outstanding', (Money $ct.Outstanding)),
        @('Overdue balance', (Money $ct.OverdueBal)),
        @('Approval rate', (($ct.ApprovalRate).ToString('F1') + '%')),
        @('Cut - bids / total',( $ct.Cut.ToString() + ' / ' + (Money $ct.CutTotal))),
        @('Avg days to pay', $ct.AvgDays.ToString('F1')),
        @('Income ratio / verdict',( ($ct.Ratio).ToString('F2') + ' / ' + (H $ct.Verdict)))
    )
    $cl += '<h3>Bid history by price band</h3>'
    $cb = @($Bids | Where-Object { $_.'Client ID' -eq $cid })
    $bandRows = @(
        @('Under $100', [string](@($cb | Where-Object { [decimal]$_.'Bid Amount' -lt 100 }).Count)),
        @('$100-$499', [string](@($cb | Where-Object { [decimal]$_.'Bid Amount' -ge 100 -and [decimal]$_.'Bid Amount' -lt 500 }).Count)),
        @('$500-$999', [string](@($cb | Where-Object { [decimal]$_.'Bid Amount' -ge 500 -and [decimal]$_.'Bid Amount' -lt 1000 }).Count)),
        @('$1,000 and over', [string](@($cb | Where-Object { [decimal]$_.'Bid Amount' -ge 1000 }).Count))
    )
    $cl += Tbl -Id ('cl-band-' + $cid) -Headers @('Price band','#Bids') -Rows $bandRows -NoFilter
}
$clHtml = Page -Slug 'clients' -Title 'Clients' -Body $cl -Desc 'The five clients in the Demo OS snapshot - work, money, approval rates and verdicts.'
Write-Page -RelDir 'os\clients' -FileName 'index.html' -Html $clHtml
Write-Output 'clients written'
# --- Crew ---
$cr = '<h1>Crew</h1>'
$cr += '<p class="lede">The twelve people who do the work. Snapshot as of <strong>2026-11-10</strong>.</p>'
$cr += Note '<strong>Two different counts.</strong> -Jobs (2025)- is the crew table-s own Jobs Completed 2025 column. -Closed (2026)- is computed here from work orders closed in 2026 through 2026-11-10. They measure different years and must not be compared as if they were the same thing.'
$crRows = @($CrewTable | ForEach-Object {
    $c = $_
    ,@(
        (H $c.Name),
        (H $c.Role),
        (H $c.Base),
        (H $c.Skills),
        ($c.Rating).ToString('F1'),
        [string]$c.Jobs2025,
        [string]$c.Closed,
        [string]$c.Open,
        [string]$c.Messages,
        [string]$c.Questions,
        (Chip $c.Status 'ok')
    )
})
$cr += Tbl -Id 'crew-all' -Headers @('Crew','Role','Home base','Skills','#Rating','#Jobs (2025)','#Closed (2026)','#Open','#Messages','#Questions','Status') -Rows $crRows
$cr += '<h2>Open work orders per crew</h2>'
$crOpenRows = @($CrewTable | Sort-Object Open -Descending | ForEach-Object {
    $c = $_
    $oWos = @($OpenWOs | Where-Object { $_.'Crew ID' -eq $c.Id } | Sort-Object 'Due Date' | Select-Object -First 3)
    $links = ($oWos | ForEach-Object { '<a href="' + $Base + '/os/work-orders/detail/?wo=' + $_.'WO Number' + '">' + (H $_.'WO Number') + '</a>' }) -join ', '
    ,@((H $c.Name), [string]$c.Open, $links)
})
$cr += Tbl -Id 'crew-open' -Headers @('Crew','#Open','Soonest open work orders') -Rows $crOpenRows
$crHtml = Page -Slug 'crew' -Title 'Crew' -Body $cr -Desc 'The twelve crew members in the Demo OS snapshot - roster, load and messages.'
Write-Page -RelDir 'os\crew' -FileName 'index.html' -Html $crHtml
Write-Output 'crew written'
# --- Quo (crew messages) ---
$qu = '<h1>Quo</h1>'
$qu += '<p class="lede">Every message from the field - the voice of the crew on site. Snapshot as of <strong>2026-11-10</strong>.</p>'
$msgTypeCounts = $Msgs | Group-Object Type
$qComp = ($msgTypeCounts | Where-Object { $_.Name -eq 'Completion' }).Count
$qUpd = ($msgTypeCounts | Where-Object { $_.Name -eq 'Update' }).Count
$qPhoto = ($msgTypeCounts | Where-Object { $_.Name -eq 'Photo note' }).Count
$qArr = ($msgTypeCounts | Where-Object { $_.Name -eq 'Arrival' }).Count
$qDel = ($msgTypeCounts | Where-Object { $_.Name -eq 'Delay' }).Count
$qu += Tiles -Items @(
    @('Crew messages', [string]$Msgs.Count, 'in total'),
    @('Questions', [string]$Questions.Count, 'the needs-answer proxy'),
    @('Completion', [string]$qComp, 'messages'),
    @('Update', [string]$qUpd, 'messages'),
    @('Photo note', [string]$qPhoto, 'messages'),
    @('Arrival', [string]$qArr, 'messages'),
    @('Delay', [string]$qDel, 'messages'),
    @('Messages today', [string]$MsgsToday.Count, '2026-11-10')
)
$qu += Note '<strong>Questions are the needs-answer proxy.</strong> A Question is a message that needs an answer from the office. The snapshot records messages only - it does not record replies or read receipts - so no response rate and no unanswered queue are computed here. Those numbers do not exist in the data.'
$qu += '<h2>Questions - needs an answer (' + $Questions.Count + ')</h2>'
$qRows = @($Questions | Sort-Object Date, Time -Descending | ForEach-Object {
    $m = $_
    ,@(
        (H $m.Date),
        (H $m.Time),
        (WoLink $m.'WO Number'),
        (H $m.'Property ID'),
        (H $m.'Crew Name'),
        (H $m.Message)
    )
})
$qu += Tbl -Id 'quo-questions' -Headers @('Date','Time','Work order','Property','Crew','Message') -Rows $qRows
$qu += '<h2>Messages by crew</h2>'
$msgCrewRows = @($Msgs | Group-Object 'Crew Name' | Sort-Object Count -Descending | ForEach-Object {
    $cn = $_.Name
    $nq = @($_.Group | Where-Object { $_.Type -eq 'Question' }).Count
    ,@((H $cn), [string]$_.Count, [string]$nq)
})
$qu += Tbl -Id 'quo-crew' -Headers @('Crew','#Messages','#Questions') -Rows $msgCrewRows
$qu += '<h2>Messages by work order - top 15</h2>'
$msgWoRows = @($Msgs | Group-Object 'WO Number' | Sort-Object Count -Descending | Select-Object -First 15 | ForEach-Object {
    ,@(
        (WoLink $_.Name),
        [string]$_.Count
    )
})
$qu += Tbl -Id 'quo-wo' -Headers @('Work order','#Messages') -Rows $msgWoRows -NoFilter
$qu += '<h2>Merged dispatch - open work orders with their latest message</h2>'
$dispRows = @($OpenWOs | Sort-Object 'Due Date' | ForEach-Object {
    $w = $_
    $ms = @($MsgByWo[$w.'WO Number'] | Sort-Object Date, Time -Descending)
    $lm = if ($ms.Count) { (H $ms[0].Date) + ' - ' + (H $ms[0].Message) } else { 'No message yet' }
    ,@(
        (WoLink $w.'WO Number'),
        (H $w.'Property ID'),
        (H $w.'WO Type'),
        (H $w.'Due Date'),
        (Chip $w.Status 'warn'),
        (H $w.'Crew Name'),
        $lm
    )
})
$qu += Tbl -Id 'quo-dispatch' -Headers @('Work order','Property','Type','Due','Status','Crew','Latest message') -Rows $dispRows
$qu += '<h2>Messages today - 2026-11-10 (' + $MsgsToday.Count + ')</h2>'
$todayRows = @($MsgsToday | Sort-Object Time | ForEach-Object {
    $m = $_
    ,@(
        (H $m.Time),
        (WoLink $m.'WO Number'),
        (H $m.'Property ID'),
        (H $m.'Crew Name'),
        (H $m.Type),
        (H $m.Message)
    )
})
$qu += Tbl -Id 'quo-today' -Headers @('Time','Work order','Property','Crew','Type','Message') -Rows $todayRows -NoFilter
$qu += '<h2>All messages</h2>'
$allMsgRows = @($Msgs | Sort-Object Date, Time -Descending | ForEach-Object {
    $m = $_
    ,@(
        (H $m.Date),
        (H $m.Time),
        (H $m.'Crew Name'),
        (WoLink $m.'WO Number'),
        (H $m.'Property ID'),
        (H $m.Type),
        (H $m.Message)
    )
})
$qu += Tbl -Id 'quo-all' -Headers @('Date','Time','Crew','Work order','Property','Type','Message') -Rows $allMsgRows
$quHtml = Page -Slug 'quo' -Title 'Quo' -Body $qu -Desc 'Quo - all 940 crew messages, Questions as the needs-answer proxy, and merged dispatch.'
Write-Page -RelDir 'os\quo' -FileName 'index.html' -Html $quHtml
Write-Output 'quo written'
# --- Problems to Solve ---
$pb = '<h1>Problems to Solve</h1>'
$pb += '<p class="lede">Six open problems, each with where to look and what -solved- looks like. Snapshot as of <strong>2026-11-10</strong>.</p>'
$pb += Tiles -Items @(
    @('Open problems', [string]$Problems.Count, 'all 6 open'),
    @('High priority', [string](@($Problems | Where-Object { $_.Priority -eq 'High' }).Count), 'problems'),
    @('Medium priority', [string](@($Problems | Where-Object { $_.Priority -eq 'Medium' }).Count), 'problems')
)
$pb += Note 'Ages are recomputed from the linked dates in the snapshot, as of 2026-11-10. The problem titles in the source sheet carry ages measured against 2026-02-28, which are out of date here; the ages below are the correct ones for this snapshot.'
foreach ($pr in ($Problems | Sort-Object 'Problem #')) {
    $probNo = $pr.'Problem #'
    $title = $ProblemTitles[$probNo]
    $age = $ProblemAges[$probNo]
    $priKind = if ($pr.Priority -eq 'High') { 'bad' } else { 'warn' }
    $woLink = ''
    $m = [regex]::Match($pr.'Where to Look (exact IDs)', 'DEMO-WO-\d+')
    if ($m.Success) { $woLink = ' <a href="' + $Base + '/os/work-orders/detail/?wo=' + $m.Value + '">Open work order ' + $m.Value + '</a>' }
    $pb += '<h2>' + (H $probNo) + ' - ' + (H $title) + ' ' + (Chip $pr.Priority $priKind) + '</h2>'
    $pb += KV -Pairs @(
        @('Open for',( [string]$age + ' days (as of 2026-11-10)')),
        @('Priority', (H $pr.Priority)),
        @('Owner role', (H $pr.'Owner Role')),
        @('Status', (Chip $pr.Status 'warn')),
        @('Where to look',( (H $pr.'Where to Look (exact IDs)') + $woLink))
    )
    $pb += '<h3>What happened</h3><p>' + (H $pr.'What Happened') + '</p>'
    $pb += '<h3>What -solved- looks like</h3><p>' + (H $pr.'What "Solved" Looks Like') + '</p>'
}
$pbHtml = Page -Slug 'problems' -Title 'Problems to Solve' -Body $pb -Desc 'Six open problems to solve in the Demo OS property preservation snapshot.'
Write-Page -RelDir 'os\problems' -FileName 'index.html' -Html $pbHtml
Write-Output 'problems written'
# --- Growth ---
$gr = '<h1>Growth</h1>'
$gr += '<p class="lede">How the book grows. Snapshot as of <strong>2026-11-10</strong>.</p>'
$gr += Note 'This board is <strong>structure only</strong>. No prospect rows exist in the snapshot, so every stage shows zero prospects recorded. No prospect is invented here.'
$gr += '<h2>The pipeline</h2>'
$stageRows = @(
    @('1. Route verified', '0', 'A route to a client is verified before any application is prepared.'),
    @('2. Application prepared', '0', 'The application is prepared for the verified route.'),
    @('3. Shakil authorisation', '0', 'Shakil authorises the application before it is submitted.'),
    @('4. Submitted', '0', 'The application is submitted.'),
    @('5. First work order', '0', 'The first work order arrives from the new client.'),
    @('6. Repeat', '0', 'The new client becomes a repeat source of work.')
)
$gr += Tbl -Id 'growth-stages' -Headers @('Stage','#Prospects recorded','What it means') -Rows $stageRows -NoFilter
$gr += '<h2>Verified routes</h2>'
$routeRows = @(
    @('NFR', 'Route verified'),
    @('VRM', 'Route verified'),
    @('SingleSource', 'Route verified'),
    @('Safeguard', 'Route verified'),
    @('Cyprexx', 'Route verified'),
    @('Altisource VMO', 'Route verified'),
    @('MCS', 'Route verified')
)
$gr += Tbl -Id 'growth-routes' -Headers @('Route','Status') -Rows $routeRows -NoFilter
$gr += '<p><strong>NMFS is excluded.</strong> The NMFS route was refuted - it is not a verified route and does not appear on this board as one.</p>'
$grHtml = Page -Slug 'growth' -Title 'Growth' -Body $gr -Desc 'Growth - the pipeline structure and verified routes (structure only, no invented prospects).'
Write-Page -RelDir 'os\growth' -FileName 'index.html' -Html $grHtml
Write-Output 'growth written'
# --- Team Access ---
$ta = '<h1>Team Access</h1>'
$ta += '<p class="lede">Who can see and do what. Snapshot as of <strong>2026-11-10</strong>.</p>'
$ta += Note 'This page is <strong>structure only</strong>. It lists roles, not people - no fictional roster is shown, and crew pay is never shown in this app.'
$ta += '<h2>Roles</h2>'
$roleRows = @(
    @('Owner', 'Everything', 'Full access', 'Sees and changes everything.'),
    @('Operations manager', 'Work, money, quality', 'Assigns and directs work', 'Runs Live Ops and Deadlines.'),
    @('Accounts', 'Money only (read)', 'Records money in, chases money owed', 'Money is read-only for other roles.'),
    @('Dispatcher', 'Work orders and messages', 'Dispatches crew, answers Questions', 'Works from Quo and Live Ops.'),
    @('Crew lead', 'Own crew jobs', 'Reports completion and photos', 'Own crew jobs only.')
)
$ta += Tbl -Id 'team-roles' -Headers @('Role','Sees','Can do','Notes') -Rows $roleRows -NoFilter
$ta += '<h2>Money is read-only</h2>'
$ta += '<p>Only the Accounts role changes money records. Every other role reads money. Crew pay is not recorded in the snapshot and is never shown.</p>'
$ta += '<h2>Audit log - structure</h2>'
$ta += '<p>The snapshot was built from daily batches dated 2026-01-01 through 2026-11-10 (see the <a href="' + $Base + '/data/demo-os-2026-11-10/manifest.json">snapshot manifest</a>). The audit log is the sequence of those daily batches: ' + ($AsOf - [datetime]'2026-01-01').Days + 1 + ' days of batches, frozen as of 2026-11-10. After 2026-12-31 the feed ends and the snapshot stays frozen at 2026-11-10.</p>'
$taHtml = Page -Slug 'team-access' -Title 'Team Access' -Body $ta -Desc 'Team Access - roles, money read-only, and the audit-log structure.'
Write-Page -RelDir 'os\team-access' -FileName 'index.html' -Html $taHtml
Write-Output 'team access written'
# --- Part 13c: Command Board ---
$cb = '<h1>Command Board</h1>'
$cb += '<p class="lede">The morning routine for the person running the day. Four steps, in order, with the live counts for the snapshot as of 2026-11-10. Nothing here sends anything; it only points at the work.</p>'
$highProblems = @($Problems | Where-Object { $_.Priority -eq 'High' }).Count
$cb += Tiles -Items @(
  @('Open work orders', "$($OpenWOs.Count)",( 'of ' + $WOs.Count + ' total')),
  @('Past due', "$($PastDue.Count)", 'open, due on or before 2026-11-10'),
  @('Open problems', "$($Problems.Count)", "$highProblems high priority"),
  @('Ready for office', "$($RfoWOs.Count)", "$($RfoReady.Count) pass every check"),
  @('Messages today', "$($MsgsToday.Count)", 'crew messages dated 2026-11-10'),
  @('Work orders assigned today', "$($WoToday.Count)", 'assigned 2026-11-10')
)
$cb += '<h2>Morning routine - four steps</h2>'
$cb += '<ol class="steps">'
$cb += '<li><strong>1. Dashboard.</strong> Check the money first: billed ' + $BilledStr + ', received ' + $ReceivedStr + ', outstanding ' + $OutstandingStr + '. Then the load: ' + $OpenWOs.Count + ' open work orders, ' + $PastDue.Count + ' past due. <a href="' + $Base + '/">Open the Dashboard</a>.</li>'
$cb += '<li><strong>2. Problems.</strong> ' + $Problems.Count + ' open problems, ' + $highProblems + ' high priority. Start with the oldest high-priority item. <a href="' + $Base + '/os/problems/">Open Problems to Solve</a>.</li>'
$cb += '<li><strong>3. Dispatch.</strong> ' + $PastDue.Count + ' past-due work orders, ' + $DueToday.Count + ' due today, ' + $Due48.Count + ' due in the next 48 hours. ' + $MsgsToday.Count + ' crew messages arrived today. <a href="' + $Base + '/os/deadlines/">Open Deadlines</a> and <a href="' + $Base + '/os/live-ops/">Open Live Ops</a>.</li>'
$cb += '<li><strong>4. Close-out.</strong> ' + $RfoWOs.Count + ' work orders are Ready for Office; ' + $RfoReady.Count + ' pass every submission check. ' + $PhotoGate.Count + ' winterizations still need a pressure-test photo. <a href="' + $Base + '/os/submission-queue/">Open Submission Queue</a>.</li>'
$cb += '</ol>'
$cb += '<h2>Sync health</h2>'
$rowsLoaded = $Props.Count + $Clients.Count + $Crew.Count + $WOs.Count + $Bids.Count + $Invoices.Count + $Payments.Count + $Msgs.Count + $Problems.Count
$cb += KV -Pairs @(
  @('Snapshot as-of', '2026-11-10'),
  @('Rows loaded', "$rowsLoaded"),
  @('Tables', '9 - properties, clients, crew, work orders, bids, invoices, payments, crew messages, problems'),
  @('Source files', 'data/demo-os-2026-11-10 - 10 JSON files, one per table plus manifest'),
  @('Last refresh', 'Snapshot built 2026-11-10 from the daily batches 2026-01-01 through 2026-11-10'),
  @('Next refresh', 'Daily snapshot rebuild. The app serves the last good snapshot, stamped with its as-of date.')
)
$cb += Note -Text 'The Command Board is a checklist and a health readout. It does not send messages, assign work, or change any record.' -Kind 'info'
$cbHtml = Page -Slug 'command-board' -Title 'Command Board' -Body $cb -Desc 'Command Board - the morning routine and sync health of the Property Preservation OS demo.'
Write-Page -RelDir 'os\command-board' -FileName 'index.html' -Html $cbHtml
# --- Part 13d: Meeting Brief ---
$mb = '<h1>Meeting Brief</h1>'
$mb += '<p class="lede">One page for the weekly meeting. Every line is a question, the finding from the snapshot, what it costs or risks, and the action. Figures are as of 2026-11-10 and cite the table they come from.</p>'
$dueTodayWo = @($DueToday)[0]
$topOwed = $ClientTable | Sort-Object Outstanding -Descending | Select-Object -First 1
$topOpen = $CrewTable | Sort-Object Open -Descending | Select-Object -First 1
$bidByStatus = GroupCount $Bids 'Status'
$mb += Tiles -Items @(
  @('Billed', $BilledStr, '297 invoices'),
  @('Received', $ReceivedStr, '379 payments'),
  @('Outstanding', $OutstandingStr, ('overdue balance ' + $OverdueStr)),
  @('Past-due work orders', "$($PastDue.Count)", ('of ' + $OpenWOs.Count + ' open')),
  @('Open problems', "$($Problems.Count)", "$highProblems high priority"),
  @('Questions in Quo', "$($Questions.Count)", ('of ' + $Msgs.Count + ' crew messages'))
)
$mb += '<h2>Money</h2>'
$mb += Tbl -Id 'mb-money' -Headers @('Question', 'Finding', 'Impact', 'Action') -Rows @(
  @('Are we billing everything completed?', ('Billed ' + $BilledStr + ' on 297 invoices; received ' + $ReceivedStr + '.'), ('Outstanding ' + $OutstandingStr + ' sits with clients.'), ('Chase the overdue balance ' + $OverdueStr + ' first - it is past due, not merely unpaid.')),
  @('How much of the outstanding is actually late?', ('Overdue balance ' + $OverdueStr + ' = sum of Balance where Due Date is before 2026-11-10 and Balance is over 0. Not yet due: ' + $NotYetDueStr + '.'), ('The ' + $NotYetDueStr + ' not yet due is normal timing, not a problem.'), 'Track the ageing bands on the Invoices page; the 90-plus day band is the recovery list.'),
  @('Which client is the biggest risk?', ($topOwed.Name + ' owes ' + (Money $topOwed.Outstanding) + ' of the ' + $OutstandingStr + ' outstanding.'), 'One client holds the largest share of the money owed.', 'Review that client and its open invoices on the Clients page.')
)
$mb += '<h2>Attention</h2>'
$mb += Tbl -Id 'mb-attention' -Headers @('Question', 'Finding', 'Impact', 'Action') -Rows @(
  @('What is past due?', ("$($PastDue.Count) open work orders are past due (due on or before 2026-11-10), including $($DueToday.Count) due today. The one due today is " + $dueTodayWo.'WO Number' + ' (' + $dueTodayWo.'WO Type' + ', ' + $dueTodayWo.Status + ').'), 'Past-due work is the first risk to client trust.', 'Work the oldest past-due orders first; the Deadlines page lists them oldest first.'),
  @('What is blocking submission?', "$($PhotoGate.Count) winterizations are missing a pressure-test photo; $($BidGaps.Count) work orders need a bid and have none.", 'Every blocked order costs a submission cycle.', 'Fix the photos and the missing bids before anything else goes out.'),
  @('What are the open problems?', "$($Problems.Count) open problems, $highProblems high priority. See the Problems page for the full list.", 'Open problems are the known risks; high-priority items set the day.', 'Start with the high-priority items.'),
  @('How many bids wait on a decision?', "$($bidByStatus['Pending']) bids are Pending; $($AboveCeil) bids are above the client ceiling.", ('Bids above ceiling total ' + (Money $AboveCeilExposure) + ' over the ceilings.'), 'Decide the pending bids on the Bids page; renegotiate or cut the above-ceiling ones.')
)
$mb += '<h2>Crew</h2>'
$mb += Tbl -Id 'mb-crew' -Headers @('Question', 'Finding', 'Impact', 'Action') -Rows @(
  @('Who closed the most work in 2026?', "$($CrewTable[0].Name) closed $($CrewTable[0].Closed) work orders in 2026; next are $($CrewTable[1].Name) with $($CrewTable[1].Closed) and $($CrewTable[2].Name) with $($CrewTable[2].Closed).", ('The top three closed ' + ($CrewTable[0].Closed + $CrewTable[1].Closed + $CrewTable[2].Closed) + ' of the 499 closed work orders.'), 'Keep the top closers busy; check the Crew page for the full load.'),
  @('Is anyone overloaded?', ('The heaviest open load is ' + $topOpen.Name + ' with ' + $topOpen.Open + ' open work orders.'), 'Open work is spread across 12 crew; the Crew page shows every load.', 'Balance the next assignments across the crew with the lightest loads.')
)
$mb += '<h2>Quo</h2>'
$mb += Tbl -Id 'mb-quo' -Headers @('Question', 'Finding', 'Impact', 'Action') -Rows @(
  @('What is the crew asking?', "$($Questions.Count) Questions in Quo out of $($Msgs.Count) messages; the rest are Completion, Update, Photo note, Arrival and Delay.", 'Questions are the needs-answer proxy; no reply data exists in the snapshot, so no response rate is computed.', 'Answer the Questions first, oldest first, on the Quo page.'),
  @('What arrived today?', "$($MsgsToday.Count) messages today and $($WoToday.Count) work orders assigned today.", 'Today is light compared with the past-due list.', 'Use the quiet day to clear past-due orders.')
)
$mb += '<h2>Method - how every figure is defined</h2>'
$mb += KV -Pairs @(
  @('Past due', 'Open work orders (Assigned, In Progress, Ready for Office) with Due Date on or before 2026-11-10.'),
  @('Overdue balance', 'Sum of Balance over invoices with Due Date before 2026-11-10 and Balance over 0.'),
  @('Approval rate', ('(Approved bids + Cut bids) / all bids = ' + $ApprRateStr + '.')),
  @('Avg days to pay', ('Last payment date minus invoice date, fully-paid invoices only = ' + $AvgDaysStr + ' days.')),
  @('As-of date', 'Every figure on this page is from the snapshot as of 2026-11-10.')
)
$mbHtml = Page -Slug 'meeting-brief' -Title 'Meeting Brief' -Body $mb -Desc 'Meeting Brief - the weekly meeting in one page: question, finding, impact, action, with every figure defined.'
Write-Page -RelDir 'os\meeting-brief' -FileName 'index.html' -Html $mbHtml
# --- Part 14a: Search index + Search page ---
$idx = [System.Collections.Generic.List[object]]::new()
foreach ($g in $NavGroups) { foreach ($it in $g.Items) {
  $u = if ($it.Slug) { "$Base/os/$($it.Slug)/" } else { "$Base/" }
  $idx.Add(@{ t = $it.Label; s = 'Section: ' + $g.Group; k = $it.Label + ' ' + $it.Slug; u = $u })
} }
foreach ($p in $Props) {
  $idx.Add(@{ t = $p.'Property ID' + ' - ' + $p.Address; s = $p.City + ', ' + $p.State + ' ' + $p.ZIP + ' - ' + $p.'Client Name'; k = $p.'Property ID' + ' ' + $p.Address + ' ' + $p.City + ' ' + $p.State + ' ' + $p.ZIP + ' ' + $p.'Property Type' + ' ' + $p.'Client Name'; u = "$Base/os/property-master/$($p.'Property ID')/" })
}
foreach ($w in $WOs) {
  $idx.Add(@{ t = $w.'WO Number' + ' - ' + $w.'WO Type' + ', ' + $w.Status; s = $w.'Property Address' + ' - ' + $w.'Client Name' + ' - ' + $w.'Crew Name'; k = $w.'WO Number' + ' ' + $w.'Property ID' + ' ' + $w.'Property Address' + ' ' + $w.'Client Name' + ' ' + $w.'Crew Name' + ' ' + $w.'WO Type' + ' ' + $w.Status + ' ' + $w.'Scope / Description'; u = "$Base/os/work-orders/detail/?wo=$($w.'WO Number')" })
}
foreach ($b in $Bids) {
  $idx.Add(@{ t = $b.'Bid ID' + ' - ' + $b.'Item / Scope'; s = 'Bid ' + (Money $b.'Bid Amount') + ' - ' + $b.Status + ' - WO ' + $b.'WO Number'; k = $b.'Bid ID' + ' ' + $b.'WO Number' + ' ' + $b.'Property ID' + ' ' + $b.'Client ID' + ' ' + $b.'Item / Scope' + ' ' + $b.Status; u = "$Base/os/bids/" })
}
foreach ($v in $Invoices) {
  $idx.Add(@{ t = $v.'Invoice ID' + ' - ' + (Money $v.Amount) + ' - ' + $v.Status; s = 'WO ' + $v.'WO Number' + ' - due ' + $v.'Due Date' + ' - balance ' + (Money $v.Balance); k = $v.'Invoice ID' + ' ' + $v.'WO Number' + ' ' + $v.'Bid ID' + ' ' + $v.'Property ID' + ' ' + $v.'Client ID' + ' ' + $v.Status; u = "$Base/os/invoices/" })
}
foreach ($y in $Payments) {
  $idx.Add(@{ t = $y.'Payment ID' + ' - ' + (Money $y.Amount) + ' - ' + $y.Method; s = 'Invoice ' + $y.'Invoice ID' + ' - ' + $y.'Payment Date' + ' - ' + $y.Status; k = $y.'Payment ID' + ' ' + $y.'Invoice ID' + ' ' + $y.'WO Number' + ' ' + $y.'Client ID' + ' ' + $y.Method + ' ' + $y.Reference; u = "$Base/os/payments/" })
}
foreach ($m in $Msgs) {
  $mu = if ($m.'WO Number') { "$Base/os/work-orders/detail/?wo=$($m.'WO Number')" } else { "$Base/os/quo/" }
  $idx.Add(@{ t = 'Message ' + $m.'Message ID' + ' - ' + $m.Type + ' - ' + $m.'Crew Name'; s = $m.Date + ' ' + $m.Time + ' - WO ' + $m.'WO Number' + ' - ' + $m.'Property ID'; k = $m.'Message ID' + ' ' + $m.'Crew Name' + ' ' + $m.'WO Number' + ' ' + $m.'Property ID' + ' ' + $m.Type + ' ' + $m.Message; u = $mu })
}
foreach ($c in $Crew) {
  $idx.Add(@{ t = $c.Name + ' - ' + $c.Role; s = $c.'Home Base' + ' - ' + $c.Status; k = $c.'Crew ID' + ' ' + $c.Name + ' ' + $c.Role + ' ' + $c.'Home Base' + ' ' + $c.Skills; u = "$Base/os/crew/" })
}
foreach ($cl in $Clients) {
  $idx.Add(@{ t = $cl.'Client Name'; s = $cl.Type + ' - ' + $cl.'Payment Terms'; k = $cl.'Client ID' + ' ' + $cl.'Client Name' + ' ' + $cl.Type + ' ' + $cl.'Contact Name'; u = "$Base/os/clients/" })
}
foreach ($pr in $Problems) {
  $idx.Add(@{ t = 'Problem ' + $pr.'Problem #' + ' - ' + $pr.Priority + ' priority'; s = $pr.'Owner Role' + ' - ' + $pr.Status; k = $pr.'Problem #' + ' ' + $pr.Title + ' ' + $pr.'What Happened' + ' ' + $pr.'Where to Look (exact IDs)'; u = "$Base/os/problems/" })
}
$idxDir = Join-Path $Root 'os\assets'
New-Item -ItemType Directory -Force $idxDir | Out-Null
Set-Content -Path (Join-Path $idxDir 'search-index.json') -Value ($idx | ConvertTo-Json -Depth 4) -Encoding UTF8
$sr = '<h1>Search</h1>'
$sr += '<p class="lede">Search every record in the snapshot: properties, work orders, bids, invoices, payments, crew messages, crew, clients and problems. Results link to the record or its section.</p>'
$sr += '<div class="filterbar"><label class="small muted" for="search-input">Search</label><input type="search" id="search-input" placeholder="Try DEMO-WO-2001, a street name, a crew name, or a client"></div>'
$sr += '<div id="search-results"><p class="muted">Type to search the snapshot. The index covers ' + $idx.Count + ' entries.</p></div>'
$sr += '<h2>What the search covers</h2>'
$sr += Tbl -Id 'search-coverage' -Headers @('Record', '#Entries', 'Opens') -Rows @(
  @('Sections', '23', 'The section page'),
  @('Properties', "$($Props.Count)", 'The property page'),
  @('Work orders', "$($WOs.Count)", 'The work order detail'),
  @('Bids', "$($Bids.Count)", 'The Bids page'),
  @('Invoices', "$($Invoices.Count)", 'The Invoices page'),
  @('Payments', "$($Payments.Count)", 'The Payments page'),
  @('Crew messages', "$($Msgs.Count)", 'The work order detail, or Quo'),
  @('Crew', "$($Crew.Count)", 'The Crew page'),
  @('Clients', "$($Clients.Count)", 'The Clients page'),
  @('Problems', "$($Problems.Count)", 'The Problems page')
) -NoFilter
$srHtml = Page -Slug 'search' -Title 'Search' -Body $sr -Desc 'Search - every record in the Property Preservation OS demo snapshot.'
Write-Page -RelDir 'os\search' -FileName 'index.html' -Html $srHtml
# --- Part 14b: Computed aggregates JSON + build summary ---
$woStatus = GroupCount $WOs 'Status'
$woType = GroupCount $WOs 'WO Type'
$invStatus = GroupCount $Invoices 'Status'
$msgType = GroupCount $Msgs 'Type'
$propState = GroupCount $Props 'State'
$propStatus = GroupCount $Props 'Status'
$ageBands = [ordered]@{ 'Not yet due' = 0; '1-30 days' = 0; '31-60 days' = 0; '61-90 days' = 0; 'Over 90 days' = 0 }
$ageAmt = [ordered]@{ 'Not yet due' = 0; '1-30 days' = 0; '31-60 days' = 0; '61-90 days' = 0; 'Over 90 days' = 0 }
foreach ($iv in $Invoices) {
  if ([decimal]$iv.Balance -gt 0) {
    $dd = [datetime]$iv.'Due Date'
    $band = if ($dd -ge $AsOf) { 'Not yet due' } elseif (($AsOf - $dd).Days -le 30) { '1-30 days' } elseif (($AsOf - $dd).Days -le 60) { '31-60 days' } elseif (($AsOf - $dd).Days -le 90) { '61-90 days' } else { 'Over 90 days' }
    $ageBands[$band]++
    $ageAmt[$band] = $ageAmt[$band] + [decimal]$iv.Balance
  }
}
$paidInvs = @($Invoices | Where-Object { $_.Status -eq 'Paid' })
$daysList = @()
foreach ($iv in $paidInvs) {
  $ps = $PayByInv[$iv.'Invoice ID']
  if ($ps) {
    $last = ($ps | ForEach-Object { [datetime]$_.'Payment Date' } | Measure-Object -Maximum).Maximum
    $daysList += ($last - [datetime]$iv.'Invoice Date').Days
  }
}
$avgDaysNum = [math]::Round(($daysList | Measure-Object -Average).Average, 1)
if ($avgDaysNum -ne [double]$AvgDaysStr) { Write-Warning ('Avg days to pay mismatch: recomputed ' + $avgDaysNum + ' vs page ' + $AvgDaysStr) }
$apprNum = [math]::Round((($bidByStatus['Approved'] + $bidByStatus['Cut']) / $Bids.Count) * 100, 1)
$clientJson = $ClientTable | ForEach-Object { [ordered]@{ id = $_.Id; name = $_.Name; work_orders = $_.WOs; properties = $_.Props; billed = $_.Billed; received = $_.Received; outstanding = $_.Outstanding; overdue_balance = $_.OverdueBal; paid_invoices = $_.Paid; invoices = $_.Invoices; bids = $_.Bids; approval_rate = $_.ApprovalRate; cut_bids = $_.Cut; cut_total = $_.CutTotal; avg_days_to_pay = $_.AvgDays; income_ratio = $_.Ratio; verdict = $_.Verdict } }
$crewTopJson = $CrewTable | Select-Object -First 3 | ForEach-Object { [ordered]@{ id = $_.Id; name = $_.Name; role = $_.Role; closed_2026 = $_.Closed; open = $_.Open; messages = $_.Messages; questions = $_.Questions } }
$computed = [ordered]@{
  as_of = '2026-11-10'
  fictional = $true
  snapshot = 'data/demo-os-2026-11-10'
  counts = [ordered]@{
    properties = $Props.Count
    clients = $Clients.Count
    crew = $Crew.Count
    work_orders = $WOs.Count
    bids = $Bids.Count
    invoices = $Invoices.Count
    payments = $Payments.Count
    crew_messages = $Msgs.Count
    problems = $Problems.Count
    search_entries = $idx.Count
    rows_loaded = $rowsLoaded
  }
  money = [ordered]@{
    billed = $Billed
    received = $Received
    outstanding = $Outstanding
    overdue_balance = $OverdueBal
    not_yet_due = $NotYetDueBal
    avg_invoice = [math]::Round($Billed / $Invoices.Count, 2)
    avg_days_to_pay = $avgDaysNum
    approval_rate_pct = $apprNum
  }
  work_orders = [ordered]@{
    by_status = $woStatus
    by_type = $woType
    open = $OpenWOs.Count
    past_due = $PastDue.Count
    due_today = @($DueToday).Count
    due_next_48h = $Due48.Count
    due_next_7d = $Due7.Count
    chains = $Chains.Count
    bid_gaps = $BidGaps.Count
  }
  bids = [ordered]@{
    by_status = $bidByStatus
    above_ceiling = $AboveCeil
    above_ceiling_exposure = $AboveCeilExposure
    cut_total = $CutTotal
  }
  invoices = [ordered]@{
    by_status = $invStatus
    ageing_counts = $ageBands
    ageing_amounts = $ageAmt
  }
  messages = [ordered]@{
    by_type = $msgType
    questions = $Questions.Count
    today = $MsgsToday.Count
  }
  properties = [ordered]@{
    by_state = $propState
    by_status = $propStatus
    new_2026 = $NewProps26.Count
  }
  photo = [ordered]@{
    winterization_missing_pressure_test = $PhotoGate.Count
    zero_before = $ZeroBefore
    zero_during = $ZeroDuring
    zero_after = $ZeroAfter
    any_zero_phase = $AnyZeroPhase
    total_before = $TotalPhotosBefore
    total_during = $TotalPhotosDuring
    total_after = $TotalPhotosAfter
  }
  problems = [ordered]@{
    open = $Problems.Count
    high_priority = $highProblems
  }
  today = [ordered]@{
    work_orders_assigned = $WoToday.Count
    messages = $MsgsToday.Count
  }
  clients = $clientJson
  crew_top_3 = $crewTopJson
  verification = 'All counts and money totals recomputed from the snapshot rows at build time. See verify.ps1 for the 79 independent checks.'
}
Set-Content -Path (Join-Path $Root 'data\computed-2026-11-10.json') -Value ($computed | ConvertTo-Json -Depth 5) -Encoding UTF8
Write-Output 'BUILD DONE'
Write-Output 'Pages: Dashboard + 21 sections + 108 property pages + work order detail + search'
Write-Output ('As-of: 2026-11-10; rows loaded: ' + $rowsLoaded)
Write-Output ('Billed ' + $BilledStr + '; received ' + $ReceivedStr + '; outstanding ' + $OutstandingStr)
Write-Output ('Search index entries: ' + $idx.Count)
