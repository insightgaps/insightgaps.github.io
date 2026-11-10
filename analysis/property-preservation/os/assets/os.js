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
