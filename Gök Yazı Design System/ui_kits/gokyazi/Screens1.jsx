/* global React, RuneButton, PrimaryButton, Card, Dice, Scrim, AppBar, LevelMeter */
const { useState, useEffect } = React;

function SplashScreen({ onBegin }) {
  const [stage, setStage] = useState(0); // 0 = enter, 1 = full
  useEffect(() => {
    const t = setTimeout(() => setStage(1), 80);
    return () => clearTimeout(t);
  }, []);
  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      {/* Cosmic backdrop */}
      <img src="../../assets/tengri.jpeg" style={{
        position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
        opacity: 0.3, mixBlendMode: "screen",
      }} />
      <div style={{
        position: "absolute", inset: 0,
        background: "radial-gradient(ellipse at 50% 38%, rgba(45,27,105,0.55) 0%, rgba(12,10,24,0.95) 60%, #0C0A18 100%)",
      }} />

      {/* Faint mandala watermark */}
      <img src="../../assets/ikon.png" style={{
        position: "absolute", top: "50%", left: "50%",
        width: 520, height: 520, marginLeft: -260, marginTop: -290,
        opacity: stage ? 0.18 : 0,
        transform: `scale(${stage ? 1 : 0.85}) rotate(${stage ? 0 : -8}deg)`,
        transition: "opacity 1400ms ease-out, transform 1800ms cubic-bezier(0.16, 1, 0.3, 1)",
        filter: "drop-shadow(0 0 40px rgba(255,193,7,0.25))",
        pointerEvents: "none",
      }} />

      {/* Center stack */}
      <div style={{
        position: "absolute", inset: 0,
        display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
        gap: 20, padding: "0 32px", boxSizing: "border-box", textAlign: "center",
        opacity: stage ? 1 : 0,
        transform: `scale(${stage ? 1 : 0.94})`,
        transition: "opacity 1100ms ease-out 200ms, transform 1100ms cubic-bezier(0.16, 1, 0.3, 1) 200ms",
      }}>
        <div style={{
          fontFamily: "Orkun, serif",
          fontSize: 56, lineHeight: 1.1,
          color: "#FFC107",
          textShadow: "0 0 24px rgba(255,193,7,0.7), 0 0 8px rgba(255,193,7,0.5), 0 2px 6px rgba(0,0,0,0.9)",
          letterSpacing: 2,
        }}>𐰏𐰇𐰚⸱𐰖𐰔𐰃</div>

        <div style={{
          fontFamily: "'Cinzel Decorative', serif", fontWeight: 700,
          letterSpacing: "0.45em", paddingLeft: "0.45em",
          fontSize: 22, color: "#fff",
          textShadow: "0 0 18px rgba(0,0,0,0.9)",
        }}>GÖK YAZI</div>

        <div style={{
          width: 48, height: 1, background: "linear-gradient(90deg, transparent, rgba(255,193,7,0.7), transparent)",
          margin: "4px 0",
        }} />

        <div style={{
          color: "rgba(255,255,255,0.72)", fontSize: 13,
          letterSpacing: "0.15em", textTransform: "uppercase",
          textShadow: "0 0 12px rgba(0,0,0,0.9)",
        }}>Kadim Bilgeliğin Kapısı</div>
      </div>

      {/* Bottom: subtle loader and tap-to-continue */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 56,
        display: "flex", flexDirection: "column", alignItems: "center", gap: 22,
        opacity: stage ? 1 : 0, transition: "opacity 800ms ease 900ms",
      }}>
        <div style={{ width: 120, height: 2, background: "rgba(255,255,255,0.08)", borderRadius: 1, overflow: "hidden" }}>
          <div style={{
            width: "40%", height: "100%", background: "linear-gradient(90deg, transparent, #FFC107, transparent)",
            animation: "splashShimmer 1800ms ease-in-out infinite",
          }} />
        </div>
        <button onClick={onBegin} style={{
          background: "transparent", border: 0, color: "rgba(255,255,255,0.45)",
          fontSize: 11, letterSpacing: "0.2em", textTransform: "uppercase", cursor: "pointer", padding: 8,
        }}>Devam etmek için dokun</button>
      </div>

      <style>{`@keyframes splashShimmer { 0% { transform: translateX(-150%);} 100% { transform: translateX(350%);} }`}</style>
    </div>
  );
}

function LoginScreen({ onLogin }) {
  const [mode, setMode] = useState("login"); // login | signup
  const [email, setEmail] = useState("");
  const [pass, setPass] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [focused, setFocused] = useState(null);
  const [loading, setLoading] = useState(false);
  const [entered, setEntered] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setEntered(true), 60);
    return () => clearTimeout(t);
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!email || !pass) return;
    setLoading(true);
    setTimeout(() => { setLoading(false); onLogin && onLogin(); }, 1100);
  };

  const inputWrap = (active) => ({
    display: "flex", alignItems: "center", gap: 12,
    background: "rgba(0,0,0,0.35)",
    border: `1px solid ${active ? "rgba(255,193,7,0.7)" : "rgba(255,255,255,0.12)"}`,
    borderRadius: 12, padding: "0 14px", height: 52,
    transition: "border-color 200ms, box-shadow 200ms",
    boxShadow: active ? "0 0 0 4px rgba(255,193,7,0.08), 0 0 22px rgba(255,193,7,0.18)" : "none",
  });
  const inputEl = {
    flex: 1, height: "100%", background: "transparent", border: 0, outline: "none",
    color: "#fff", fontSize: 15, fontFamily: "inherit",
  };
  const IconMail = ({ color }) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>
    </svg>
  );
  const IconLock = ({ color }) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      <rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V8a4 4 0 1 1 8 0v3"/>
    </svg>
  );
  const IconEye = ({ color, off }) => (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
      {off ? <><path d="M9.88 9.88a3 3 0 1 0 4.24 4.24"/><path d="M10.73 5.08A10.43 10.43 0 0 1 12 5c7 0 10 7 10 7a13.16 13.16 0 0 1-1.67 2.68"/><path d="M6.61 6.61A13.526 13.526 0 0 0 2 12s3 7 10 7a9.74 9.74 0 0 0 5.39-1.61"/><path d="m2 2 20 20"/></> : <><path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/></>}
    </svg>
  );

  const stagger = (i) => ({
    opacity: entered ? 1 : 0,
    transform: entered ? "translateY(0)" : "translateY(12px)",
    transition: `opacity 600ms ease ${200 + i*120}ms, transform 600ms cubic-bezier(0.16,1,0.3,1) ${200 + i*120}ms`,
  });

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/tengri.jpeg" style={{
        position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
        opacity: 0.3, mixBlendMode: "screen",
      }} />
      <div style={{
        position: "absolute", inset: 0,
        background: "radial-gradient(ellipse at 50% 30%, rgba(45,27,105,0.55) 0%, rgba(12,10,24,0.95) 60%, #0C0A18 100%)",
      }} />
      <img src="../../assets/ikon.png" style={{
        position: "absolute", top: 60, left: "50%", marginLeft: -240,
        width: 480, height: 480, opacity: 0.10, pointerEvents: "none",
        filter: "drop-shadow(0 0 40px rgba(255,193,7,0.25))",
      }} />

      <form onSubmit={handleSubmit} style={{
        position: "absolute", inset: 0,
        display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
        padding: "40px 24px", boxSizing: "border-box", gap: 28,
      }}>
        {/* Logo area, OUTSIDE the card */}
        <div style={{ textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: 8,
          opacity: entered ? 1 : 0, transform: entered ? "translateY(0)" : "translateY(-8px)",
          transition: "opacity 700ms ease, transform 700ms cubic-bezier(0.16,1,0.3,1)" }}>
          <div style={{
            fontFamily: "Orkun, serif", fontSize: 42, color: "#FFC107", lineHeight: 1.1,
            textShadow: "0 0 22px rgba(255,193,7,0.7), 0 2px 6px rgba(0,0,0,0.9)", letterSpacing: 1.5,
          }}>𐰏𐰇𐰚⸱𐰖𐰔𐰃</div>
          <div style={{
            fontFamily: "'Cinzel Decorative', serif", fontWeight: 700,
            letterSpacing: "0.4em", paddingLeft: "0.4em",
            fontSize: 14, color: "rgba(189,189,189,0.95)",
            textShadow: "0 0 12px rgba(0,0,0,0.9)",
          }}>GÖK YAZI</div>
        </div>

        {/* Glassmorphic card */}
        <div style={{
          width: "100%", maxWidth: 400,
          background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
          border: "1px solid rgba(255,215,0,0.2)", borderRadius: 24, padding: 32,
          display: "flex", flexDirection: "column", gap: 18,
          boxShadow: "0 30px 60px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.04)",
          opacity: entered ? 1 : 0,
          transform: entered ? "translateY(0)" : "translateY(24px)",
          transition: "opacity 700ms ease 100ms, transform 700ms cubic-bezier(0.16,1,0.3,1) 100ms",
        }}>
          {/* Tab toggle */}
          <div style={{ display: "flex", gap: 4, padding: 4, background: "rgba(0,0,0,0.35)", borderRadius: 10, border: "1px solid rgba(255,255,255,0.06)", ...stagger(0) }}>
            {[["login","Giriş Yap"],["signup","Hesap Oluştur"]].map(([k, label]) => (
              <button key={k} type="button" onClick={() => setMode(k)} style={{
                flex: 1, padding: "9px 0", borderRadius: 7, border: 0,
                background: mode === k ? "rgba(255,193,7,0.18)" : "transparent",
                color: mode === k ? "#FFC107" : "rgba(255,255,255,0.6)",
                fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "0.08em",
                fontSize: 12, cursor: "pointer", textTransform: "uppercase",
                transition: "background 200ms, color 200ms",
              }}>{label}</button>
            ))}
          </div>

          {/* Email */}
          <div style={stagger(1)}>
            <label style={{ display: "block", fontSize: 11, letterSpacing: "0.12em", textTransform: "uppercase", color: "rgba(255,255,255,0.55)", marginBottom: 8, marginLeft: 2 }}>E-posta</label>
            <div style={inputWrap(focused === "email")}>
              <IconMail color={focused === "email" ? "#FFC107" : "rgba(255,255,255,0.5)"} />
              <input type="email" value={email} onChange={e => setEmail(e.target.value)} onFocus={() => setFocused("email")} onBlur={() => setFocused(null)} placeholder="sen@gokyazi.app" style={inputEl} />
            </div>
          </div>

          {/* Password */}
          <div style={stagger(2)}>
            <label style={{ display: "block", fontSize: 11, letterSpacing: "0.12em", textTransform: "uppercase", color: "rgba(255,255,255,0.55)", marginBottom: 8, marginLeft: 2 }}>Şifre</label>
            <div style={inputWrap(focused === "pass")}>
              <IconLock color={focused === "pass" ? "#FFC107" : "rgba(255,255,255,0.5)"} />
              <input type={showPass ? "text" : "password"} value={pass} onChange={e => setPass(e.target.value)} onFocus={() => setFocused("pass")} onBlur={() => setFocused(null)} placeholder="••••••••" style={inputEl} />
              <button type="button" onClick={() => setShowPass(v => !v)} style={{ background: "transparent", border: 0, cursor: "pointer", padding: 4, display: "flex" }}>
                <IconEye color="rgba(255,255,255,0.55)" off={!showPass} />
              </button>
            </div>
          </div>

          {/* Forgot */}
          <div style={{ display: "flex", justifyContent: "flex-end", marginTop: -6, ...stagger(3) }}>
            <button type="button" style={{
              background: "transparent", border: 0, color: "rgba(255,255,255,0.55)",
              fontSize: 12, cursor: "pointer", textDecoration: "underline", textUnderlineOffset: 3,
            }}>Şifremi Unuttum</button>
          </div>

          {/* Primary CTA */}
          <button type="submit" disabled={loading || !email || !pass} style={{
            height: 56, borderRadius: 12, border: 0, marginTop: 6,
            background: (loading || !email || !pass) ? "rgba(212,160,23,0.4)" : "linear-gradient(180deg, #E5B225 0%, #C99411 100%)",
            color: "#0C0A18", fontWeight: 700, fontSize: 16, letterSpacing: "0.05em",
            fontFamily: "'Cinzel Decorative', serif",
            cursor: (loading || !email || !pass) ? "not-allowed" : "pointer",
            boxShadow: (loading || !email || !pass) ? "none" : "0 8px 24px rgba(212,160,23,0.35), inset 0 1px 0 rgba(255,255,255,0.4)",
            transition: "transform 180ms cubic-bezier(0.34,1.56,0.64,1), filter 180ms, box-shadow 180ms",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
            ...stagger(4),
          }}
            onMouseDown={e => !loading && (e.currentTarget.style.transform = "scale(0.98)")}
            onMouseUp={e => (e.currentTarget.style.transform = "scale(1)")}
            onMouseLeave={e => (e.currentTarget.style.transform = "scale(1)")}
            onMouseEnter={e => !loading && email && pass && (e.currentTarget.style.filter = "brightness(1.08)")}
            onMouseOut={e => (e.currentTarget.style.filter = "brightness(1)")}
          >
            {loading ? (
              <>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#0C0A18" strokeWidth="2.5" strokeLinecap="round">
                  <path d="M21 12a9 9 0 1 1-6.219-8.56"><animateTransform attributeName="transform" type="rotate" from="0 12 12" to="360 12 12" dur="0.9s" repeatCount="indefinite"/></path>
                </svg>
                <span>Giriliyor…</span>
              </>
            ) : (mode === "login" ? "Giriş Yap" : "Hesap Oluştur")}
          </button>

          {/* Divider */}
          <div style={{ display: "flex", alignItems: "center", gap: 12, margin: "6px 0", ...stagger(5) }}>
            <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.08)" }} />
            <div style={{ fontSize: 10, letterSpacing: "0.2em", color: "rgba(255,255,255,0.4)", textTransform: "uppercase" }}>veya</div>
            <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.08)" }} />
          </div>

          {/* Footer toggle */}
          <div style={{ textAlign: "center", color: "rgba(255,255,255,0.6)", fontSize: 13, ...stagger(6) }}>
            {mode === "login" ? "Hesabın yok mu? " : "Hesabın var mı? "}
            <button type="button" onClick={() => setMode(mode === "login" ? "signup" : "login")} style={{
              background: "transparent", border: 0, padding: 0, cursor: "pointer",
              color: "#FFD56B", fontWeight: 600, fontSize: 13, textDecoration: "underline", textUnderlineOffset: 3,
            }}>{mode === "login" ? "Hesap Oluştur" : "Giriş Yap"}</button>
          </div>
        </div>

        {/* Below-card hint */}
        <div style={{ color: "rgba(255,255,255,0.35)", fontSize: 11, letterSpacing: "0.12em", textTransform: "uppercase", textAlign: "center",
          opacity: entered ? 1 : 0, transition: "opacity 700ms ease 900ms" }}>
          Tengri'nin gözleri seni izliyor
        </div>
      </form>
    </div>
  );
}

function OnboardingScreen({ onDone, onSkip }) {
  const slides = [
    {
      title: "𐰋𐰃𐰓𐰢", subtitle: "Kadim Bilgeliğe Hoş Geldin",
      body: "Türk mitolojisinin derinliklerinde kehanet, bilgelik ve ruhsal yolculuk seni bekliyor.",
      kind: "ak_ana",
    },
    {
      title: "𐰃𐰼𐰴", subtitle: "Irk Bitig — Kadim Kehanet Kitabı",
      body: "Göktürk runik yazısıyla yazılan 65 kehanetten birini çek. Niyetini belirt, zarları at, kadim bilgeliğin sesini dinle.",
      kind: "dice",
    },
    {
      title: "𐱃𐰺𐰆𐱃", subtitle: "Türk Tarotu — 22 Kart, 22 Yol",
      body: "Kam, Ak Ana, Yer Ana… Türk mitolojisinin kadim varlıkları rehberin olsun. Niyetini belirt, kartlarını çek, yolunu aydınlat.",
      kind: "tarot",
    },
  ];
  const [i, setI] = useState(0);
  const [entered, setEntered] = useState(false);
  useEffect(() => { const t = setTimeout(() => setEntered(true), 60); return () => clearTimeout(t); }, []);
  const last = i === slides.length - 1;
  const go = (n) => setI(Math.max(0, Math.min(slides.length - 1, n)));

  // Illustration renderers
  const renderArt = (kind, key) => {
    const baseStyle = {
      position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center",
    };
    if (kind === "ak_ana") {
      return (
        <div style={baseStyle}>
          <div style={{ position: "relative", width: 260, height: 260 }}>
            <div style={{ position: "absolute", inset: -30, borderRadius: "50%",
              background: "radial-gradient(circle, rgba(255,193,7,0.22) 0%, transparent 65%)",
              animation: "obShimmer 3.6s ease-in-out infinite" }} />
            <img src="../../assets/ak_ana.png" alt="Ak Ana" style={{
              width: "100%", height: "100%", objectFit: "contain",
              borderRadius: "50%", opacity: 0.95,
              filter: "drop-shadow(0 0 30px rgba(255,193,7,0.35))",
            }} />
          </div>
        </div>
      );
    }
    if (kind === "dice") {
      const pips = ["o","oo","ooo","oooo"];
      return (
        <div style={baseStyle}>
          <div style={{ position: "relative", width: 240, height: 200 }}>
            <div style={{ position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center",
              animation: "obFloat 2.6s ease-in-out infinite" }}>
              <div style={{ display: "flex", gap: 16 }}>
                {[1,2,3].map((n, idx) => (
                  <div key={n} style={{
                    width: 64, height: 64, borderRadius: 12,
                    background: "linear-gradient(155deg, rgba(40,30,80,0.85), rgba(12,10,24,0.95))",
                    border: "1.5px solid rgba(255,193,7,0.55)",
                    boxShadow: "0 12px 32px rgba(0,0,0,0.55), 0 0 24px rgba(255,193,7,0.22), inset 0 1px 0 rgba(255,255,255,0.08)",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    color: "#FFD56B", fontSize: 26, fontWeight: 700, letterSpacing: -2,
                    transform: `rotate(${[-6,0,6][idx]}deg) translateY(${[6,0,8][idx]}px)`,
                  }}>{pips[idx === 1 ? 3 : idx === 0 ? 1 : 2]}</div>
                ))}
              </div>
            </div>
            {/* Runic spark accents */}
            {["𐰋","𐰃","𐱅"].map((g, k) => (
              <div key={k} style={{
                position: "absolute", color: "rgba(255,193,7,0.55)", fontFamily: "Orkun, serif", fontSize: 22,
                top: [10, 30, 150][k], left: [16, 200, 24][k],
                textShadow: "0 0 12px rgba(255,193,7,0.7)",
                animation: `obSparkle 2.2s ease-in-out ${k * 0.4}s infinite`,
              }}>{g}</div>
            ))}
          </div>
        </div>
      );
    }
    // tarot
    return (
      <div style={baseStyle}>
        <div style={{ position: "relative", width: 220, height: 320, perspective: 900 }}>
          <div style={{ position: "absolute", inset: -28, borderRadius: 20,
            background: "radial-gradient(ellipse at center, rgba(255,193,7,0.20) 0%, transparent 70%)",
            animation: "obShimmer 3.2s ease-in-out infinite" }} />
          <div style={{
            position: "absolute", inset: 0, borderRadius: 14, overflow: "hidden",
            transform: "rotateY(-12deg) rotateX(2deg)",
            boxShadow: "0 30px 60px rgba(0,0,0,0.55), 0 0 28px rgba(255,193,7,0.25)",
            border: "1px solid rgba(255,193,7,0.4)",
            background: "#0C0A18",
          }}>
            <img src="../../assets/tarot_arkayuz.png" alt="Türk Tarotu" style={{
              width: "100%", height: "100%", objectFit: "cover",
            }} />
          </div>
        </div>
      </div>
    );
  };

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      <img src="../../assets/tengri.jpeg" style={{
        position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
        opacity: 0.3, mixBlendMode: "screen",
      }} />
      <div style={{
        position: "absolute", inset: 0,
        background: "radial-gradient(ellipse at 50% 35%, rgba(45,27,105,0.55) 0%, rgba(12,10,24,0.95) 60%, #0C0A18 100%)",
      }} />

      {/* Skip */}
      {!last && (
        <button onClick={onSkip} style={{
          position: "absolute", top: 18, right: 18, zIndex: 10,
          background: "transparent", border: 0, color: "rgba(189,189,189,0.85)",
          fontSize: 13, letterSpacing: "0.1em", textTransform: "uppercase", cursor: "pointer", padding: 8,
          opacity: entered ? 1 : 0, transition: "opacity 600ms ease 400ms",
        }}>Atla</button>
      )}

      {/* Slide carousel */}
      <div style={{ position: "absolute", inset: 0, overflow: "hidden" }}>
        <div style={{
          position: "absolute", inset: 0, display: "flex",
          width: `${slides.length * 100}%`,
          transform: `translateX(-${i * (100 / slides.length)}%)`,
          transition: "transform 550ms cubic-bezier(0.7, 0, 0.2, 1)",
        }}>
          {slides.map((s, idx) => (
            <div key={idx} style={{
              width: `${100 / slides.length}%`, height: "100%", position: "relative",
              padding: "60px 28px 160px", boxSizing: "border-box",
              display: "flex", flexDirection: "column",
            }}>
              {/* Illustration */}
              <div style={{
                flex: "0 0 56%", position: "relative",
                opacity: idx === i && entered ? 1 : 0,
                transform: idx === i && entered ? "scale(1)" : "scale(0.92)",
                transition: "opacity 800ms ease-out 100ms, transform 800ms cubic-bezier(0.16,1,0.3,1) 100ms",
              }}>
                {renderArt(s.kind, idx)}
              </div>

              {/* Text block */}
              <div style={{
                flex: "1 1 auto", textAlign: "center", padding: "8px 6px",
                display: "flex", flexDirection: "column", alignItems: "center", gap: 14,
                opacity: idx === i && entered ? 1 : 0,
                transform: idx === i && entered ? "translateY(0)" : "translateY(14px)",
                transition: "opacity 700ms ease 350ms, transform 700ms cubic-bezier(0.16,1,0.3,1) 350ms",
              }}>
                <div style={{
                  fontFamily: "Orkun, serif", fontSize: idx === 0 ? 40 : 34, color: "#FFC107",
                  textShadow: "0 0 22px rgba(255,193,7,0.6), 0 2px 6px rgba(0,0,0,0.9)",
                  lineHeight: 1, letterSpacing: 2,
                }}>{s.title}</div>
                <div style={{
                  fontFamily: "'Cinzel Decorative', serif", fontWeight: 700,
                  color: "#fff", fontSize: idx === 0 ? 21 : 19,
                  letterSpacing: "0.12em", textShadow: "0 0 12px rgba(0,0,0,0.9)",
                  lineHeight: 1.25, maxWidth: 320,
                }}>{s.subtitle}</div>
                <div style={{
                  color: "rgba(224,224,224,0.85)", fontSize: 14, lineHeight: 1.65,
                  maxWidth: 300, textShadow: "0 0 8px rgba(0,0,0,0.9)",
                  textWrap: "pretty",
                }}>{s.body}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom controls */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 36,
        padding: "0 28px", display: "flex", flexDirection: "column", alignItems: "center", gap: 22,
        opacity: entered ? 1 : 0, transition: "opacity 700ms ease 500ms",
      }}>
        {/* Dot indicator */}
        <div style={{ display: "flex", gap: 8 }}>
          {slides.map((_, k) => (
            <button key={k} onClick={() => go(k)} aria-label={`Sayfa ${k+1}`} style={{
              width: k === i ? 28 : 8, height: 8, borderRadius: 4, border: 0, padding: 0,
              background: k === i ? "#FFC107" : "rgba(255,255,255,0.22)",
              boxShadow: k === i ? "0 0 14px rgba(255,193,7,0.6)" : "none",
              cursor: "pointer", transition: "all 300ms cubic-bezier(0.16,1,0.3,1)",
            }} />
          ))}
        </div>

        {/* CTA */}
        {last ? (
          <button onClick={onDone} className="ob-start" style={{
            width: "100%", maxWidth: 360, height: 56, border: 0, borderRadius: 12,
            background: "linear-gradient(180deg, #E5B225 0%, #C99411 100%)",
            color: "#0C0A18", fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 18,
            letterSpacing: "0.18em", cursor: "pointer",
            boxShadow: "0 8px 24px rgba(212,160,23,0.35), inset 0 1px 0 rgba(255,255,255,0.4)",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 12,
            animation: "obPulse 2.4s ease-in-out infinite",
          }}>
            BAŞLA
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#0C0A18" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14"/><path d="m13 5 7 7-7 7"/></svg>
          </button>
        ) : (
          <button onClick={() => go(i + 1)} style={{
            width: "100%", maxWidth: 360, height: 50, border: "1px solid rgba(255,193,7,0.4)", borderRadius: 12,
            background: "rgba(255,193,7,0.08)", color: "#FFD56B", fontWeight: 600, fontSize: 14,
            letterSpacing: "0.15em", textTransform: "uppercase", cursor: "pointer",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
            transition: "background 200ms",
          }}
            onMouseEnter={e => (e.currentTarget.style.background = "rgba(255,193,7,0.16)")}
            onMouseLeave={e => (e.currentTarget.style.background = "rgba(255,193,7,0.08)")}
          >
            Devam Et
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#FFD56B" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14"/><path d="m13 5 7 7-7 7"/></svg>
          </button>
        )}
      </div>

      <style>{`
        @keyframes obFloat { 0%,100% { transform: translateY(0);} 50% { transform: translateY(-10px);} }
        @keyframes obShimmer { 0%,100% { opacity: 0.6; transform: scale(1);} 50% { opacity: 1; transform: scale(1.05);} }
        @keyframes obSparkle { 0%,100% { opacity: 0.25;} 50% { opacity: 1;} }
        @keyframes obPulse { 0%,100% { box-shadow: 0 8px 24px rgba(212,160,23,0.35), inset 0 1px 0 rgba(255,255,255,0.4);} 50% { box-shadow: 0 8px 24px rgba(212,160,23,0.55), 0 0 26px rgba(255,193,7,0.4), inset 0 1px 0 rgba(255,255,255,0.4);} }
      `}</style>
    </div>
  );
}

Object.assign(window, { SplashScreen, LoginScreen, OnboardingScreen });
