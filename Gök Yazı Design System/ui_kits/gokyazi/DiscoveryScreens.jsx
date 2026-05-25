/* global React */
const { useState: useTarotState, useEffect: useTarotEffect } = React;

// ───────────────────────── TÜRK TAROTU ─────────────────────────
function TarotScreen({ onBack }) {
  const [stage, setStage] = useTarotState("intent"); // intent | spreadPick | drawing | result
  const [spread, setSpread] = useTarotState(null);   // 1 | 3
  const [niyet, setNiyet] = useTarotState("");
  const [browseIdx, setBrowseIdx] = useTarotState(0);
  const [flipped, setFlipped] = useTarotState([]);   // booleans per drawn card
  const [tabAi, setTabAi] = useTarotState("anlam");  // anlam | ai
  const [entered, setEntered] = useTarotState(false);
  useTarotEffect(() => { const t = setTimeout(() => setEntered(true), 60); return () => clearTimeout(t); }, []);

  // 22 cards — Turkic-mythology themed major arcana
  const deck = [
    { n: 0, ad: "Yolçı", mean: "Yeni bir yolculuğun başı. Cesur ol; bilinmeyen bilgedir." },
    { n: 1, ad: "Kam", mean: "İçindeki şifacıya ses ver. Bilgi yolla geliyor." },
    { n: 2, ad: "Ak Ana", mean: "Bilgelik tanrıçası. Sezgilerine güven." },
    { n: 3, ad: "Yer Ana", mean: "Bereket ve büyüme; hasat zamanı." },
    { n: 4, ad: "Han", mean: "Yapısal güç, otorite ve düzen." },
    { n: 5, ad: "Töre", mean: "Geleneğin yolu; eski bilgiye dön." },
    { n: 6, ad: "Sevdalı", mean: "Bağ kuran ruhlar; bir seçim eşikte." },
    { n: 7, ad: "Bozkurt", mean: "Yol gösterici; sezgisel rota değişimi." },
    { n: 8, ad: "Kuvvet", mean: "İçten gelen güç, sabırla zafere." },
    { n: 9, ad: "Münzevi", mean: "Sessizliğin sesini dinle." },
    { n: 10, ad: "Yazgı Çarkı", mean: "Döngü dönüyor; hazırlıklı ol." },
    { n: 11, ad: "Adalet", mean: "Terazi denge istiyor; doğruyu söyle." },
    { n: 12, ad: "Asılı Kişi", mean: "Bakış açısını değiştir, çözüm orada." },
    { n: 13, ad: "Erlik Han", mean: "Bir döngünün sonu; dönüşüm zamanı." },
    { n: 14, ad: "Ölçü", mean: "Aşırılıkları yumuşat; karışım gerek." },
    { n: 15, ad: "Çor", mean: "Bağımlılık ve gölge; yüzleş." },
    { n: 16, ad: "Yıkım", mean: "Yapı sarsılıyor; özün açığa çıkıyor." },
    { n: 17, ad: "Yıldız", mean: "Umut, ilham ve şifa." },
    { n: 18, ad: "Ay", mean: "Belirsizlik; rüyalara kulak ver." },
    { n: 19, ad: "Güneş", mean: "Sevinç, başarı, açıklık." },
    { n: 20, ad: "Uyanış", mean: "Geçmişi affet, yeniden doğ." },
    { n: 21, ad: "Tengri'nin Yolu", mean: "Tamamlanma; kozmik bütünlük." },
  ];

  const startDraw = () => {
    if (!niyet.trim() || !spread) return;
    const need = spread === 1 ? 1 : 3;
    setFlipped(Array(need).fill(false));
    setStage("drawing");
  };
  const flip = (i) => setFlipped(f => f.map((v, k) => k === i ? true : v));
  const allFlipped = flipped.length > 0 && flipped.every(Boolean);
  useTarotEffect(() => { if (allFlipped) setTimeout(() => setStage("result"), 600); }, [allFlipped]);

  // Sample drawn cards (deterministic from niyet length to keep stable)
  const drawnCards = (() => {
    if (!spread) return [];
    const seed = niyet.length % deck.length;
    if (spread === 1) return [deck[(seed * 7) % deck.length]];
    return [deck[(seed * 3) % deck.length], deck[(seed * 5 + 4) % deck.length], deck[(seed * 11 + 7) % deck.length]];
  })();
  const labels = spread === 3 ? ["Geçmiş", "Şimdi", "Gelecek"] : ["Yol"];

  const reset = () => { setStage("intent"); setSpread(null); setNiyet(""); setFlipped([]); };

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/tarot_arkayuz.png" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover", opacity: 0.18, filter: "blur(2px)" }} />
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 30%, rgba(157,23,77,0.4) 0%, rgba(76,29,110,0.5) 35%, rgba(12,10,24,0.95) 75%, #0C0A18 100%)" }} />

      {/* App bar */}
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 56, display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20 }}>
        <button onClick={onBack} aria-label="Geri" style={{ width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{ flex: 1, textAlign: "center", color: "#fff", fontFamily: "Orkun, serif", fontSize: 26, letterSpacing: 1.5, textShadow: "0 0 16px rgba(244,114,182,0.5), 0 2px 6px rgba(0,0,0,0.9)", marginRight: 40 }}>𐱅𐰸𐰺𐰆𐱃</div>
      </div>

      <div style={{ position: "absolute", inset: "56px 0 0", overflow: "auto" }}>
        {stage === "intent" && (
          <div style={{ padding: "32px 28px 40px", display: "flex", flexDirection: "column", gap: 24, alignItems: "center", minHeight: "100%", boxSizing: "border-box",
            opacity: entered ? 1 : 0, transition: "opacity 700ms ease" }}>
            <div style={{ color: "rgba(224,224,224,0.85)", fontSize: 13, letterSpacing: "0.16em", textTransform: "uppercase", textAlign: "center", maxWidth: 280, lineHeight: 1.5, textShadow: "0 0 12px rgba(0,0,0,0.9)" }}>
              Niyetini belirle · Kartları çek
            </div>
            <div style={{ width: 200, height: 240, position: "relative", perspective: 800 }}>
              <div style={{ position: "absolute", inset: -30, borderRadius: 30, background: "radial-gradient(ellipse, rgba(244,114,182,0.25) 0%, transparent 70%)", animation: "tr-glow 3s ease-in-out infinite" }} />
              {[2,1,0].map(k => (
                <div key={k} style={{
                  position: "absolute", top: 0, left: "50%", marginLeft: -70,
                  width: 140, height: 220, borderRadius: 12, overflow: "hidden",
                  background: "#0C0A18", border: "1.5px solid rgba(255,193,7,0.5)",
                  transform: `translateX(${(k - 1) * 22}px) rotate(${(k - 1) * 6}deg)`,
                  boxShadow: "0 20px 40px rgba(0,0,0,0.55), 0 0 20px rgba(244,114,182,0.25)",
                  zIndex: 3 - k,
                }}>
                  <img src="../../assets/tarot_arkayuz.png" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                </div>
              ))}
            </div>

            {/* Spread picker */}
            <div style={{ width: "100%", maxWidth: 380 }}>
              <label style={{ display: "block", color: "rgba(255,255,255,0.55)", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 10, marginLeft: 4 }}>Açılım Seç</label>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10 }}>
                {[{ n: 1, label: "Tek Kart", sub: "Hızlı yanıt" }, { n: 3, label: "Üç Kart", sub: "Geçmiş · Şimdi · Gelecek" }].map(opt => {
                  const on = spread === opt.n;
                  return (
                    <button key={opt.n} onClick={() => setSpread(opt.n)} style={{
                      padding: "16px 14px", borderRadius: 14, cursor: "pointer",
                      background: on ? "rgba(244,114,182,0.15)" : "rgba(255,255,255,0.04)",
                      border: `1px solid ${on ? "rgba(244,114,182,0.6)" : "rgba(255,255,255,0.1)"}`,
                      color: "#fff", textAlign: "left", transition: "all 200ms",
                    }}>
                      <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 14, letterSpacing: "0.12em", color: on ? "#F472B6" : "#fff" }}>{opt.label}</div>
                      <div style={{ fontSize: 11, color: "rgba(255,255,255,0.6)", marginTop: 4 }}>{opt.sub}</div>
                    </button>
                  );
                })}
              </div>
            </div>

            <div style={{ width: "100%", maxWidth: 380 }}>
              <label style={{ display: "block", color: "rgba(255,255,255,0.55)", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 8, marginLeft: 4 }}>Niyetin</label>
              <textarea value={niyet} onChange={e => setNiyet(e.target.value)} placeholder="Sorunu veya niyetini yaz…" rows={2} style={{
                width: "100%", background: "rgba(12,10,24,0.6)", backdropFilter: "blur(20px)",
                border: "1px solid rgba(255,215,0,0.2)", borderRadius: 14, padding: 14,
                color: "#fff", fontSize: 14, lineHeight: 1.6, outline: "none", resize: "none", boxSizing: "border-box", fontFamily: "inherit",
              }} />
            </div>

            <button onClick={startDraw} disabled={!niyet.trim() || !spread} style={{
              width: "100%", maxWidth: 380, height: 56, borderRadius: 14, border: 0,
              background: (niyet.trim() && spread) ? "linear-gradient(180deg, #E5B225 0%, #C99411 100%)" : "rgba(212,160,23,0.35)",
              color: "#0C0A18", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 16,
              letterSpacing: "0.18em", textTransform: "uppercase", cursor: (niyet.trim() && spread) ? "pointer" : "not-allowed",
              boxShadow: (niyet.trim() && spread) ? "0 8px 24px rgba(212,160,23,0.35), inset 0 1px 0 rgba(255,255,255,0.4)" : "none",
            }}>Kartları Çek</button>
          </div>
        )}

        {stage === "drawing" && (
          <div style={{ minHeight: "100%", padding: "24px 20px 40px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", gap: 28, boxSizing: "border-box" }}>
            <div style={{ color: "rgba(244,114,182,0.85)", fontSize: 13, letterSpacing: "0.16em", textTransform: "uppercase", textAlign: "center", fontStyle: "italic", textShadow: "0 0 12px rgba(0,0,0,0.9)" }}>
              Kartların sırrını çözmek için üzerlerine dokun
            </div>
            <div style={{ display: "flex", gap: spread === 3 ? 8 : 0, justifyContent: "center", flexWrap: "wrap", maxWidth: "100%" }}>
              {flipped.map((isFlipped, i) => (
                <TarotFlipCard key={i} flipped={isFlipped} onClick={() => !isFlipped && flip(i)} card={drawnCards[i]} label={labels[i]} />
              ))}
            </div>
          </div>
        )}

        {stage === "result" && (
          <div style={{ padding: "20px 20px 32px", display: "flex", flexDirection: "column", gap: 18 }}>
            <div style={{ textAlign: "center", color: "rgba(224,224,224,0.7)", fontSize: 13, fontStyle: "italic", padding: "0 12px", lineHeight: 1.6 }}>
              Sorduğun: <span style={{ color: "rgba(244,114,182,0.9)" }}>“{niyet}”</span>
            </div>
            <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap" }}>
              {drawnCards.map((c, i) => (
                <div key={i} style={{ textAlign: "center" }}>
                  <div style={{
                    width: spread === 3 ? 90 : 130, height: spread === 3 ? 140 : 200, borderRadius: 10,
                    background: "linear-gradient(155deg, #4C1D6E 0%, #1E1B4B 60%, #0C0A18 100%)",
                    border: "1.5px solid rgba(244,114,182,0.6)",
                    boxShadow: "0 14px 30px rgba(0,0,0,0.55), 0 0 18px rgba(244,114,182,0.3)",
                    display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "space-between",
                    padding: 8, position: "relative", overflow: "hidden",
                  }}>
                    <div style={{ fontFamily: "Orkun, serif", fontSize: spread === 3 ? 20 : 28, color: "#FFD56B", textShadow: "0 0 12px rgba(255,193,7,0.7)" }}>𐰚𐰢</div>
                    <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: spread === 3 ? 11 : 14, color: "#fff", textAlign: "center", lineHeight: 1.2, letterSpacing: "0.08em" }}>{c.ad}</div>
                    <div style={{ fontSize: 9, color: "rgba(244,114,182,0.7)", letterSpacing: "0.15em" }}>{c.n}</div>
                  </div>
                  <div style={{ marginTop: 6, color: "#F472B6", fontSize: 10, letterSpacing: "0.18em", textTransform: "uppercase", fontWeight: 600 }}>{labels[i]}</div>
                </div>
              ))}
            </div>

            <div style={{ display: "flex", gap: 6 }}>
              {[["anlam","Kart Anlamı"], ["ai","AI Yorum ✦"]].map(([k, label]) => {
                const on = tabAi === k; const ai = k === "ai";
                return (
                  <button key={k} onClick={() => setTabAi(k)} style={{
                    flex: 1, padding: "10px 12px", borderRadius: 12,
                    background: on ? (ai ? "rgba(77,208,225,0.18)" : "rgba(244,114,182,0.18)") : "rgba(255,255,255,0.05)",
                    border: `1px solid ${on ? (ai ? "rgba(77,208,225,0.6)" : "rgba(244,114,182,0.5)") : "rgba(255,255,255,0.1)"}`,
                    color: on ? (ai ? "#4DD0E1" : "#F472B6") : "rgba(255,255,255,0.65)",
                    fontSize: 12, fontWeight: 600, letterSpacing: "0.06em", cursor: "pointer",
                  }}>{label}</button>
                );
              })}
            </div>

            <div style={{
              background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)",
              border: "1px solid rgba(244,114,182,0.25)", borderRadius: 18, padding: 22,
            }}>
              {tabAi === "anlam" ? (
                <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
                  {drawnCards.map((c, i) => (
                    <div key={i}>
                      <div style={{ color: "#F472B6", fontSize: 12, fontWeight: 700, letterSpacing: "0.14em", textTransform: "uppercase", marginBottom: 4 }}>
                        {labels[i]} · {c.ad}
                      </div>
                      <div style={{ color: "#fff", fontSize: 14, lineHeight: 1.6 }}>{c.mean}</div>
                    </div>
                  ))}
                </div>
              ) : (
                <div>
                  <div style={{ color: "#4DD0E1", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 10, fontWeight: 600 }}>Göklerin Yorumu</div>
                  <div style={{ color: "#fff", fontSize: 14, lineHeight: 1.7 }}>
                    {spread === 1
                      ? `“${drawnCards[0].ad}” seninle konuşuyor. Niyetin etrafında çevresel bir hareket var; içinde duyduğun sesi izle.`
                      : `Geçmişin “${drawnCards[0].ad}”, şimdiyi “${drawnCards[1].ad}” ile yoğurmuş. Gelecek “${drawnCards[2].ad}” açılımıyla seni çağırıyor — küçük bir karar büyük bir kapıyı aralayacak.`}
                  </div>
                </div>
              )}
            </div>

            <div style={{ display: "flex", gap: 10 }}>
              <button style={{
                flex: 1, height: 50, borderRadius: 14,
                background: "rgba(255,255,255,0.05)", border: "1px solid rgba(244,114,182,0.4)",
                color: "#F472B6", fontWeight: 600, fontSize: 12, letterSpacing: "0.14em", textTransform: "uppercase", cursor: "pointer",
              }}>Günlüğe Kaydet</button>
              <button onClick={reset} style={{
                flex: 1, height: 50, borderRadius: 14, border: 0,
                background: "linear-gradient(180deg, #E5B225 0%, #C99411 100%)",
                color: "#0C0A18", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 12,
                letterSpacing: "0.16em", textTransform: "uppercase", cursor: "pointer",
                boxShadow: "0 8px 22px rgba(212,160,23,0.35)",
              }}>Yeni Açılım</button>
            </div>
          </div>
        )}
      </div>

      <style>{`@keyframes tr-glow { 0%,100% { opacity: 0.55;} 50% { opacity: 1;} }`}</style>
    </div>
  );
}

function TarotFlipCard({ flipped, onClick, card, label }) {
  return (
    <div style={{ perspective: 1000, padding: "0 4px", textAlign: "center" }}>
      <button onClick={onClick} style={{
        width: 130, height: 200, position: "relative", transformStyle: "preserve-3d",
        transform: `rotateY(${flipped ? 180 : 0}deg)`,
        transition: "transform 600ms cubic-bezier(0.4, 0.0, 0.2, 1)",
        background: "transparent", border: 0, padding: 0, cursor: flipped ? "default" : "pointer",
      }}>
        {/* Back */}
        <div style={{ position: "absolute", inset: 0, backfaceVisibility: "hidden", WebkitBackfaceVisibility: "hidden", borderRadius: 12, overflow: "hidden", border: "1.5px solid rgba(255,193,7,0.5)", boxShadow: "0 16px 32px rgba(0,0,0,0.55), 0 0 22px rgba(244,114,182,0.25)" }}>
          <img src="../../assets/tarot_arkayuz.png" style={{ width: "100%", height: "100%", objectFit: "cover" }} />
        </div>
        {/* Front */}
        <div style={{
          position: "absolute", inset: 0, backfaceVisibility: "hidden", WebkitBackfaceVisibility: "hidden",
          transform: "rotateY(180deg)",
          borderRadius: 12, padding: 10, boxSizing: "border-box",
          background: "linear-gradient(155deg, #4C1D6E 0%, #1E1B4B 60%, #0C0A18 100%)",
          border: "1.5px solid rgba(244,114,182,0.6)",
          boxShadow: "0 16px 32px rgba(0,0,0,0.55), 0 0 28px rgba(244,114,182,0.45)",
          display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "space-between",
        }}>
          <div style={{ fontFamily: "Orkun, serif", fontSize: 24, color: "#FFD56B", textShadow: "0 0 12px rgba(255,193,7,0.7)" }}>𐰚𐰢</div>
          <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 13, color: "#fff", textAlign: "center", lineHeight: 1.2, letterSpacing: "0.08em" }}>{card.ad}</div>
          <div style={{ fontSize: 9, color: "rgba(244,114,182,0.7)", letterSpacing: "0.15em" }}>{card.n}</div>
        </div>
      </button>
      <div style={{ marginTop: 6, color: "rgba(244,114,182,0.8)", fontSize: 10, letterSpacing: "0.18em", textTransform: "uppercase", fontWeight: 600 }}>{label}</div>
    </div>
  );
}

// ───────────────────────── 12 HAYVAN TAKVİMİ ─────────────────────────
function TakvimScreen({ onBack }) {
  const animals = [
    { k: "sican", label: "Sıçan", traits: "Zeki, hızlı düşünen, sezgisel", lucky: ["Su", "Kuzey", "Gümüş"] },
    { k: "ud", label: "Ud (Öküz)", traits: "Sabırlı, kararlı, çalışkan", lucky: ["Toprak", "Doğu", "Altın"] },
    { k: "bars", label: "Bars (Pars)", traits: "Cesur, lider ruhlu, hızlı", lucky: ["Ateş", "Güney", "Bakır"] },
    { k: "tavsan", label: "Tavşan", traits: "Nazik, duyarlı, sanatkâr", lucky: ["Ay", "Batı", "Yeşim"] },
    { k: "luu", label: "Luu (Ejder)", traits: "Karizmatik, vizyoner, güçlü", lucky: ["Hava", "Merkez", "Mercan"] },
    { k: "yilan", label: "Yılan", traits: "Bilge, mistik, derin", lucky: ["Su", "Güney", "Yeşil"] },
    { k: "at", label: "At", traits: "Özgür, tutkulu, hareketli", lucky: ["Ateş", "Güney", "Kızıl"] },
    { k: "koyun", label: "Koyun", traits: "Şefkatli, uyumlu, yaratıcı", lucky: ["Toprak", "Batı", "Mavi"] },
    { k: "bicin", label: "Biçin (Maymun)", traits: "Esprili, çevik, akıllı", lucky: ["Metal", "Kuzey", "Sarı"] },
    { k: "takagu", label: "Takagu (Tavuk)", traits: "Disiplinli, dürüst, dakik", lucky: ["Hava", "Doğu", "Beyaz"] },
    { k: "it", label: "It (Köpek)", traits: "Sadık, koruyucu, dürüst", lucky: ["Toprak", "Kuzey", "Kahve"] },
    { k: "tonguz", label: "Tonguz (Domuz)", traits: "Cömert, dürüst, samimi", lucky: ["Su", "Batı", "Pembe"] },
  ];

  const [stage, setStage] = useTarotState("pick"); // pick | result
  const [year, setYear] = useTarotState(1995);
  const [showAi, setShowAi] = useTarotState(false);

  const idx = (year - 1924) % 12; // 1924 = Sıçan
  const animal = animals[(idx + 12) % 12];
  const mucelAge = ((new Date().getFullYear() - year) % 12);
  const mucelDonem = mucelAge < 4 ? "1. Müçel" : mucelAge < 8 ? "2. Müçel" : "3. Müçel";

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/bg_takvim.jpeg" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover", opacity: 0.4 }} />
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 30%, rgba(30,58,138,0.5) 0%, rgba(12,10,24,0.95) 65%, #0C0A18 100%)" }} />

      {/* App bar */}
      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 56, display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20 }}>
        <button onClick={onBack} style={{ width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{ flex: 1, textAlign: "center", color: "#fff", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "0.2em", fontSize: 14, textTransform: "uppercase", marginRight: 40 }}>12 Hayvanlı Takvim</div>
      </div>

      <div style={{ position: "absolute", inset: "56px 0 0", overflow: "auto" }}>
        {stage === "pick" && (
          <div style={{ padding: "24px 20px 32px", display: "flex", flexDirection: "column", gap: 22 }}>
            {/* Animated zodiac wheel */}
            <div style={{ position: "relative", height: 220, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <div style={{ position: "absolute", inset: 0, animation: "tk-wheel 60s linear infinite" }}>
                {animals.map((a, i) => {
                  const angle = (i / 12) * Math.PI * 2;
                  const r = 96;
                  const x = Math.cos(angle - Math.PI / 2) * r;
                  const y = Math.sin(angle - Math.PI / 2) * r;
                  return (
                    <img key={a.k} src={`../../assets/animal_${a.k}.png`} alt={a.label} style={{
                      position: "absolute", top: "50%", left: "50%",
                      width: 44, height: 44, objectFit: "contain",
                      transform: `translate(${x - 22}px, ${y - 22}px)`,
                      filter: "drop-shadow(0 4px 10px rgba(0,0,0,0.6))",
                      opacity: 0.92,
                    }} />
                  );
                })}
              </div>
              <div style={{ width: 80, height: 80, borderRadius: "50%", background: "radial-gradient(circle, rgba(96,165,250,0.4) 0%, transparent 70%)", display: "flex", alignItems: "center", justifyContent: "center", fontFamily: "Orkun, serif", fontSize: 36, color: "#60A5FA", textShadow: "0 0 18px rgba(96,165,250,0.7)" }}>𐰚</div>
            </div>

            <div style={{ textAlign: "center", color: "rgba(224,224,224,0.85)", fontSize: 13, letterSpacing: "0.14em", textTransform: "uppercase", lineHeight: 1.6 }}>
              Doğum yılını gir<br/>Yıl hayvanını keşfet
            </div>

            {/* Year picker */}
            <div style={{ background: "rgba(12,10,24,0.65)", backdropFilter: "blur(20px)", border: "1px solid rgba(96,165,250,0.3)", borderRadius: 18, padding: 22 }}>
              <div style={{ color: "rgba(255,255,255,0.55)", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 12, textAlign: "center" }}>Doğum Yılın</div>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 14 }}>
                <button onClick={() => setYear(y => Math.max(1900, y - 1))} style={{ width: 42, height: 42, borderRadius: 21, background: "rgba(96,165,250,0.15)", border: "1px solid rgba(96,165,250,0.4)", color: "#60A5FA", fontSize: 22, cursor: "pointer" }}>−</button>
                <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 38, color: "#fff", letterSpacing: "0.1em", minWidth: 130, textAlign: "center" }}>{year}</div>
                <button onClick={() => setYear(y => Math.min(new Date().getFullYear(), y + 1))} style={{ width: 42, height: 42, borderRadius: 21, background: "rgba(96,165,250,0.15)", border: "1px solid rgba(96,165,250,0.4)", color: "#60A5FA", fontSize: 22, cursor: "pointer" }}>+</button>
              </div>
              <div style={{ marginTop: 14, display: "flex", justifyContent: "center", gap: 6 }}>
                {[1980, 1990, 2000, 2010].map(q => (
                  <button key={q} onClick={() => setYear(q)} style={{ padding: "5px 11px", borderRadius: 12, fontSize: 11, background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.1)", color: "rgba(255,255,255,0.65)", cursor: "pointer" }}>{q}</button>
                ))}
              </div>
            </div>

            <button onClick={() => setStage("result")} style={{
              width: "100%", height: 56, borderRadius: 14, border: 0,
              background: "linear-gradient(180deg, #E5B225 0%, #C99411 100%)",
              color: "#0C0A18", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 16,
              letterSpacing: "0.18em", textTransform: "uppercase", cursor: "pointer",
              boxShadow: "0 8px 24px rgba(212,160,23,0.35)",
            }}>Hayvanımı Bul</button>
          </div>
        )}

        {stage === "result" && (
          <div style={{ padding: "16px 20px 32px", display: "flex", flexDirection: "column", gap: 16 }}>
            {/* Hero animal */}
            <div style={{ position: "relative", height: 240, display: "flex", alignItems: "center", justifyContent: "center" }}>
              <div style={{ position: "absolute", inset: -20, background: "radial-gradient(circle, rgba(96,165,250,0.3) 0%, transparent 65%)", filter: "blur(8px)", animation: "tk-pulse 3s ease-in-out infinite" }} />
              <img src={`../../assets/animal_${animal.k}.png`} alt={animal.label} style={{ width: 220, height: 220, objectFit: "contain", filter: "drop-shadow(0 12px 30px rgba(0,0,0,0.7))" }} />
            </div>

            <div style={{ textAlign: "center" }}>
              <div style={{ color: "#60A5FA", fontSize: 11, letterSpacing: "0.18em", textTransform: "uppercase", fontWeight: 600, marginBottom: 6 }}>{year} Yılı · {mucelDonem}</div>
              <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 30, color: "#fff", letterSpacing: "0.12em", textShadow: "0 0 18px rgba(96,165,250,0.5)" }}>{animal.label.toUpperCase()}</div>
            </div>

            <div style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: "1px solid rgba(96,165,250,0.25)", borderRadius: 16, padding: 18 }}>
              <div style={{ color: "#FFE082", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", fontWeight: 600, marginBottom: 8 }}>Kişilik</div>
              <div style={{ color: "#fff", fontSize: 14, lineHeight: 1.7 }}>{animal.traits}.</div>
            </div>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 10 }}>
              {[["Element", animal.lucky[0]], ["Yön", animal.lucky[1]], ["Renk", animal.lucky[2]]].map(([k, v]) => (
                <div key={k} style={{ background: "rgba(96,165,250,0.08)", border: "1px solid rgba(96,165,250,0.2)", borderRadius: 12, padding: "12px 10px", textAlign: "center" }}>
                  <div style={{ color: "rgba(255,255,255,0.5)", fontSize: 10, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 4 }}>{k}</div>
                  <div style={{ color: "#60A5FA", fontSize: 13, fontWeight: 600 }}>{v}</div>
                </div>
              ))}
            </div>

            <button onClick={() => setShowAi(s => !s)} style={{
              height: 50, borderRadius: 14, cursor: "pointer",
              background: showAi ? "rgba(77,208,225,0.18)" : "rgba(77,208,225,0.08)",
              border: `1px solid ${showAi ? "rgba(77,208,225,0.6)" : "rgba(77,208,225,0.3)"}`,
              color: "#4DD0E1", fontWeight: 600, fontSize: 13, letterSpacing: "0.14em", textTransform: "uppercase",
              display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
            }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#4DD0E1" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 3v18M3 12h18"/></svg>
              {showAi ? "Yıllık Yorum Açık" : "Yıllık AI Yorumu Al"}
            </button>

            {showAi && (
              <div style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: "1px solid rgba(77,208,225,0.4)", borderRadius: 16, padding: 18 }}>
                <div style={{ color: "#4DD0E1", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", fontWeight: 600, marginBottom: 8 }}>{new Date().getFullYear()} · Sana Özel</div>
                <div style={{ color: "#fff", fontSize: 14, lineHeight: 1.7 }}>{animal.label} yılında doğanlar bu yıl bir geçiş eşiğinde. Müçelin {mucelDonem.toLowerCase()} olduğundan, geçen 12 yılın tortusunu bırakman ve yeni bir kabuk takman zamanı. Bahar aylarında bir karar, sonbaharda bir yolculuk işaret veriyor.</div>
              </div>
            )}

            <button onClick={() => { setStage("pick"); setShowAi(false); }} style={{
              height: 48, borderRadius: 14, cursor: "pointer",
              background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,215,0,0.3)",
              color: "rgba(255,215,0,0.85)", fontSize: 12, letterSpacing: "0.14em", textTransform: "uppercase",
            }}>Başka Yıl Dene</button>
          </div>
        )}
      </div>

      <style>{`
        @keyframes tk-wheel { from { transform: rotate(0); } to { transform: rotate(360deg); } }
        @keyframes tk-pulse { 0%,100% { opacity: 0.6; transform: scale(1);} 50% { opacity: 1; transform: scale(1.08);} }
      `}</style>
    </div>
  );
}

// ───────────────────────── MİTOLOJİ SÖZLÜĞÜ ─────────────────────────
function MitolojiScreen({ onBack }) {
  const entries = [
    { ad: "Tengri", unvan: "Gök Tanrısı", img: "tengri.jpeg", aciklama: "Türk mitolojisinin en yüce tanrısı. Sonsuz gök, kaderin ve adaletin sahibi." , tag: "Tanrı" },
    { ad: "Ak Ana", unvan: "Bilgelik Tanrıçası", img: "ak_ana.png", aciklama: "Sütümsü beyaz sularda yaşar; yaratıcı ilham ve bilgelik kaynağı.", tag: "Tanrıça" },
    { ad: "Erlik Han", unvan: "Yer Altı Hâkimi", img: "erlik_han.png", aciklama: "Aşağı dünyanın efendisi; ölümün ve dönüşümün bekçisi.", tag: "Tanrı" },
    { ad: "Bozkurt", unvan: "Ata Ruhu", img: "bozkurt.png", aciklama: "Türk soyunun kurucusu, yol gösterici kutsal kurt.", tag: "Ata Ruhu" },
    { ad: "Kam", unvan: "Şaman", img: "kam.png", aciklama: "Üç dünyayı dolaşan; rüya, şifa ve kehanet ustası.", tag: "Şaman" },
    { ad: "Dede Korkut", unvan: "Bilge Atalar", img: "dede_korkut.png", aciklama: "Oğuzların kopuz çalan bilgesi; kelamla geleceği görür.", tag: "Bilge" },
    { ad: "Tomris Hatun", unvan: "Sakaların Hakanı", img: "tomris_hatun.png", aciklama: "Persleri yenen efsanevi Türk kraliçesi; cesaretin sembolü.", tag: "Kahraman" },
  ];
  const [q, setQ] = useTarotState("");
  const [sel, setSel] = useTarotState(null);
  const filtered = entries.filter(e => (e.ad + " " + e.unvan + " " + e.tag).toLowerCase().includes(q.toLowerCase()));

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/yolculuk.jpeg" style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover", opacity: 0.22, filter: "blur(2px)" }} />
      <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 30%, rgba(20,83,45,0.4) 0%, rgba(107,29,43,0.3) 35%, rgba(12,10,24,0.95) 75%, #0C0A18 100%)" }} />

      <div style={{ position: "absolute", top: 0, left: 0, right: 0, height: 56, display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20 }}>
        <button onClick={sel ? () => setSel(null) : onBack} style={{ width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{ flex: 1, textAlign: "center", color: "#fff", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "0.2em", fontSize: 14, textTransform: "uppercase", marginRight: 40 }}>{sel ? sel.ad : "Mitoloji Sözlüğü"}</div>
      </div>

      <div style={{ position: "absolute", inset: "56px 0 0", overflow: "auto" }}>
        {!sel ? (
          <div style={{ padding: "16px 16px 32px" }}>
            <div style={{ background: "rgba(12,10,24,0.65)", backdropFilter: "blur(20px)", border: "1px solid rgba(134,239,172,0.25)", borderRadius: 14, padding: "10px 14px", display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.5)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
              <input value={q} onChange={e => setQ(e.target.value)} placeholder="Tanrı, ruh, kahraman ara…" style={{ flex: 1, background: "transparent", border: 0, outline: "none", color: "#fff", fontSize: 14, fontFamily: "inherit", padding: "8px 0" }} />
              {q && <button onClick={() => setQ("")} style={{ background: "transparent", border: 0, color: "rgba(255,255,255,0.5)", cursor: "pointer", fontSize: 18 }}>×</button>}
            </div>

            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
              {filtered.map(e => (
                <button key={e.ad} onClick={() => setSel(e)} style={{
                  textAlign: "left", cursor: "pointer", padding: 0, background: "transparent", border: 0,
                  borderRadius: 14, overflow: "hidden", position: "relative", aspectRatio: "3/4",
                  boxShadow: "0 14px 30px rgba(0,0,0,0.5)",
                }}>
                  <img src={`../../assets/${e.img}`} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
                  <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg, transparent 35%, rgba(12,10,24,0.95) 100%)" }} />
                  <div style={{ position: "absolute", left: 10, top: 10, padding: "3px 8px", borderRadius: 10, background: "rgba(134,239,172,0.18)", border: "1px solid rgba(134,239,172,0.4)", color: "#86EFAC", fontSize: 9, letterSpacing: "0.12em", textTransform: "uppercase", fontWeight: 600 }}>{e.tag}</div>
                  <div style={{ position: "absolute", left: 12, right: 12, bottom: 12, color: "#fff" }}>
                    <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 16, letterSpacing: "0.08em", textShadow: "0 0 12px rgba(0,0,0,0.9)" }}>{e.ad}</div>
                    <div style={{ fontSize: 11, color: "rgba(255,255,255,0.75)", marginTop: 2 }}>{e.unvan}</div>
                  </div>
                </button>
              ))}
            </div>
            {filtered.length === 0 && (
              <div style={{ textAlign: "center", padding: 40, color: "rgba(255,255,255,0.5)", fontSize: 14 }}>Aradığın varlık bulunamadı.</div>
            )}
          </div>
        ) : (
          <div>
            <div style={{ position: "relative", height: 320 }}>
              <img src={`../../assets/${sel.img}`} style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover" }} />
              <div style={{ position: "absolute", inset: 0, background: "linear-gradient(180deg, transparent 40%, rgba(12,10,24,1) 100%)" }} />
              <div style={{ position: "absolute", left: 20, right: 20, bottom: 16 }}>
                <div style={{ display: "inline-block", padding: "3px 10px", borderRadius: 12, background: "rgba(134,239,172,0.18)", border: "1px solid rgba(134,239,172,0.4)", color: "#86EFAC", fontSize: 10, letterSpacing: "0.16em", textTransform: "uppercase", fontWeight: 600, marginBottom: 8 }}>{sel.tag}</div>
                <div style={{ fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 32, color: "#fff", letterSpacing: "0.1em", textShadow: "0 0 16px rgba(0,0,0,0.9)" }}>{sel.ad}</div>
                <div style={{ color: "#86EFAC", fontSize: 14, fontStyle: "italic", marginTop: 4 }}>{sel.unvan}</div>
              </div>
            </div>
            <div style={{ padding: "20px 20px 32px", display: "flex", flexDirection: "column", gap: 14 }}>
              <div style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: "1px solid rgba(134,239,172,0.25)", borderRadius: 16, padding: 18 }}>
                <div style={{ color: "#FFE082", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", fontWeight: 600, marginBottom: 8 }}>Hikâye</div>
                <div style={{ color: "#fff", fontSize: 14, lineHeight: 1.7 }}>{sel.aciklama}</div>
              </div>
              <div style={{ background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", border: "1px solid rgba(77,208,225,0.3)", borderRadius: 16, padding: 18 }}>
                <div style={{ color: "#4DD0E1", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", fontWeight: 600, marginBottom: 8 }}>İlgili Kehanetler</div>
                <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
                  {[1,2].map(k => (
                    <div key={k} style={{ display: "flex", alignItems: "center", gap: 10, padding: 10, borderRadius: 10, background: "rgba(77,208,225,0.06)" }}>
                      <div style={{ width: 36, height: 36, borderRadius: 9, background: "rgba(77,208,225,0.18)", border: "1px solid rgba(77,208,225,0.4)", display: "flex", alignItems: "center", justifyContent: "center", color: "#4DD0E1", fontFamily: "Orkun, serif", fontSize: 16 }}>𐰋</div>
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 13, color: "#fff" }}>{sel.ad}'in işaret ettiği yol</div>
                        <div style={{ fontSize: 11, color: "rgba(255,255,255,0.55)" }}>Irk Bitig · 12 Mart 2026</div>
                      </div>
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { TarotScreen, TakvimScreen, MitolojiScreen });
