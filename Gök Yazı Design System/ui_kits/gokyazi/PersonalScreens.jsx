/* global React */
const { useState: usePS, useEffect: useEP } = React;

// ───────────────────────── PROFİL ─────────────────────────
function ProfilScreen({ onBack }) {
  const [open, setOpen] = usePS({ ach: true, hist: false, gunluk: false });
  const [notif, setNotif] = usePS(true);
  const [theme, setTheme] = usePS("cosmos");

  const greet = (() => {
    const h = new Date().getHours();
    if (h < 11) return "Günaydın";
    if (h < 18) return "İyi günler";
    return "İyi akşamlar";
  })();

  const stats = [
    { k: "kader", label: "Kader Puanı", value: 1247, glyph: "✦", color: "#FFC107" },
    { k: "fal", label: "Toplam Fal", value: 38, glyph: "𐰋", color: "#A78BFA" },
    { k: "hak", label: "Günlük Hak", value: "3 / 5", glyph: "☀", color: "#4DD0E1" },
  ];
  const achievements = [
    { ad: "İlk Fal", got: true, glyph: "𐰋" },
    { ad: "7 Günlük Streak", got: true, glyph: "🔥" },
    { ad: "Yolçı", got: true, glyph: "✦" },
    { ad: "10 Tarot", got: true, glyph: "✺" },
    { ad: "Bilge", got: false, glyph: "𐰉" },
    { ad: "Kam", got: false, glyph: "𐰚" },
    { ad: "30 Fal", got: false, glyph: "✷" },
    { ad: "Tengrici", got: false, glyph: "𐰢" },
    { ad: "Mucize", got: false, glyph: "✧" },
  ];
  const history = [
    { type: "Irk Bitig", date: "Bugün, 14:32", q: "Yeni iş teklifi…", roll: "𐰋𐰋𐰃", tone: "#A78BFA" },
    { type: "Türk Tarotu", date: "Dün, 22:08", q: "Bir karar…", roll: "Kam", tone: "#F472B6" },
    { type: "Takvim", date: "10 May 2026", q: "Yıllık yorum", roll: "At", tone: "#60A5FA" },
  ];

  const Section = ({ k, title, glyph, count, children }) => (
    <div style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: "1px solid rgba(255,215,0,0.18)", borderRadius: 16, overflow: "hidden" }}>
      <button onClick={() => setOpen(o => ({ ...o, [k]: !o[k] }))} style={{
        width: "100%", display: "flex", alignItems: "center", gap: 12, padding: "16px 18px",
        background: "transparent", border: 0, cursor: "pointer", color: "#fff",
      }}>
        <div style={{ width: 32, height: 32, borderRadius: 8, background: "rgba(255,215,0,0.12)", border: "1px solid rgba(255,215,0,0.3)", display: "flex", alignItems: "center", justifyContent: "center", color: "#FFC107", fontFamily: "Orkun, serif", fontSize: 16 }}>{glyph}</div>
        <div style={{ flex: 1, textAlign: "left" }}>
          <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 14, letterSpacing: "0.12em", textTransform: "uppercase" }}>{title}</div>
          {count != null && <div style={{ fontSize: 11, color: "rgba(255,255,255,0.55)", marginTop: 2 }}>{count}</div>}
        </div>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,193,7,0.7)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ transform: `rotate(${open[k] ? 180 : 0}deg)`, transition: "transform 300ms" }}><path d="m6 9 6 6 6-6"/></svg>
      </button>
      {open[k] && <div style={{ padding: "0 18px 18px" }}>{children}</div>}
    </div>
  );

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/tarot_arkayuz.png" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover", opacity: 0.12, filter: "blur(2px)" }} />
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 0%, rgba(45,27,105,0.55) 0%, rgba(12,10,24,0.95) 60%, #0C0A18 100%)" }} />

      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 56, display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20 }}>
        <button onClick={onBack} style={{ width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{ flex: 1, textAlign: "center", color: "#fff", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "0.2em", fontSize: 14, textTransform: "uppercase", marginRight: 40 }}>Profil</div>
      </div>

      <div style={{ position: "absolute", inset: "56px 0 0", overflow: "auto" }}>
        <div style={{ padding: "16px 16px 32px", display: "flex", flexDirection: "column", gap: 14 }}>

          {/* Greeting card */}
          <div style={{ background: "linear-gradient(155deg, rgba(91,33,182,0.35) 0%, rgba(12,10,24,0.7) 100%)", backdropFilter: "blur(20px)", border: "1px solid rgba(255,215,0,0.25)", borderRadius: 20, padding: 20, position: "relative", overflow: "hidden" }}>
            <img src="../../assets/ikon.png" style={{ position: "absolute", right: -40, top: -30, width: 180, height: 180, opacity: 0.1 }} />
            <div style={{ position: "relative", display: "flex", alignItems: "center", gap: 14, marginBottom: 14 }}>
              <div style={{ width: 56, height: 56, borderRadius: "50%", background: "linear-gradient(135deg, #FFD700, #C99411)", color: "#0C0A18", fontSize: 22, fontWeight: 800, display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 8px 20px rgba(212,160,23,0.4)" }}>B</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 12, color: "rgba(255,255,255,0.6)", letterSpacing: "0.08em" }}>{greet},</div>
                <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 22, color: "#fff", letterSpacing: "0.1em" }}>Bilge</div>
                <div style={{ fontSize: 11, color: "rgba(255,215,0,0.65)", marginTop: 2 }}>bilge@gokyazi.app</div>
              </div>
            </div>
            <div style={{ position: "relative", color: "rgba(255,193,7,0.85)", fontSize: 13, fontStyle: "italic", textAlign: "center", lineHeight: 1.5 }}>
              "Ruhun bugün sana ne fısıldıyor?"
            </div>
            {/* XP bar */}
            <div style={{ marginTop: 16 }}>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: 11, color: "rgba(255,255,255,0.7)", marginBottom: 6 }}>
                <span style={{ fontFamily: "'Cinzel Decorative', serif", letterSpacing: "0.14em", color: "#FFC107" }}>Seviye 4 · Bilge</span>
                <span>260 / 400 DP</span>
              </div>
              <div style={{ height: 8, background: "rgba(255,255,255,0.06)", borderRadius: 4, overflow: "hidden", border: "1px solid rgba(255,215,0,0.15)" }}>
                <div style={{ width: "65%", height: "100%", background: "linear-gradient(90deg, #C99411, #FFD700)", borderRadius: 4, boxShadow: "0 0 12px rgba(255,193,7,0.6)" }} />
              </div>
            </div>
          </div>

          {/* Stats grid */}
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
            {stats.map(s => (
              <div key={s.k} style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: `1px solid ${s.color}44`, borderRadius: 14, padding: "14px 8px", textAlign: "center" }}>
                <div style={{ fontFamily: "Orkun, serif", fontSize: 22, color: s.color, textShadow: `0 0 12px ${s.color}99`, marginBottom: 4 }}>{s.glyph}</div>
                <div style={{ fontSize: 18, color: "#fff", fontWeight: 700 }}>{s.value}</div>
                <div style={{ fontSize: 9, color: "rgba(255,255,255,0.55)", letterSpacing: "0.12em", textTransform: "uppercase", marginTop: 4 }}>{s.label}</div>
              </div>
            ))}
          </div>

          {/* Streak */}
          <div style={{ background: "linear-gradient(155deg, rgba(245,101,39,0.18) 0%, rgba(12,10,24,0.7) 70%)", border: "1px solid rgba(245,101,39,0.35)", borderRadius: 14, padding: 14, display: "flex", alignItems: "center", gap: 12 }}>
            <div style={{ fontSize: 28 }}>🔥</div>
            <div style={{ flex: 1 }}>
              <div style={{ color: "#FFA372", fontWeight: 700, fontSize: 14 }}>5 gün üst üste!</div>
              <div style={{ color: "rgba(255,255,255,0.6)", fontSize: 11, marginTop: 2 }}>Devam et — 7 günde rozet kazan</div>
            </div>
            <div style={{ display: "flex", gap: 4 }}>
              {[1,2,3,4,5,6,7].map(d => (
                <div key={d} style={{ width: 14, height: 22, borderRadius: 4, background: d <= 5 ? "linear-gradient(180deg, #F56527, #C04317)" : "rgba(255,255,255,0.08)", border: "1px solid rgba(255,255,255,0.1)" }} />
              ))}
            </div>
          </div>

          {/* Achievements */}
          <Section k="ach" title="Başarımlar" glyph="✦" count="3 / 9 açıldı">
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8, marginTop: 6 }}>
              {achievements.map(a => (
                <div key={a.ad} style={{
                  aspectRatio: "1/1", borderRadius: 12,
                  background: a.got ? "rgba(255,193,7,0.15)" : "rgba(0,0,0,0.35)",
                  border: `1px solid ${a.got ? "rgba(255,193,7,0.55)" : "rgba(255,255,255,0.06)"}`,
                  display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 4,
                  opacity: a.got ? 1 : 0.45,
                  position: "relative",
                }}>
                  {!a.got && <svg style={{ position: "absolute", top: 6, right: 6 }} width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2"><rect x="3" y="11" width="18" height="10" rx="2"/><path d="M8 11V8a4 4 0 1 1 8 0v3"/></svg>}
                  <div style={{ fontFamily: "Orkun, serif", fontSize: 22, color: a.got ? "#FFC107" : "rgba(255,255,255,0.45)", textShadow: a.got ? "0 0 12px rgba(255,193,7,0.6)" : "none" }}>{a.glyph}</div>
                  <div style={{ fontSize: 10, color: a.got ? "#fff" : "rgba(255,255,255,0.6)", textAlign: "center" }}>{a.ad}</div>
                </div>
              ))}
            </div>
          </Section>

          {/* Past readings */}
          <Section k="hist" title="Geçmiş Fallar" glyph="𐰋" count={`${history.length} kayıt`}>
            <div style={{ display: "flex", flexDirection: "column", gap: 8, marginTop: 6 }}>
              {history.map((h, k) => (
                <div key={k} style={{ display: "flex", alignItems: "center", gap: 10, padding: 10, borderRadius: 10, background: "rgba(0,0,0,0.3)" }}>
                  <div style={{ width: 38, height: 38, borderRadius: 9, background: `${h.tone}22`, border: `1px solid ${h.tone}55`, display: "flex", alignItems: "center", justifyContent: "center", color: h.tone, fontFamily: "Orkun, serif", fontSize: 14 }}>{h.roll}</div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 10, color: h.tone, fontWeight: 600, letterSpacing: "0.08em", textTransform: "uppercase" }}>{h.type}</div>
                    <div style={{ fontSize: 13, color: "#fff", marginTop: 1, whiteSpace: "nowrap", textOverflow: "ellipsis", overflow: "hidden" }}>{h.q}</div>
                    <div style={{ fontSize: 10, color: "rgba(255,255,255,0.45)", marginTop: 1 }}>{h.date}</div>
                  </div>
                </div>
              ))}
            </div>
          </Section>

          {/* Sky Diary integration */}
          <Section k="gunluk" title="GöKyüzü Günlüğü" glyph="✺" count="Bağlı · 12 senkron">
            <div style={{ marginTop: 6 }}>
              <div style={{ display: "flex", alignItems: "center", gap: 10, padding: 12, borderRadius: 12, background: "rgba(76,175,80,0.1)", border: "1px solid rgba(76,175,80,0.35)", marginBottom: 10 }}>
                <div style={{ width: 8, height: 8, borderRadius: 4, background: "#4CAF50", boxShadow: "0 0 8px rgba(76,175,80,0.7)" }} />
                <div style={{ flex: 1, color: "#86EFAC", fontSize: 12 }}>Bağlantı aktif · 12 fal senkron</div>
              </div>
              <button style={{ width: "100%", height: 44, borderRadius: 12, background: "rgba(255,193,7,0.12)", border: "1px solid rgba(255,193,7,0.4)", color: "#FFC107", fontSize: 12, letterSpacing: "0.14em", textTransform: "uppercase", cursor: "pointer" }}>Günlüğümü Aç</button>
            </div>
          </Section>

          {/* Personalization */}
          <div style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: "1px solid rgba(255,255,255,0.08)", borderRadius: 16, padding: 18 }}>
            <div style={{ color: "rgba(255,255,255,0.55)", fontSize: 10, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 14 }}>Kişiselleştirme</div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0", borderBottom: "1px solid rgba(255,255,255,0.06)" }}>
              <div>
                <div style={{ color: "#fff", fontSize: 14 }}>Bildirimler</div>
                <div style={{ color: "rgba(255,255,255,0.5)", fontSize: 11 }}>Günlük fal hatırlatması</div>
              </div>
              <button onClick={() => setNotif(n => !n)} style={{
                width: 46, height: 26, borderRadius: 13, padding: 2, cursor: "pointer",
                background: notif ? "rgba(255,193,7,0.7)" : "rgba(255,255,255,0.12)",
                border: "1px solid rgba(255,255,255,0.15)", position: "relative", transition: "background 250ms",
              }}>
                <div style={{ width: 20, height: 20, borderRadius: 10, background: "#fff", transform: notif ? "translateX(20px)" : "translateX(0)", transition: "transform 250ms", boxShadow: "0 2px 6px rgba(0,0,0,0.4)" }} />
              </button>
            </div>
            <div style={{ padding: "10px 0" }}>
              <div style={{ color: "#fff", fontSize: 14, marginBottom: 8 }}>Tema</div>
              <div style={{ display: "flex", gap: 8 }}>
                {[["cosmos","Cosmos"],["amber","Altın"]].map(([k, label]) => (
                  <button key={k} onClick={() => setTheme(k)} style={{
                    flex: 1, padding: "8px 12px", borderRadius: 10, fontSize: 12, cursor: "pointer",
                    background: theme === k ? "rgba(255,193,7,0.18)" : "rgba(255,255,255,0.05)",
                    border: `1px solid ${theme === k ? "rgba(255,193,7,0.55)" : "rgba(255,255,255,0.1)"}`,
                    color: theme === k ? "#FFC107" : "rgba(255,255,255,0.7)",
                  }}>{label}</button>
                ))}
              </div>
            </div>
          </div>

          {/* Account actions */}
          <div style={{ display: "flex", flexDirection: "column", gap: 8, marginTop: 6 }}>
            <button style={{ height: 48, borderRadius: 12, background: "rgba(245,101,39,0.12)", border: "1px solid rgba(245,101,39,0.4)", color: "#FFA372", fontSize: 13, letterSpacing: "0.12em", textTransform: "uppercase", cursor: "pointer" }}>Çıkış Yap</button>
            <button style={{ height: 48, borderRadius: 12, background: "rgba(244,67,54,0.1)", border: "1px solid rgba(244,67,54,0.4)", color: "#F87171", fontSize: 13, letterSpacing: "0.12em", textTransform: "uppercase", cursor: "pointer" }}>Hesabı Sil</button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ───────────────────────── AYARLAR ─────────────────────────
function AyarlarScreen({ onBack }) {
  const [theme, setTheme] = usePS("cosmos");
  const [lang, setLang] = usePS("tr");
  const [sound, setSound] = usePS(true);
  const [haptic, setHaptic] = usePS(true);
  const langs = [
    { k: "tr", label: "Türkçe", glyph: "TR", on: true },
    { k: "az", label: "Azərbaycanca", glyph: "AZ", on: false },
    { k: "kk", label: "Қазақша", glyph: "KK", on: false },
    { k: "uz", label: "Oʻzbekcha", glyph: "UZ", on: false },
    { k: "jp", label: "日本語", glyph: "JP", on: false },
  ];

  const Row = ({ icon, title, sub, right, danger }) => (
    <div style={{ display: "flex", alignItems: "center", gap: 14, padding: "14px 16px", borderBottom: "1px solid rgba(255,255,255,0.04)" }}>
      <div style={{ width: 36, height: 36, borderRadius: 10, background: danger ? "rgba(244,67,54,0.15)" : "rgba(255,193,7,0.12)", border: `1px solid ${danger ? "rgba(244,67,54,0.35)" : "rgba(255,193,7,0.3)"}`, color: danger ? "#F87171" : "#FFC107", display: "flex", alignItems: "center", justifyContent: "center" }}>
        {icon}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ color: danger ? "#F87171" : "#fff", fontSize: 14 }}>{title}</div>
        {sub && <div style={{ color: "rgba(255,255,255,0.5)", fontSize: 11, marginTop: 2 }}>{sub}</div>}
      </div>
      {right}
    </div>
  );

  const Toggle = ({ on, onChange }) => (
    <button onClick={onChange} style={{
      width: 46, height: 26, borderRadius: 13, padding: 2, cursor: "pointer", flexShrink: 0,
      background: on ? "rgba(255,193,7,0.7)" : "rgba(255,255,255,0.12)",
      border: "1px solid rgba(255,255,255,0.15)", transition: "background 250ms",
    }}>
      <div style={{ width: 20, height: 20, borderRadius: 10, background: "#fff", transform: on ? "translateX(20px)" : "translateX(0)", transition: "transform 250ms", boxShadow: "0 2px 6px rgba(0,0,0,0.4)" }} />
    </button>
  );

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 0%, rgba(45,27,105,0.4) 0%, rgba(12,10,24,0.95) 60%, #0C0A18 100%)" }} />

      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 56, display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20 }}>
        <button onClick={onBack} style={{ width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{ flex: 1, textAlign: "center", color: "#fff", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "0.2em", fontSize: 14, textTransform: "uppercase", marginRight: 40 }}>Ayarlar</div>
      </div>

      <div style={{ position: "absolute", inset: "56px 0 0", overflow: "auto" }}>
        <div style={{ padding: "16px 16px 32px", display: "flex", flexDirection: "column", gap: 18 }}>

          <SettingsGroup title="Görünüm">
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/></svg>} title="Karanlık Tema" sub="Cosmos · varsayılan" right={<div style={{ fontSize: 11, color: "rgba(255,193,7,0.7)", letterSpacing: "0.1em", textTransform: "uppercase" }}>Aktif</div>} />
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 22a1 1 0 0 1-1-1v-3.4a6 6 0 1 1 2 0V21a1 1 0 0 1-1 1ZM12 14a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z"/></svg>} title="Animasyonlar" sub="Geçiş efektleri ve glow" right={<Toggle on={true} onChange={() => {}} />} />
          </SettingsGroup>

          <SettingsGroup title="Dil">
            <div style={{ padding: "10px 16px 14px" }}>
              <div style={{ color: "rgba(255,255,255,0.55)", fontSize: 10, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 10 }}>Mevcut</div>
              {langs.map(l => (
                <button key={l.k} disabled={!l.on} onClick={() => l.on && setLang(l.k)} style={{
                  width: "100%", display: "flex", alignItems: "center", gap: 14, padding: "10px 12px",
                  background: lang === l.k ? "rgba(255,193,7,0.12)" : "transparent",
                  border: `1px solid ${lang === l.k ? "rgba(255,193,7,0.45)" : "transparent"}`,
                  borderRadius: 10, cursor: l.on ? "pointer" : "not-allowed", color: "#fff", marginBottom: 4,
                  opacity: l.on ? 1 : 0.45,
                }}>
                  <div style={{ width: 36, height: 26, borderRadius: 6, background: "rgba(255,193,7,0.12)", border: "1px solid rgba(255,193,7,0.3)", color: "#FFC107", fontWeight: 700, fontSize: 11, display: "flex", alignItems: "center", justifyContent: "center", letterSpacing: "0.05em" }}>{l.glyph}</div>
                  <div style={{ flex: 1, textAlign: "left", fontSize: 14 }}>{l.label}</div>
                  {!l.on && <div style={{ fontSize: 9, color: "rgba(255,255,255,0.45)", letterSpacing: "0.1em", textTransform: "uppercase" }}>Yakında</div>}
                  {lang === l.k && <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFC107" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>}
                </button>
              ))}
            </div>
          </SettingsGroup>

          <SettingsGroup title="Ses & His">
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>} title="Ses Efektleri" sub="Davul ve geçiş sesleri" right={<Toggle on={sound} onChange={() => setSound(s => !s)} />} />
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M3 12h2M19 12h2M12 3v2M12 19v2"/></svg>} title="Titreşim" sub="Zar atışında dokunsal" right={<Toggle on={haptic} onChange={() => setHaptic(h => !h)} />} />
          </SettingsGroup>

          <SettingsGroup title="Hakkında">
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>} title="Versiyon" right={<div style={{ fontSize: 12, color: "rgba(255,255,255,0.6)" }}>2.1.0</div>} />
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/></svg>} title="İletişim" sub="destek@gokyazi.app" right={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2"><path d="m9 18 6-6-6-6"/></svg>} />
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M9 12h6M9 16h6M9 8h6M5 5h14a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2Z"/></svg>} title="Gizlilik Politikası" right={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2"><path d="m9 18 6-6-6-6"/></svg>} />
            <Row icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>} title="Kullanım Şartları" right={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2"><path d="m9 18 6-6-6-6"/></svg>} />
          </SettingsGroup>

          <div style={{ textAlign: "center", color: "rgba(255,255,255,0.35)", fontSize: 10, letterSpacing: "0.15em", textTransform: "uppercase", padding: "10px 0" }}>
            Gök Yazı · Tengri'nin sesi
          </div>
        </div>
      </div>
    </div>
  );
}

function SettingsGroup({ title, children }) {
  return (
    <div>
      <div style={{ color: "rgba(255,255,255,0.5)", fontSize: 10, letterSpacing: "0.18em", textTransform: "uppercase", marginBottom: 8, marginLeft: 16, fontWeight: 600 }}>{title}</div>
      <div style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: "1px solid rgba(255,215,0,0.15)", borderRadius: 14, overflow: "hidden" }}>{children}</div>
    </div>
  );
}

Object.assign(window, { ProfilScreen, AyarlarScreen });
