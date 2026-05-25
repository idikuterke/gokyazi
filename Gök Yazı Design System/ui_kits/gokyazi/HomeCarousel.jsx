/* global React */
const { useState, useEffect, useRef } = React;

function HomeScreen({ onOpen, onProfile, onSettings, onKehanetler }) {
  const cards = [
    {
      k: "fal", label: "IRK BİTİG", sub: "65 Kehanet · Göktürk Falı",
      icon: "../../assets/ikon_irk_bitig.png",
      bg: "../../assets/bg_fal_ekrani.png",
      gradient: "linear-gradient(155deg, #5B21B6 0%, #2D1B69 55%, #0C0A18 100%)",
      accent: "#A78BFA",
    },
    {
      k: "tarot", label: "TÜRK TAROTU", sub: "22 Kart · Kadim Açılım",
      icon: "../../assets/ikon_tarot.png",
      bg: "../../assets/tarot_arkayuz.png",
      gradient: "linear-gradient(155deg, #9D174D 0%, #4C1D6E 55%, #0C0A18 100%)",
      accent: "#F472B6",
    },
    {
      k: "takvim", label: "TAKVİM", sub: "12 Hayvanlı Türk Takvimi",
      icon: "../../assets/ikon_takvim.png",
      bg: "../../assets/bg_takvim.jpeg",
      gradient: "linear-gradient(155deg, #1E3A8A 0%, #1E1B4B 55%, #0C0A18 100%)",
      accent: "#60A5FA",
    },
    {
      k: "mitoloji", label: "MİTOLOJİ", sub: "Tanrılar, Ruhlar, Atalar",
      icon: "../../assets/ikon_mitoloji.png",
      bg: "../../assets/yolculuk.jpeg",
      gradient: "linear-gradient(155deg, #14532D 0%, #6B1D2B 55%, #0C0A18 100%)",
      accent: "#86EFAC",
    },
  ];

  const [active, setActive] = useState(0);
  const [entered, setEntered] = useState(false);
  const [tab, setTab] = useState("home"); // home | kehanetler
  const dragRef = useRef({ start: 0, dx: 0, dragging: false });
  const [dragOffset, setDragOffset] = useState(0);

  useEffect(() => { const t = setTimeout(() => setEntered(true), 80); return () => clearTimeout(t); }, []);

  const go = (n) => setActive(Math.max(0, Math.min(cards.length - 1, n)));
  const onPointerDown = (e) => {
    dragRef.current = { start: e.clientX || (e.touches && e.touches[0].clientX) || 0, dx: 0, dragging: true };
  };
  const onPointerMove = (e) => {
    if (!dragRef.current.dragging) return;
    const x = e.clientX || (e.touches && e.touches[0].clientX) || 0;
    const dx = x - dragRef.current.start;
    dragRef.current.dx = dx;
    setDragOffset(dx);
  };
  const onPointerUp = () => {
    if (!dragRef.current.dragging) return;
    const dx = dragRef.current.dx;
    dragRef.current.dragging = false;
    setDragOffset(0);
    if (Math.abs(dx) > 50) go(active + (dx < 0 ? 1 : -1));
  };

  // Background cross-fade across cards
  const renderBg = () => (
    <>
      {cards.map((c, i) => (
        <img key={i} src={c.bg} alt="" style={{
          position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
          opacity: i === active ? 0.45 : 0,
          transition: "opacity 700ms ease",
          filter: "saturate(0.85)",
        }} />
      ))}
      <div style={{
        position: "absolute", inset: 0,
        background: "linear-gradient(180deg, rgba(12,10,24,0.85) 0%, rgba(12,10,24,0.55) 35%, rgba(12,10,24,0.85) 75%, #0C0A18 100%)",
      }} />
    </>
  );

  // Card-position transform: each card relative to active
  const cardTransform = (i) => {
    const delta = i - active;
    const dragDelta = dragOffset / 220; // soft elastic
    const d = delta - dragDelta;
    const abs = Math.abs(d);
    const isActive = abs < 0.5;
    const isAdjacent = abs >= 0.5 && abs < 1.5;
    const sign = d > 0 ? 1 : -1;

    const tx = d * 220; // px offset
    const rotateY = Math.max(-45, Math.min(45, -d * 25));
    const scale = isActive ? (1.05 - Math.abs(d) * 0.15) : (isAdjacent ? 0.92 - (abs - 0.5) * 0.1 : 0.8);
    const opacity = abs > 2.2 ? 0 : (abs > 1.5 ? 0.4 : 1);
    const zIndex = Math.round(100 - abs * 10);
    return { tx, rotateY, scale, opacity, zIndex };
  };

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden", userSelect: "none" }}>
      {renderBg()}

      {/* App bar */}
      <div style={{
        position: "absolute", top: 0, left: 0, right: 0, height: 56,
        display: "flex", alignItems: "center", justifyContent: "space-between",
        padding: "0 12px", zIndex: 20,
        opacity: entered ? 1 : 0, transition: "opacity 600ms ease",
      }}>
        <button onClick={onProfile} style={{
          display: "flex", alignItems: "center", gap: 6, padding: "6px 12px 6px 8px",
          background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)",
          color: "rgba(255,255,255,0.92)", borderRadius: 22, cursor: "pointer",
          fontSize: 12, letterSpacing: "0.06em", textTransform: "uppercase",
          fontFamily: "'Cinzel Decorative', serif", fontWeight: 700,
          backdropFilter: "blur(10px)",
        }}>
          <span style={{
            width: 22, height: 22, borderRadius: "50%",
            background: "linear-gradient(135deg, #FFD700, #C99411)",
            color: "#0C0A18", fontSize: 11, display: "inline-flex", alignItems: "center", justifyContent: "center",
            fontWeight: 800, fontFamily: "Inter, sans-serif",
          }}>B</span>
          Profil
        </button>
        <button onClick={onSettings} aria-label="Ayarlar" style={{
          width: 38, height: 38, borderRadius: "50%",
          background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,215,0,0.15)",
          color: "rgba(255,255,255,0.92)", cursor: "pointer",
          display: "flex", alignItems: "center", justifyContent: "center",
          backdropFilter: "blur(10px)",
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33h0a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82v0a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
        </button>
      </div>

      {tab === "home" ? (
        <>
          {/* Title block */}
          <div style={{
            position: "absolute", top: 72, left: 0, right: 0, textAlign: "center", padding: "0 24px",
            opacity: entered ? 1 : 0, transform: entered ? "translateY(0)" : "translateY(-6px)",
            transition: "opacity 700ms ease 150ms, transform 700ms cubic-bezier(0.16,1,0.3,1) 150ms",
            zIndex: 5,
          }}>
            <div style={{
              fontFamily: "Orkun, serif", fontSize: 36, color: "#FFD700",
              textShadow: "0 0 22px rgba(255,215,0,0.55), 0 2px 6px rgba(0,0,0,0.9)", letterSpacing: 1.4,
              lineHeight: 1,
            }}>𐰏𐰇𐰚⸱𐰖𐰔𐰃</div>
            <div style={{
              marginTop: 6,
              fontFamily: "'Cinzel Decorative', serif", fontWeight: 700,
              letterSpacing: "0.22em", fontSize: 11, color: "rgba(224,224,224,0.85)",
              textTransform: "uppercase",
            }}>Kadim Bilgeliğin Yolu</div>
          </div>

          {/* 3D Carousel */}
          <div
            onMouseDown={onPointerDown} onMouseMove={onPointerMove} onMouseUp={onPointerUp} onMouseLeave={onPointerUp}
            onTouchStart={onPointerDown} onTouchMove={onPointerMove} onTouchEnd={onPointerUp}
            style={{
              position: "absolute", top: 150, bottom: 156, left: 0, right: 0,
              perspective: 1000, cursor: "grab",
              opacity: entered ? 1 : 0, transform: entered ? "scale(1)" : "scale(0.96)",
              transition: "opacity 700ms ease 300ms, transform 700ms cubic-bezier(0.16,1,0.3,1) 300ms",
            }}
          >
            <div style={{
              position: "absolute", inset: 0, transformStyle: "preserve-3d",
            }}>
              {cards.map((c, i) => {
                const { tx, rotateY, scale, opacity, zIndex } = cardTransform(i);
                return (
                  <button key={c.k} onClick={() => i === active ? onOpen(c.k) : go(i)} style={{
                    position: "absolute", top: "50%", left: "50%",
                    width: 230, height: 340, marginLeft: -115, marginTop: -170,
                    transform: `translate3d(${tx}px, 0, 0) rotateY(${rotateY}deg) scale(${scale})`,
                    transformStyle: "preserve-3d",
                    transition: dragRef.current.dragging ? "none" : "transform 500ms cubic-bezier(0.16, 1, 0.3, 1), opacity 500ms ease",
                    opacity, zIndex,
                    border: `1px solid ${i === active ? "rgba(255,215,0,0.6)" : "rgba(255,255,255,0.12)"}`,
                    borderRadius: 22, padding: 0, cursor: "pointer", background: "transparent",
                    boxShadow: i === active
                      ? "0 30px 60px rgba(0,0,0,0.55), 0 0 36px rgba(255,215,0,0.28)"
                      : "0 18px 40px rgba(0,0,0,0.5)",
                    overflow: "hidden", outline: "none",
                  }}>
                    {/* Card body */}
                    <div style={{
                      position: "absolute", inset: 0, background: c.gradient, borderRadius: 22,
                    }} />
                    <img src={c.bg} alt="" style={{
                      position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
                      opacity: 0.28, mixBlendMode: "screen",
                    }} />
                    {/* shine */}
                    <div style={{
                      position: "absolute", inset: 0, borderRadius: 22, pointerEvents: "none",
                      background: "linear-gradient(135deg, rgba(255,255,255,0.18) 0%, transparent 35%, transparent 70%, rgba(0,0,0,0.3) 100%)",
                    }} />
                    {/* gold corner filigree */}
                    <div style={{
                      position: "absolute", top: 14, left: 14, right: 14, height: 1,
                      background: "linear-gradient(90deg, transparent, rgba(255,215,0,0.55), transparent)",
                    }} />
                    <div style={{
                      position: "absolute", bottom: 14, left: 14, right: 14, height: 1,
                      background: "linear-gradient(90deg, transparent, rgba(255,215,0,0.55), transparent)",
                    }} />
                    {/* Content */}
                    <div style={{
                      position: "absolute", inset: 0, padding: 22, display: "flex", flexDirection: "column",
                      alignItems: "center", justifyContent: "space-between", color: "#fff", textAlign: "center",
                    }}>
                      <div style={{
                        fontSize: 10, letterSpacing: "0.18em", color: c.accent,
                        textTransform: "uppercase", marginTop: 4, fontWeight: 600,
                        textShadow: "0 0 12px rgba(0,0,0,0.6)",
                      }}>Kadim Yol</div>
                      <div style={{
                        width: 140, height: 140, display: "flex", alignItems: "center", justifyContent: "center",
                        position: "relative",
                      }}>
                        <div style={{
                          position: "absolute", inset: 0, borderRadius: "50%",
                          background: `radial-gradient(circle, ${c.accent}33 0%, transparent 70%)`,
                          filter: "blur(6px)",
                        }} />
                        <img src={c.icon} alt="" style={{
                          width: 116, height: 116, objectFit: "contain",
                          filter: "drop-shadow(0 6px 18px rgba(0,0,0,0.6))",
                        }} />
                      </div>
                      <div>
                        <div style={{
                          fontFamily: "'Cinzel Decorative', serif", fontWeight: 700,
                          fontSize: 19, letterSpacing: "0.14em",
                          textShadow: "0 0 14px rgba(0,0,0,0.7)",
                        }}>{c.label}</div>
                        <div style={{
                          marginTop: 6, fontSize: 11, color: "rgba(255,255,255,0.75)",
                          letterSpacing: "0.05em",
                        }}>{c.sub}</div>
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Dot indicator */}
          <div style={{
            position: "absolute", left: 0, right: 0, bottom: 110,
            display: "flex", justifyContent: "center", gap: 8, zIndex: 5,
            opacity: entered ? 1 : 0, transition: "opacity 700ms ease 400ms",
          }}>
            {cards.map((_, k) => (
              <button key={k} onClick={() => go(k)} aria-label={`Kart ${k+1}`} style={{
                width: k === active ? 28 : 8, height: 8, borderRadius: 4, border: 0, padding: 0,
                background: k === active ? "#FFD700" : "rgba(255,255,255,0.22)",
                boxShadow: k === active ? "0 0 12px rgba(255,215,0,0.6)" : "none",
                cursor: "pointer", transition: "all 300ms cubic-bezier(0.16,1,0.3,1)",
              }} />
            ))}
          </div>
        </>
      ) : (
        <KehanetlerTab />
      )}

      {/* Bottom nav */}
      <div style={{
        position: "absolute", left: 0, right: 0, bottom: 0, height: 76,
        display: "flex", alignItems: "center", justifyContent: "space-around",
        background: "rgba(12,10,24,0.85)", backdropFilter: "blur(20px)",
        borderTop: "1px solid rgba(255,215,0,0.12)", zIndex: 30,
        opacity: entered ? 1 : 0, transform: entered ? "translateY(0)" : "translateY(20px)",
        transition: "opacity 700ms ease 200ms, transform 700ms cubic-bezier(0.16,1,0.3,1) 200ms",
      }}>
        {[
          { k: "home", label: "Ana Sayfa", icon: (
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M9 22V12h6v10"/></svg>
          )},
          { k: "kehanetler", label: "Kehanetler", icon: (
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
          )},
        ].map(t => {
          const on = tab === t.k;
          return (
            <button key={t.k} onClick={() => setTab(t.k)} style={{
              background: "transparent", border: 0, cursor: "pointer",
              display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
              color: on ? "#FFD700" : "rgba(255,255,255,0.55)", padding: "6px 18px",
              position: "relative", transition: "color 250ms",
            }}>
              {on && <div style={{
                position: "absolute", top: -1, left: "50%", marginLeft: -16, width: 32, height: 2,
                background: "#FFD700", borderRadius: 2, boxShadow: "0 0 10px rgba(255,215,0,0.7)",
              }} />}
              {t.icon}
              <div style={{
                fontFamily: "'Cinzel Decorative', serif", fontWeight: 700,
                fontSize: 10, letterSpacing: "0.12em", textTransform: "uppercase",
              }}>{t.label}</div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

function KehanetlerTab() {
  const items = [
    { type: "Irk Bitig", when: "Bugün, 14:32", q: "Yeni iş teklifi…", roll: "𐰋𐰋𐰃", tone: "#A78BFA" },
    { type: "Türk Tarotu", when: "Dün, 22:08", q: "Bir karar…", roll: "Kam ✦", tone: "#F472B6" },
    { type: "Takvim", when: "12 May, 09:00", q: "Yıllık yorum", roll: "At ✺", tone: "#60A5FA" },
    { type: "Irk Bitig", when: "9 May, 18:44", q: "Aşk hakkında…", roll: "𐱅𐰸𐰋", tone: "#A78BFA" },
  ];
  return (
    <div style={{ position: "absolute", inset: "120px 0 76px", overflow: "auto", padding: "0 20px" }}>
      <div style={{ display: "flex", gap: 8, marginBottom: 14, flexWrap: "wrap" }}>
        {["Tümü","Irk Bitig","Türk Tarotu","Takvim"].map((f, i) => (
          <span key={f} style={{
            padding: "6px 14px", borderRadius: 16, fontSize: 12,
            background: i === 0 ? "rgba(255,215,0,0.15)" : "rgba(255,255,255,0.06)",
            color: i === 0 ? "#FFD700" : "rgba(255,255,255,0.7)",
            border: `1px solid ${i === 0 ? "rgba(255,215,0,0.4)" : "rgba(255,255,255,0.1)"}`,
            cursor: "pointer",
          }}>{f}</span>
        ))}
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        {items.map((it, k) => (
          <div key={k} style={{
            display: "flex", alignItems: "center", gap: 14, padding: 14,
            background: "rgba(12,10,24,0.6)", border: "1px solid rgba(255,255,255,0.08)",
            borderRadius: 14, backdropFilter: "blur(10px)",
          }}>
            <div style={{
              width: 50, height: 50, borderRadius: 12, flexShrink: 0,
              background: `linear-gradient(135deg, ${it.tone}33, ${it.tone}11)`,
              border: `1px solid ${it.tone}55`,
              display: "flex", alignItems: "center", justifyContent: "center",
              color: it.tone, fontFamily: "Orkun, serif", fontSize: 20,
              textShadow: `0 0 10px ${it.tone}aa`,
            }}>{it.roll}</div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ fontSize: 11, color: it.tone, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>{it.type}</div>
              <div style={{ fontSize: 14, color: "#fff", marginTop: 2, whiteSpace: "nowrap", textOverflow: "ellipsis", overflow: "hidden" }}>{it.q}</div>
              <div style={{ fontSize: 11, color: "rgba(255,255,255,0.45)", marginTop: 2 }}>{it.when}</div>
            </div>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.4)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m9 18 6-6-6-6"/></svg>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { HomeScreen, KehanetlerTab });
