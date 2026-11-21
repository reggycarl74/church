// Plain JavaScript, no build step.
(() => {
  "use strict";

  // Confirmation for delete buttons: <form data-confirm="...">
  document.addEventListener("submit", (e) => {
    const msg = e.target.dataset && e.target.dataset.confirm;
    if (msg && !window.confirm(msg)) e.preventDefault();
  }, true);

  const sheet = document.getElementById("sheet");
  if (!sheet) return;

  const typeId = sheet.dataset.typeId;
  const url = sheet.dataset.upsertUrl;
  const currency = sheet.dataset.currency || "EUR";
  const token = document.querySelector('meta[name="csrf-token"]')?.content;
  const status = document.getElementById("save-status");
  const money = new Intl.NumberFormat("de-DE", { style: "currency", currency });
  const fmt = (c) => money.format(c / 100);
  const plain = (c) => c ? new Intl.NumberFormat("de-DE", { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(c / 100) : "";
  const setStatus = (text, cls) => { if (status) { status.textContent = text; status.className = "save-status " + (cls || ""); } };
  let pending = 0;

  function parse(text) {
    let s = String(text).trim().replace(/[€$£\s]/g, "");
    if (!s) return 0;
    if (s.includes(",") && s.includes(".")) {
      s = s.lastIndexOf(",") > s.lastIndexOf(".") ? s.replace(/\./g, "").replace(",", ".") : s.replace(/,/g, "");
    } else if (s.includes(",")) s = s.replace(",", ".");
    if (!/^\d*\.?\d{0,2}$/.test(s) || s === ".") return NaN;
    return Math.round(parseFloat(s) * 100);
  }

  function recalc() {
    const grandDay = [];
    const sections = [...sheet.querySelectorAll("[data-section]")];
    sections.forEach((sec, si) => {
      const colTotals = [];
      sec.querySelectorAll("tbody tr[data-row]").forEach((row) => {
        let rowTotal = 0;
        row.querySelectorAll("[data-cell]").forEach((cell) => {
          const c = Number(cell.dataset.cents) || 0, col = Number(cell.dataset.col);
          rowTotal += c;
          colTotals[col] = (colTotals[col] || 0) + c;
        });
        row.querySelector("[data-row-total]").textContent = fmt(rowTotal);
      });
      let secTotal = 0;
      sec.querySelectorAll("[data-section-col]").forEach((td) => {
        const col = Number(td.dataset.sectionCol), v = colTotals[col] || 0;
        td.textContent = fmt(v); secTotal += v;
        grandDay[col] = (grandDay[col] || 0) + v;
        const g = sheet.querySelector(`[data-grand-row="${si}"] [data-grand-col="${col}"]`);
        if (g) g.textContent = fmt(v);
      });
      sec.querySelector("[data-section-total]").textContent = fmt(secTotal);
      const gt = sheet.querySelector(`[data-grand-row="${si}"] [data-grand-row-total]`);
      if (gt) gt.textContent = fmt(secTotal);
    });
    let grand = 0;
    sheet.querySelectorAll("[data-grand-day]").forEach((td) => {
      const v = grandDay[Number(td.dataset.grandDay)] || 0;
      td.textContent = fmt(v); grand += v;
    });
    const g = sheet.querySelector("[data-grand-total]");
    if (g) g.textContent = fmt(grand);
  }

  async function save(input) {
    const cents = parse(input.value);
    if (isNaN(cents) || cents < 0) {
      input.classList.add("bad");
      setStatus("Invalid amount — use e.g. 20 or 12,50", "warn");
      return;
    }
    input.classList.remove("bad");
    if (cents === Number(input.dataset.cents)) { input.value = plain(cents); return; }

    const previous = input.dataset.cents;
    input.dataset.cents = cents;
    input.value = plain(cents);
    recalc();
    pending++; setStatus("Saving…");
    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json", "Accept": "application/json", "X-CSRF-Token": token },
        body: JSON.stringify({ member_id: input.dataset.memberId, offering_type_id: typeId, date: input.dataset.date, amount: input.value }),
        credentials: "same-origin"
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `Error ${res.status}`);
      input.classList.remove("unsaved");
      pending--;
      if (!pending) setStatus("Saved ✓", "ok");
    } catch (err) {
      pending--;
      input.dataset.cents = previous;
      input.classList.add("bad", "unsaved");
      recalc();
      setStatus(`Not saved: ${err.message}. Check your connection and try again.`, "warn");
    }
  }

  sheet.addEventListener("change", (e) => { if (e.target.matches("input.amt")) save(e.target); });
  sheet.addEventListener("focusin", (e) => { if (e.target.matches("input.amt")) e.target.select(); });
  sheet.addEventListener("keydown", (e) => {
    const input = e.target;
    if (!input.matches("input.amt") || e.key !== "Enter") return;
    e.preventDefault();
    const column = [...sheet.querySelectorAll(`input.amt[data-date="${input.dataset.date}"]`)];
    const next = column[column.indexOf(input) + (e.shiftKey ? -1 : 1)];
    input.blur(); // triggers change → save
    if (next) next.focus();
  });

  window.addEventListener("beforeunload", (e) => {
    if (pending > 0 || sheet.querySelector("input.unsaved")) { e.preventDefault(); e.returnValue = ""; }
  });
})();
