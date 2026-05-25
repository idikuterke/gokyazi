/* global React */
const { useState: useES, useEffect: useEE } = React;

// ───────────────────────── RİTÜEL · KOZMİK ARINMA ─────────────────────────
function RituelScreen({ onBack }) {
  const steps = [
    { glyph: "𐰢", title: "Hazırlık", body: "Rahat bir yere otur. Üç derin nefes al. Gözlerini hafif kapat.", duration: 30 },
    { glyph: "𐰋", title: "Niyet", body: "Bugün arınmak istediğin şeyi içinden geçir. Tek bir kelime bul.", duration: 45 },
    { glyph: "𐰚", title: "Tengri'ye Çağrı", body: "Göklere ellerini aç. \"Tengri\" diye fısılda. Sesin titreşsin.", duration: 60 },
    { glyph: "𐰽", title: "Davul Sesi", body: "İçinde davulun ritmini duy. Her vuruşta bir parça gölge çözülür.", duration: 90 },
    { glyph: "✦", title: "Şükran", body: "Arınma için Yer Ana'ya ve Ak Ana'ya teşekkür et. Gözlerini aç.", duration: 30 },
  ];

  const [stage, setStage] = useES("intro"); // intro | running | done
  const [idx, setIdx] = useES(0);
  const [tick, setTick] = useES(0);
  const [playing, setPlaying] = useES(false);

  // Step timer
  useEE(() => {
    if (stage !== "running" || !playing) return;
    const dur = steps[idx].duration;
    if (tick >= dur) {
      if (idx === steps.length - 1) {
        setStage("done");
        return;
      }
      setIdx(i => i + 1);
      setTick(0);
      return;
    }
    const t = setTimeout(() => setTick(s => s + 1), 100); // accelerated for prototype
    return () => clearTimeout(t);
  }, [stage, playing, tick, idx]);

  const reset = () => { setStage("intro"); setIdx(0); setTick(0); setPlaying(false); };
  const start = () => { setStage("running"); setIdx(0); setTick(0); setPlaying(true); };

  const currentDuration = steps[idx].duration;
  const stepProgress = stage === "running" ? tick / currentDuration : 0;
  const overallProgress = stage === "running" ? (idx + stepProgress) / steps.length : (stage === "done" ? 1 : 0);

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/tengri.jpeg" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover", opacity: 0.32, mixBlendMode: "screen", filter: stage === "done" ? "brightness(1.3) saturate(1.2)" : "none", transition: "filter 1500ms ease" }} />
      <div style={{ position: "absolute", inset: 0, background: stage === "done"
        ? "radial-gradient(ellipse at 50% 40%, rgba(255,215,0,0.35) 0%, rgba(45,27,105,0.6) 35%, rgba(12,10,24,0.95) 75%, #0C0A18 100%)"
        : "radial-gradient(ellipse at 50% 35%, rgba(91,33,182,0.5) 0%, rgba(12,10,24,0.95) 65%, #0C0A18 100%)",
        transition: "background 1500ms ease",
      }} />

      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 56, display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20 }}>
        <button onClick={onBack} style={{ width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{ flex: 1, textAlign: "center", color: "#fff", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "0.2em", fontSize: 14, textTransform: "uppercase", marginRight: 40 }}>Kozmik Arınma</div>
      </div>

      <div style={{ position: "absolute", inset: "56px 0 0", overflow: "hidden" }}>
        {stage === "intro" && (
          <div style={{ minHeight: "100%", padding: "24px 28px 32px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 28, boxSizing: "border-box" }}>
            <div style={{ position: "relative", width: 200, height: 200 }}>
              <div style={{ position: "absolute", inset: 0, borderRadius: "50%", border: "1.5px solid rgba(255,215,0,0.45)", animation: "ri-spin 24s linear infinite" }}>
                {[0,1,2,3,4,5,6,7].map(k => {
                  const a = (k / 8) * Math.PI * 2;
                  const x = Math.cos(a - Math.PI / 2) * 92;
                  const y = Math.sin(a - Math.PI / 2) * 92;
                  return (
                    <div key={k} style={{ position: "absolute", top: "50%", left: "50%", marginLeft: -8, marginTop: -8, transform: `translate(${x}px, ${y}px)`, color: "#FFC107", fontFamily: "Orkun, serif", fontSize: 18, textShadow: "0 0 10px rgba(255,193,7,0.7)" }}>{"𐰋𐰃𐱅𐰢𐰚𐰽𐰉𐰉"[k]}</div>
                  );
                })}
              </div>
              <div style={{ position: "absolute", top: "50%", left: "50%", marginLeft: -50, marginTop: -50, width: 100, height: 100, borderRadius: "50%", background: "radial-gradient(circle, rgba(255,215,0,0.4) 0%, transparent 70%)", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Orkun, serif", fontSize: 56, color: "#FFD700", textShadow: "0 0 24px rgba(255,215,0,0.8)", animation: "ri-pulse 3s ease-in-out infinite" }}>𐰚</div>
            </div>
            <div style={{ textAlign: "center", maxWidth: 320 }}>
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 24, color: "#fff", letterSpacing: "0.14em", marginBottom: 10, textShadow: "0 0 16px rgba(255,215,0,0.4)" }}>Kozmik Arınma</div>
              <div style={{ color: "rgba(224,224,224,0.85)", fontSize: 14, lineHeight: 1.7 }}>
                5 adımda, yaklaşık 4 dakika. Kadim ritüel seni temizleyecek ve yeni bir niyet için açacak.
              </div>
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 8, width: "100%", maxWidth: 320 }}>
              {steps.map((s, k) => (
                <div key={k} style={{ display: "flex", alignItems: "center", gap: 12, padding: "10px 14px", background: "rgba(12,10,24,0.6)", border: "1px solid rgba(255,215,0,0.15)", borderRadius: 12 }}>
                  <div style={{ width: 28, height: 28, borderRadius: 7, background: "rgba(255,193,7,0.15)", border: "1px solid rgba(255,193,7,0.4)", display: "flex", alignItems: "center", justifyContent: "center", color: "#FFC107", fontFamily: "Orkun, serif", fontSize: 14 }}>{s.glyph}</div>
                  <div style={{ flex: 1, color: "#fff", fontSize: 13 }}>{s.title}</div>
                  <div style={{ color: "rgba(255,255,255,0.45)", fontSize: 11 }}>{s.duration}s</div>
                </div>
              ))}
            </div>
            <button onClick={start} style={{
              width: "100%", maxWidth: 320, height: 58, borderRadius: 14, border: 0,
              background: "linear-gradient(180deg, #E5B225 0%, #C99411 100%)",
              color: "#0C0A18", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 16,
              letterSpacing: "0.2em", textTransform: "uppercase", cursor: "pointer",
              boxShadow: "0 8px 24px rgba(212,160,23,0.35), inset 0 1px 0 rgba(255,255,255,0.4)",
            }}>Ritüele Başla</button>
          </div>
        )}

        {stage === "running" && (
          <div style={{ minHeight: "100%", padding: "24px 28px 32px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 30, boxSizing: "border-box" }}>
            {/* Big radial progress with glyph */}
            <div style={{ position: "relative", width: 220, height: 220 }}>
              <svg width="220" height="220" style={{ position: "absolute", inset: 0, transform: "rotate(-90deg)" }}>
                <circle cx="110" cy="110" r="100" fill="none" stroke="rgba(255,255,255,0.06)" strokeWidth="2" />
                <circle cx="110" cy="110" r="100" fill="none" stroke="#FFC107" strokeWidth="3" strokeLinecap="round" strokeDasharray={`${2 * Math.PI * 100}`} strokeDashoffset={`${(1 - stepProgress) * 2 * Math.PI * 100}`} style={{ transition: "stroke-dashoffset 100ms linear", filter: "drop-shadow(0 0 12px rgba(255,193,7,0.6))" }} />
              </svg>
              <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 6 }}>
                <div style={{ fontFamily: "Orkun, serif", fontSize: 66, color: "#FFD700", textShadow: "0 0 24px rgba(255,215,0,0.7)", animation: playing ? "ri-breathe 3.6s ease-in-out infinite" : "none" }}>{steps[idx].glyph}</div>
                <div style={{ color: "rgba(255,193,7,0.7)", fontSize: 10, letterSpacing: "0.2em", textTransform: "uppercase" }}>Adım {idx + 1}/{steps.length}</div>
              </div>
            </div>
            <div style={{ textAlign: "center", maxWidth: 320 }}>
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 22, color: "#fff", letterSpacing: "0.14em", marginBottom: 10 }}>{steps[idx].title}</div>
              <div style={{ color: "rgba(224,224,224,0.88)", fontSize: 15, lineHeight: 1.7, fontStyle: "italic" }}>"{steps[idx].body}"</div>
            </div>

            {/* Drum waveform */}
            <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
              {[0,1,2,3,4,5,6,7,8,9,10].map(k => (
                <div key={k} style={{
                  width: 3, height: 8, borderRadius: 2,
                  background: playing ? "rgba(255,193,7,0.65)" : "rgba(255,255,255,0.18)",
                  animation: playing ? `ri-wave 1.4s ease-in-out ${k * 0.07}s infinite` : "none",
                }} />
              ))}
            </div>

            {/* Overall progress */}
            <div style={{ width: "100%", maxWidth: 280 }}>
              <div style={{ height: 4, background: "rgba(255,255,255,0.06)", borderRadius: 2, overflow: "hidden" }}>
                <div style={{ width: `${overallProgress * 100}%`, height: "100%", background: "linear-gradient(90deg, #C99411, #FFD700)", transition: "width 250ms ease", boxShadow: "0 0 8px rgba(255,193,7,0.5)" }} />
              </div>
            </div>

            <div style={{ display: "flex", gap: 12 }}>
              <button onClick={() => setPlaying(p => !p)} aria-label={playing ? "Duraklat" : "Devam"} style={{ width: 52, height: 52, borderRadius: 26, background: "rgba(255,193,7,0.15)", border: "1px solid rgba(255,193,7,0.45)", color: "#FFC107", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
                {playing ? (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>
                ) : (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><polygon points="6 4 20 12 6 20"/></svg>
                )}
              </button>
              <button onClick={reset} aria-label="Yeniden başla" style={{ width: 52, height: 52, borderRadius: 26, background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.12)", color: "rgba(255,255,255,0.7)", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 12a9 9 0 1 0 3-6.7L3 8"/><path d="M3 3v5h5"/></svg>
              </button>
            </div>
          </div>
        )}

        {stage === "done" && (
          <div style={{ minHeight: "100%", padding: "24px 28px 32px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 30, boxSizing: "border-box", animation: "ri-completefade 800ms ease both" }}>
            {/* Burst */}
            <div style={{ position: "relative", width: 220, height: 220 }}>
              {[...Array(12)].map((_, k) => {
                const a = (k / 12) * Math.PI * 2;
                return (
                  <div key={k} style={{
                    position: "absolute", top: "50%", left: "50%", width: 2, height: 90,
                    transform: `translate(-1px, -45px) rotate(${(a * 180) / Math.PI}deg) translateY(-50px)`,
                    background: "linear-gradient(180deg, transparent 0%, rgba(255,215,0,0.85) 50%, transparent 100%)",
                    transformOrigin: "center center",
                    animation: `ri-ray 2.4s ease-in-out ${k * 0.05}s infinite`,
                  }} />
                );
              })}
              <div style={{ position: "absolute", inset: 50, borderRadius: "50%", background: "radial-gradient(circle, rgba(255,215,0,0.5) 0%, rgba(255,215,0,0.1) 50%, transparent 80%)", animation: "ri-pulse 2s ease-in-out infinite" }} />
              <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Orkun, serif", fontSize: 78, color: "#FFD700", textShadow: "0 0 32px rgba(255,215,0,0.9)" }}>✦</div>
            </div>
            <div style={{ textAlign: "center", maxWidth: 320 }}>
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 28, color: "#FFD700", letterSpacing: "0.18em", marginBottom: 14, textShadow: "0 0 22px rgba(255,215,0,0.6)" }}>Arındın</div>
              <div style={{ color: "rgba(255,255,255,0.85)", fontSize: 15, lineHeight: 1.7, fontStyle: "italic" }}>
                Ruhun bir kabuğun kırılışını duydu. Bugünden sonra yeni bir niyet taşıyorsun. Tengri seninle.
              </div>
              <div style={{ marginTop: 18, display: "inline-flex", alignItems: "center", gap: 8, padding: "6px 14px", borderRadius: 14, background: "rgba(255,193,7,0.12)", border: "1px solid rgba(255,193,7,0.4)", color: "#FFC107", fontSize: 12, letterSpacing: "0.12em", textTransform: "uppercase", fontWeight: 600 }}>
                +50 Kader Puanı
              </div>
            </div>
            <div style={{ display: "flex", gap: 10, width: "100%", maxWidth: 320 }}>
              <button onClick={reset} style={{ flex: 1, height: 50, borderRadius: 12, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.3)", color: "rgba(255,215,0,0.85)", fontSize: 12, letterSpacing: "0.14em", textTransform: "uppercase", cursor: "pointer" }}>Yeniden</button>
              <button onClick={onBack} style={{ flex: 1, height: 50, borderRadius: 12, border: 0, background: "linear-gradient(180deg, #E5B225 0%, #C99411 100%)", color: "#0C0A18", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 12, letterSpacing: "0.16em", textTransform: "uppercase", cursor: "pointer", boxShadow: "0 8px 22px rgba(212,160,23,0.35)" }}>Ana Sayfaya Dön</button>
            </div>
          </div>
        )}
      </div>

      <style>{`
        @keyframes ri-spin { from { transform: rotate(0);} to { transform: rotate(360deg);} }
        @keyframes ri-pulse { 0%,100% { opacity: 0.7; transform: scale(1);} 50% { opacity: 1; transform: scale(1.08);} }
        @keyframes ri-breathe { 0%,100% { transform: scale(1);} 50% { transform: scale(1.06);} }
        @keyframes ri-wave { 0%,100% { transform: scaleY(1); opacity: 0.5;} 50% { transform: scaleY(5); opacity: 1;} }
        @keyframes ri-ray { 0%,100% { opacity: 0.3;} 50% { opacity: 1;} }
        @keyframes ri-completefade { from { opacity: 0; transform: scale(0.95);} to { opacity: 1; transform: scale(1);} }
      `}</style>
    </div>
  );
}

// ───────────────────────── LOADING / ERROR / EMPTY / DIALOG STATES ─────────────────────────
function StatesShowcase({ onBack }) {
  const [state, setState] = useES("loading"); // loading | error | empty | dialog | snackbar | sheet
  const opts = [
    { k: "loading", label: "Loading" },
    { k: "error", label: "Error" },
    { k: "empty", label: "Boş" },
    { k: "dialog", label: "Dialog" },
    { k: "snackbar", label: "SnackBar" },
    { k: "sheet", label: "BottomSheet" },
  ];

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/tengri.jpeg" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover", opacity: 0.22, mixBlendMode: "screen" }} />
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 30%, rgba(45,27,105,0.5) 0%, rgba(12,10,24,0.95) 65%, #0C0A18 100%)" }} />

      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 56, display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20 }}>
        <button onClick={onBack} style={{ width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{ flex: 1, textAlign: "center", color: "#fff", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "0.2em", fontSize: 14, textTransform: "uppercase", marginRight: 40 }}>States</div>
      </div>

      {/* Picker */}
      <div style={{ position: "absolute", top: 64, left: 12, right: 12, zIndex: 15, display: "flex", gap: 6, flexWrap: "wrap", padding: "6px", background: "rgba(0,0,0,0.4)", borderRadius: 14, backdropFilter: "blur(20px)", border: "1px solid rgba(255,255,255,0.08)" }}>
        {opts.map(o => {
          const on = state === o.k;
          return (
            <button key={o.k} onClick={() => setState(o.k)} style={{
              flex: 1, minWidth: 60, padding: "8px 6px", borderRadius: 9, border: 0,
              background: on ? "rgba(255,193,7,0.18)" : "rgba(255,255,255,0.04)",
              color: on ? "#FFC107" : "rgba(255,255,255,0.6)",
              fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 10,
              letterSpacing: "0.1em", textTransform: "uppercase", cursor: "pointer",
            }}>{o.label}</button>
          );
        })}
      </div>

      <div style={{ position: "absolute", inset: "128px 0 0", overflow: "hidden", display: "flex", alignItems: "center", justifyContent: "center" }}>
        {state === "loading" && (
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 22 }}>
            <div style={{ width: 80, height: 80, position: "relative" }}>
              <svg width="80" height="80" viewBox="0 0 80 80" style={{ animation: "ss-spin 1.2s linear infinite" }}>
                <circle cx="40" cy="40" r="34" fill="none" stroke="rgba(255,193,7,0.18)" strokeWidth="3" />
                <circle cx="40" cy="40" r="34" fill="none" stroke="#FFC107" strokeWidth="3" strokeLinecap="round" strokeDasharray="55 200" style={{ filter: "drop-shadow(0 0 8px rgba(255,193,7,0.6))" }} />
              </svg>
              <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Orkun, serif", fontSize: 26, color: "#FFC107", animation: "ss-pulse 1.8s ease-in-out infinite" }}>𐰚</div>
            </div>
            <div style={{ color: "rgba(255,193,7,0.8)", fontSize: 13, fontStyle: "italic", textShadow: "0 0 12px rgba(0,0,0,0.9)" }}>
              Ata ruhları seni dinliyor…
            </div>
          </div>
        )}

        {state === "error" && (
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 16, padding: 32, textAlign: "center", maxWidth: 320 }}>
            <div style={{ width: 80, height: 80, borderRadius: 40, background: "rgba(244,67,54,0.15)", border: "1.5px solid rgba(244,67,54,0.5)", display: "flex", alignItems: "center", justifyContent: "center", color: "#F87171" }}>
              <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            </div>
            <div>
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 18, color: "#fff", letterSpacing: "0.12em", marginBottom: 6 }}>Bir şey ters gitti</div>
              <div style={{ color: "rgba(255,255,255,0.65)", fontSize: 13, lineHeight: 1.6 }}>Yorum alınırken bir sorun oluştu. Lütfen internet bağlantınızı kontrol edin.</div>
            </div>
            <button style={{ marginTop: 8, height: 46, padding: "0 26px", borderRadius: 12, border: 0, background: "linear-gradient(180deg, #E5B225 0%, #C99411 100%)", color: "#0C0A18", fontWeight: 700, fontSize: 12, letterSpacing: "0.16em", textTransform: "uppercase", cursor: "pointer", boxShadow: "0 6px 18px rgba(212,160,23,0.35)" }}>Tekrar Dene</button>
          </div>
        )}

        {state === "empty" && (
          <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 16, padding: 32, textAlign: "center", maxWidth: 320 }}>
            <div style={{ position: "relative", width: 120, height: 120 }}>
              <div style={{ position: "absolute", inset: 0, borderRadius: "50%", background: "radial-gradient(circle, rgba(255,193,7,0.15) 0%, transparent 70%)" }} />
              <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Orkun, serif", fontSize: 60, color: "rgba(255,193,7,0.55)", textShadow: "0 0 18px rgba(255,193,7,0.4)" }}>𐰋</div>
            </div>
            <div>
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 18, color: "#fff", letterSpacing: "0.12em", marginBottom: 6 }}>Henüz Fal Çekmedin</div>
              <div style={{ color: "rgba(255,255,255,0.55)", fontSize: 13, lineHeight: 1.6 }}>Zarları ata, kartları çek — kadim yolculuğun burada başlıyor.</div>
            </div>
            <button style={{ marginTop: 8, height: 46, padding: "0 22px", borderRadius: 12, background: "rgba(255,193,7,0.12)", border: "1px solid rgba(255,193,7,0.4)", color: "#FFC107", fontWeight: 600, fontSize: 12, letterSpacing: "0.14em", textTransform: "uppercase", cursor: "pointer" }}>İlk Falımı Çek</button>
          </div>
        )}

        {state === "dialog" && (
          <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.65)", display: "flex", alignItems: "center", justifyContent: "center", padding: 20, backdropFilter: "blur(6px)" }}>
            <div style={{
              width: "100%", maxWidth: 320, background: "rgba(20,18,38,0.95)", backdropFilter: "blur(30px)",
              border: "1px solid rgba(255,193,7,0.4)", borderRadius: 20, padding: 24, textAlign: "center",
              boxShadow: "0 30px 60px rgba(0,0,0,0.6), 0 0 32px rgba(255,193,7,0.2)",
              animation: "ss-dialogin 350ms cubic-bezier(0.34,1.56,0.64,1) both",
            }}>
              <div style={{ width: 56, height: 56, borderRadius: 28, background: "rgba(244,67,54,0.15)", border: "1px solid rgba(244,67,54,0.45)", display: "inline-flex", alignItems: "center", justifyContent: "center", color: "#F87171", marginBottom: 14 }}>
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
              </div>
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 17, color: "#FFC107", letterSpacing: "0.12em", marginBottom: 8 }}>Geçmişi Temizle?</div>
              <div style={{ color: "rgba(255,255,255,0.7)", fontSize: 13, lineHeight: 1.6, marginBottom: 18 }}>
                Tüm kayıtlı falları kalıcı olarak silmek istediğinden emin misin? Bu işlem geri alınamaz.
              </div>
              <div style={{ display: "flex", gap: 10 }}>
                <button style={{ flex: 1, height: 44, borderRadius: 11, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.12)", color: "#fff", fontSize: 12, letterSpacing: "0.14em", textTransform: "uppercase", cursor: "pointer" }}>İptal</button>
                <button style={{ flex: 1, height: 44, borderRadius: 11, border: 0, background: "linear-gradient(180deg, #EF4444, #B91C1C)", color: "#fff", fontWeight: 700, fontSize: 12, letterSpacing: "0.14em", textTransform: "uppercase", cursor: "pointer", boxShadow: "0 6px 16px rgba(244,67,54,0.4)" }}>Sil</button>
              </div>
            </div>
          </div>
        )}

        {state === "snackbar" && (
          <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "flex-end", justifyContent: "center", padding: "0 16px 40px" }}>
            <div style={{
              width: "100%", maxWidth: 340, padding: "14px 18px",
              background: "rgba(20,18,38,0.92)", backdropFilter: "blur(20px)",
              border: "1px solid rgba(255,193,7,0.5)", borderRadius: 14,
              boxShadow: "0 16px 36px rgba(0,0,0,0.55), 0 0 22px rgba(255,193,7,0.2)",
              display: "flex", alignItems: "center", gap: 12,
              animation: "ss-snackin 450ms cubic-bezier(0.16,1,0.3,1) both",
            }}>
              <div style={{ width: 32, height: 32, borderRadius: 9, background: "rgba(76,175,80,0.18)", border: "1px solid rgba(76,175,80,0.5)", color: "#86EFAC", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
              </div>
              <div style={{ flex: 1, color: "#fff", fontSize: 13 }}>
                Fal günlüğüne kaydedildi.
                <div style={{ fontSize: 11, color: "rgba(255,255,255,0.55)", marginTop: 1 }}>+15 Kader Puanı</div>
              </div>
              <button style={{ background: "transparent", border: 0, color: "#FFC107", fontSize: 12, letterSpacing: "0.1em", textTransform: "uppercase", fontWeight: 700, cursor: "pointer" }}>Aç</button>
            </div>
          </div>
        )}

        {state === "sheet" && (
          <div style={{ position: "absolute", inset: 0, background: "rgba(0,0,0,0.55)" }}>
            <div style={{
              position: "absolute", left: 0, right: 0, bottom: 0,
              background: "rgba(20,18,38,0.95)", backdropFilter: "blur(30px)",
              borderTop: "1px solid rgba(255,193,7,0.4)",
              borderTopLeftRadius: 24, borderTopRightRadius: 24,
              padding: "16px 20px 28px",
              boxShadow: "0 -20px 50px rgba(0,0,0,0.5), 0 0 32px rgba(255,193,7,0.15)",
              animation: "ss-sheetin 500ms cubic-bezier(0.16,1,0.3,1) both",
            }}>
              <div style={{ width: 40, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.2)", margin: "0 auto 16px" }} />
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 16, color: "#FFC107", letterSpacing: "0.14em", marginBottom: 6, textTransform: "uppercase" }}>Falı Paylaş</div>
              <div style={{ color: "rgba(255,255,255,0.6)", fontSize: 12, marginBottom: 18 }}>Kadim sözü dostlarınla paylaş</div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
                {[
                  { l: "Kopyala", g: "📋" },
                  { l: "WhatsApp", g: "💬" },
                  { l: "Twitter", g: "𝕏" },
                  { l: "Instagram", g: "◉" },
                  { l: "Mail", g: "✉" },
                  { l: "Daha…", g: "•••" },
                ].map((o, k) => (
                  <button key={k} style={{ padding: "16px 8px", borderRadius: 12, background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)", color: "#fff", cursor: "pointer", display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
                    <div style={{ fontSize: 22 }}>{o.g}</div>
                    <div style={{ fontSize: 11, color: "rgba(255,255,255,0.75)" }}>{o.l}</div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>

      <style>{`
        @keyframes ss-spin { from { transform: rotate(0);} to { transform: rotate(360deg);} }
        @keyframes ss-pulse { 0%,100% { opacity: 0.7;} 50% { opacity: 1;} }
        @keyframes ss-dialogin { from { opacity: 0; transform: scale(0.85);} to { opacity: 1; transform: scale(1);} }
        @keyframes ss-snackin { from { opacity: 0; transform: translateY(40px);} to { opacity: 1; transform: translateY(0);} }
        @keyframes ss-sheetin { from { transform: translateY(100%);} to { transform: translateY(0);} }
      `}</style>
    </div>
  );
}

Object.assign(window, { RituelScreen, StatesShowcase });
