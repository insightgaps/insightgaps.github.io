# verify.ps1 - Step 1: verify the Demo OS snapshot (as-of 2026-11-10) against blueprint section 2.
# Fictional demo data only. Reads the JSON files in demo-os-2026-11-10/ beside this script.
$ErrorActionPreference = 'Stop'
$AsOf = [datetime]'2026-11-10'
$DataDir = Join-Path $PSScriptRoot 'demo-os-2026-11-10'
function Load-Table($name) { return (Get-Content (Join-Path $DataDir "$name.json") -Raw | ConvertFrom-Json).rows }
$Props = Load-Table 'properties'
$Clients = Load-Table 'clients'
$Crew = Load-Table 'crew'
$WOs = Load-Table 'work_orders'
$Bids = Load-Table 'bids'
$Invoices = Load-Table 'invoices'
$Payments = Load-Table 'payments'
$Msgs = Load-Table 'crew_messages'
$Problems = Load-Table 'problems'
$Manifest = Get-Content (Join-Path $DataDir 'manifest.json') -Raw | ConvertFrom-Json
$Checks = New-Object System.Collections.Generic.List[object]
function Check($name, $expected, $actual) {
  $de = 0; $da = 0
  $isNum = ([decimal]::TryParse("$expected", [ref]$de) -and [decimal]::TryParse("$actual", [ref]$da))
  $ok = if ($isNum) { $de -eq $da } else { "$actual" -eq "$expected" }
  $Checks.Add([pscustomobject]@{ Check = $name; Expected = "$expected"; Actual = "$actual"; Result = $(if ($ok) { 'PASS' } else { 'FAIL' }) }) | Out-Null
}
function SumF([object[]]$rows, [string]$field) { [decimal]($rows | ForEach-Object { [decimal]$_.$field } | Measure-Object -Sum).Sum }
function GroupCount([object[]]$rows, [string]$field) { $h = @{}; $rows | Group-Object $field | ForEach-Object { $h["$($_.Name)"] = $_.Count }; return $h }
# --- Properties ---
Check 'properties.total' 108 $Props.Count
$ByState = GroupCount $Props 'State'
Check 'properties.SD' 15 $ByState['SD']; Check 'properties.IA' 14 $ByState['IA']; Check 'properties.MO' 12 $ByState['MO']; Check 'properties.KS' 12 $ByState['KS']; Check 'properties.NE' 11 $ByState['NE']; Check 'properties.MN' 10 $ByState['MN']; Check 'properties.OH' 10 $ByState['OH']; Check 'properties.IL' 9 $ByState['IL']; Check 'properties.IN' 9 $ByState['IN']; Check 'properties.WI' 6 $ByState['WI']
$ByPropStatus = GroupCount $Props 'Status'
Check 'properties.Active' 92 $ByPropStatus['Active']
Write-Output ("INFO property.status: " + (($ByPropStatus.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '))
Check 'clients.total' 5 $Clients.Count
Check 'crew.total' 12 $Crew.Count
# --- Work orders ---
Check 'wo.total' 664 $WOs.Count
$ByWOType = GroupCount $WOs 'WO Type'
Check 'wo.Grass' 176 $ByWOType['Grass']; Check 'wo.Inspection' 134 $ByWOType['Inspection']; Check 'wo.Secure' 111 $ByWOType['Secure']; Check 'wo.Winterization' 89 $ByWOType['Winterization']; Check 'wo.Debris' 82 $ByWOType['Debris']; Check 'wo.Eviction' 72 $ByWOType['Eviction']
$ByWOStatus = GroupCount $WOs 'Status'
Check 'wo.Closed' 499 $ByWOStatus['Closed']; Check 'wo.Cancelled' 27 $ByWOStatus['Cancelled']; Check 'wo.ReadyForOffice' 37 $ByWOStatus['Ready for Office']; Check 'wo.InProgress' 66 $ByWOStatus['In Progress']; Check 'wo.Assigned' 35 $ByWOStatus['Assigned']
$OpenWOs = $WOs | Where-Object { $_.Status -in 'Assigned','In Progress','Ready for Office' }
Check 'wo.open' 138 $OpenWOs.Count
$PastDue = $OpenWOs | Where-Object { [datetime]$_.'Due Date' -le $AsOf }
Check 'wo.pastDue' 130 $PastDue.Count
$NewProps = $Props | Where-Object { [datetime]$_.'First Seen' -ge [datetime]'2026-01-01' }
Check 'properties.new2026' 8 $NewProps.Count
# --- Bids ---
Check 'bids.total' 487 $Bids.Count
$ByBidStatus = GroupCount $Bids 'Status'
Check 'bids.Approved' 278 $ByBidStatus['Approved']; Check 'bids.Cut' 78 $ByBidStatus['Cut']; Check 'bids.Pending' 65 $ByBidStatus['Pending']; Check 'bids.Rejected' 66 $ByBidStatus['Rejected']
$AboveCeil = $Bids | Where-Object { [decimal]$_.'Bid Amount' -gt [decimal]$_.'Client Ceiling' }
Check 'bids.aboveCeiling' 30 $AboveCeil.Count
$ApprovalRate = [math]::Round((($ByBidStatus['Approved'] + $ByBidStatus['Cut']) / $Bids.Count) * 100, 1)
Write-Output ("INFO bids.approvalRatePct: $ApprovalRate")
$BidWO = $WOs | Where-Object { $_.'Bid Needed' -eq 'Y' -and $_.Status -ne 'Cancelled' }
$BidIDs = $Bids | ForEach-Object { $_.'WO Number' }
$BidGaps = $BidWO | Where-Object { $_.'WO Number' -notin $BidIDs }
Check 'wo.bidGaps' 12 $BidGaps.Count
$Chains = $WOs | Where-Object { "$($_.'Supersedes WO')" -ne '' }
Check 'wo.chains' 6 $Chains.Count
Write-Output ("INFO wo.supersedes: " + (($Chains | ForEach-Object { "$($_.'WO Number')->$($_.'Supersedes WO')" }) -join ', '))
# --- Invoices + Payments ---
Check 'invoices.total' 297 $Invoices.Count
$ByInvStatus = GroupCount $Invoices 'Status'
Check 'inv.Paid' 173 $ByInvStatus['Paid']; Check 'inv.Overdue' 57 $ByInvStatus['Overdue']; Check 'inv.PartiallyPaid' 57 $ByInvStatus['Partially Paid']; Check 'inv.Unpaid' 10 $ByInvStatus['Unpaid']
$Billed = SumF $Invoices 'Amount'; $Received = SumF $Invoices 'Amount Received'; $Outstanding = SumF $Invoices 'Balance'
Check 'money.billed' 128285 $Billed; Check 'money.received' 91948 $Received; Check 'money.outstanding' 36337 $Outstanding
$OverdueBal = SumF ($Invoices | Where-Object { [datetime]$_.'Due Date' -lt $AsOf -and [decimal]$_.Balance -gt 0 }) 'Balance'
Check 'money.overdueBalance' 32089 $OverdueBal
$OverdueStatusBal = SumF ($Invoices | Where-Object { $_.Status -eq 'Overdue' }) 'Balance'
$PartiallyBal = SumF ($Invoices | Where-Object { $_.Status -eq 'Partially Paid' }) 'Balance'
Write-Output ("INFO money.overdueStatusBal=$OverdueStatusBal partiallyBal=$PartiallyBal")
$AvgInvAmt = [math]::Round($Billed / $Invoices.Count, 2)
Write-Output ("INFO money.avgInvoiceAmount=$AvgInvAmt")
Check 'payments.total' 379 $Payments.Count
$PaySum = SumF $Payments 'Amount'
Check 'payments.sum' 91948 $PaySum
Write-Output ("INFO money.paySumEqualsReceived: $($PaySum -eq $Received)")
$PaidInv = $Invoices | Where-Object { [decimal]$_.Balance -eq 0 }
$PayDays = @()
foreach ($inv in $PaidInv) { $pays = $Payments | Where-Object { $_.'Invoice ID' -eq $inv.'Invoice ID' }; if ($pays) { $last = ($pays | ForEach-Object { [datetime]$_.'Payment Date' } | Measure-Object -Maximum).Maximum; $PayDays += ($last - [datetime]$inv.'Invoice Date').Days } }
$AvgPayDays = [math]::Round(($PayDays | Measure-Object -Average).Average, 1)
Write-Output ("INFO money.avgDaysToPayAll=$AvgPayDays (n=$($PayDays.Count))")
$PayDays26 = @()
foreach ($inv in ($PaidInv | Where-Object { [datetime]$_.'Invoice Date' -ge [datetime]'2026-01-01' })) { $pays = $Payments | Where-Object { $_.'Invoice ID' -eq $inv.'Invoice ID' }; if ($pays) { $last = ($pays | ForEach-Object { [datetime]$_.'Payment Date' } | Measure-Object -Maximum).Maximum; $PayDays26 += ($last - [datetime]$inv.'Invoice Date').Days } }
Write-Output ("INFO money.avgDaysToPay2026=$([math]::Round(($PayDays26 | Measure-Object -Average).Average, 1)) (n=$($PayDays26.Count))")
# --- Crew messages ---
Check 'messages.total' 940 $Msgs.Count
$ByMsgType = GroupCount $Msgs 'Type'
Check 'msg.Completion' 342 $ByMsgType['Completion']; Check 'msg.Update' 255 $ByMsgType['Update']; Check 'msg.PhotoNote' 126 $ByMsgType['Photo note']; Check 'msg.Question' 82 $ByMsgType['Question']; Check 'msg.Arrival' 75 $ByMsgType['Arrival']; Check 'msg.Delay' 60 $ByMsgType['Delay']
Write-Output ("INFO msg.types: " + (($ByMsgType.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '))
# --- Problems + photo gate ---
Check 'problems.total' 6 $Problems.Count
Check 'problems.allOpen' 6 ($Problems | Where-Object { $_.Status -eq 'Open' }).Count
$PressVals = GroupCount ($WOs | Where-Object { $_.'WO Type' -eq 'Winterization' }) 'Pressure Test Photo'
Write-Output ("INFO photo.pressureVals: " + (($PressVals.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '))
$PhotoGate = $WOs | Where-Object { $_.'WO Type' -eq 'Winterization' -and $_.'Pressure Test Photo' -eq 'Missing' }
Check 'photo.missingPressureTest' 17 $PhotoGate.Count
# --- worked chains + crew + per-client ---
$Inv5001 = $Invoices | Where-Object { $_.'Invoice ID' -eq 'DEMO-INV-5001' }
Check 'chain.5001.amount' 423 ([decimal]$Inv5001.Amount); Check 'chain.5001.received' 423 ([decimal]$Inv5001.'Amount Received'); Check 'chain.5001.balance' 0 ([decimal]$Inv5001.Balance); Check 'chain.5001.status' 'Paid' $Inv5001.Status
$Inv5005 = $Invoices | Where-Object { $_.'Invoice ID' -eq 'DEMO-INV-5005' }
Check 'chain.5005.amount' 470 ([decimal]$Inv5005.Amount); Check 'chain.5005.received' 218 ([decimal]$Inv5005.'Amount Received'); Check 'chain.5005.balance' 252 ([decimal]$Inv5005.Balance)
$Wo2001 = $WOs | Where-Object { $_.'WO Number' -eq 'DEMO-WO-2001' }
Check 'chain.2001.property' 'DEMO-P-060' $Wo2001.'Property ID'
$ClosedByCrew = GroupCount ($WOs | Where-Object { $_.Status -eq 'Closed' }) 'Crew ID'
Check 'crew.closed.C12' 61 $ClosedByCrew['DEMO-C-12']; Check 'crew.closed.C06' 58 $ClosedByCrew['DEMO-C-06']; Check 'crew.closed.C11' 50 $ClosedByCrew['DEMO-C-11']
Write-Output ("INFO crew.closed: " + (($ClosedByCrew.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '))
$WoByClient = GroupCount $WOs 'Client ID'
Check 'client.wo.CL-01' 231 $WoByClient['CL-01']; Check 'client.wo.CL-02' 160 $WoByClient['CL-02']; Check 'client.wo.CL-03' 127 $WoByClient['CL-03']; Check 'client.wo.CL-04' 92 $WoByClient['CL-04']; Check 'client.wo.CL-05' 54 $WoByClient['CL-05']
$BilledByClient = @{}; $Invoices | Group-Object 'Client ID' | ForEach-Object { $BilledByClient[$_.Name] = SumF $_.Group 'Amount' }
Check 'client.billed.CL-01' 45709 $BilledByClient['CL-01']; Check 'client.billed.CL-02' 34519 $BilledByClient['CL-02']; Check 'client.billed.CL-03' 24555 $BilledByClient['CL-03']; Check 'client.billed.CL-04' 15603 $BilledByClient['CL-04']; Check 'client.billed.CL-05' 7899 $BilledByClient['CL-05']
$Inv3902 = $Invoices | Where-Object { $_.'Invoice ID' -eq 'DEMO-INV-3902' }
$Inv3903 = $Invoices | Where-Object { $_.'Invoice ID' -eq 'DEMO-INV-3903' }
Write-Output ("INFO p3.chain: INV-3902 status=$($Inv3902.Status) amount=$([decimal]$Inv3902.Amount) received=$([decimal]$Inv3902.'Amount Received') balance=$([decimal]$Inv3902.Balance) | INV-3903 status=$($Inv3903.Status) amount=$([decimal]$Inv3903.Amount) received=$([decimal]$Inv3903.'Amount Received') balance=$([decimal]$Inv3903.Balance)")
# --- results ---
$Fails = $Checks | Where-Object { $_.Result -eq 'FAIL' }
$Checks | Format-Table -AutoSize | Out-String -Width 150 | Write-Output
Write-Output ("VERIFY: $($Checks.Count - $Fails.Count)/$($Checks.Count) checks passed; $($Fails.Count) failed")
if ($Fails.Count -gt 0) { exit 1 }
