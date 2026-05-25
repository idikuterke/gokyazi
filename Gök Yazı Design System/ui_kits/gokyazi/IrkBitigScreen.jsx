/* global React, AppBar */
const { useState, useEffect, useRef } = React;

function IrkBitigScreen({ onBack, onSave }) {
  // Stages: prompt → rolling → result
  const [stage, setStage] = useState("prompt");
  const [niyet, setNiyet] = useState("");
  const [focused, setFocused] = useState(false);
  const [dice, setDice] = useState([1, 1, 1]);
  const [rollKey, setRollKey] = useState(0);
  const [ritualMsg, setRitualMsg] = useState(0);
  const [tab, setTab] = useState("gokturkce"); // result tab
  const [saved, setSaved] = useState(false);
  const [entered, setEntered] = useState(false);

  useEffect(() => { const t = setTimeout(() => setEntered(true), 60); return () => clearTimeout(t); }, []);

  const messages = [
    "Niyetine ve sorunuza odaklan…",
    "Ata ruhları seni dinliyor…",
    "Irk Bitig yol gösterecek…",
  ];

  const rollDice = () => {
    if (!niyet.trim()) return;
    setStage("rolling");
    setRitualMsg(0);
    // Davul ses cue (placeholder)
    try { window?.dispatchEvent(new CustomEvent("gokyazi:drum")); } catch {}
    const t1 = setTimeout(() => setRitualMsg(1), 1700);
    const t2 = setTimeout(() => setRitualMsg(2), 3400);
    const t3 = setTimeout(() => {
      const newDice = [
        Math.ceil(Math.random() * 4),
        Math.ceil(Math.random() * 4),
        Math.ceil(Math.random() * 4),
      ];
      setDice(newDice);
      setRollKey(k => k + 1);
      setStage("result");
      setTab("gokturkce");
      setSaved(false);
    }, 5200);
    // Cleanup not strictly needed in tap flow
  };

  const reset = () => {
    setStage("prompt"); setNiyet(""); setSaved(false); setRitualMsg(0);
  };

  return (
    <div style={{ position: "relative", width: "100%", height: "100%", background: "#0C0A18", overflow: "hidden" }}>
      {/* Background */}
      <img src="../../assets/bg_fal_ekrani.png" style={{
        position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover",
        opacity: 0.45,
      }} />
      <div style={{
        position: "absolute", inset: 0,
        background: "radial-gradient(ellipse at 50% 30%, rgba(91,33,182,0.45) 0%, rgba(12,10,24,0.95) 65%, #0C0A18 100%)",
      }} />

      {/* App bar */}
      <div style={{
        position: "absolute", top: 0, left: 0, right: 0, height: 56,
        display: "flex", alignItems: "center", padding: "0 8px", zIndex: 20,
        opacity: entered ? 1 : 0, transition: "opacity 500ms ease",
      }}>
        <button onClick={onBack} aria-label="Geri" style={{
          width: 40, height: 40, borderRadius: 20, background: "rgba(255,255,255,0.06)",
          border: "1px solid rgba(255,215,0,0.15)", color: "#fff", cursor: "pointer",
          display: "flex", alignItems: "center", justifyContent: "center", backdropFilter: "blur(10px)",
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div style={{
          flex: 1, textAlign: "center", color: "#fff",
          fontFamily: "Orkun, serif", fontSize: 26, letterSpacing: 1.5,
          textShadow: "0 0 16px rgba(255,193,7,0.5), 0 2px 6px rgba(0,0,0,0.9)",
          marginRight: 40,
        }}>𐰃𐰼𐰴 : 𐰋𐰃𐱅𐰃𐰏</div>
      </div>

      {/* Stage content */}
      <div style={{ position: "absolute", inset: "56px 0 0", overflow: "auto" }}>
        {stage === "prompt" && <PromptStage niyet={niyet} setNiyet={setNiyet} focused={focused} setFocused={setFocused} rollDice={rollDice} entered={entered} />}
        {stage === "rolling" && <RollingStage messages={messages} ritualMsg={ritualMsg} dice={dice} />}
        {stage === "result" && (
          <ResultStage
            niyet={niyet}
            dice={dice}
            rollKey={rollKey}
            tab={tab}
            setTab={setTab}
            onAgain={reset}
            onSave={() => { setSaved(true); onSave && onSave(); }}
            saved={saved}
          />
        )}
      </div>
    </div>
  );
}

function PromptStage({ niyet, setNiyet, focused, setFocused, rollDice, entered }) {
  return (
    <div style={{
      minHeight: "100%", boxSizing: "border-box",
      padding: "32px 28px 40px", display: "flex", flexDirection: "column",
      gap: 28, alignItems: "center",
    }}>
      {/* Subtitle */}
      <div style={{
        color: "rgba(224,224,224,0.85)", fontSize: 13, letterSpacing: "0.16em",
        textTransform: "uppercase", textAlign: "center", maxWidth: 280, lineHeight: 1.5,
        textShadow: "0 0 12px rgba(0,0,0,0.9)",
        opacity: entered ? 1 : 0, transform: entered ? "translateY(0)" : "translateY(8px)",
        transition: "opacity 700ms ease, transform 700ms cubic-bezier(0.16,1,0.3,1)",
      }}>Niyetini belirle · Zarları at · Kadim sözü dinle</div>

      {/* Hero dice illustration */}
      <div style={{
        width: 200, height: 180, position: "relative",
        opacity: entered ? 1 : 0, transform: entered ? "scale(1)" : "scale(0.92)",
        transition: "opacity 800ms ease 150ms, transform 800ms cubic-bezier(0.16,1,0.3,1) 150ms",
      }}>
        <div style={{
          position: "absolute", inset: -20, borderRadius: "50%",
          background: "radial-gradient(circle, rgba(255,193,7,0.22) 0%, transparent 65%)",
          animation: "ib-shimmer 3.4s ease-in-out infinite",
        }} />
        <div style={{
          position: "absolute", inset: 0, display: "flex", alignItems: "center", justifyContent: "center", gap: 14,
          animation: "ib-float 2.8s ease-in-out infinite",
        }}>
          {["o","oo","oooo"].map((pip, i) => (
            <div key={i} style={{
              width: 64, height: 64, borderRadius: 12,
              background: "linear-gradient(155deg, rgba(40,30,80,0.92), rgba(12,10,24,0.95))",
              border: "1.5px solid rgba(255,193,7,0.55)",
              boxShadow: "0 12px 28px rgba(0,0,0,0.55), 0 0 22px rgba(255,193,7,0.25), inset 0 1px 0 rgba(255,255,255,0.08)",
              display: "flex", alignItems: "center", justifyContent: "center",
              color: "#FFD56B", fontSize: 24, fontWeight: 700, letterSpacing: -2,
              transform: `rotate(${[-6,0,6][i]}deg) translateY(${[6,0,8][i]}px)`,
            }}>{pip}</div>
          ))}
        </div>
      </div>

      {/* Niyet field */}
      <div style={{
        width: "100%", maxWidth: 380,
        opacity: entered ? 1 : 0, transform: entered ? "translateY(0)" : "translateY(12px)",
        transition: "opacity 700ms ease 300ms, transform 700ms cubic-bezier(0.16,1,0.3,1) 300ms",
      }}>
        <label style={{
          display: "block", color: "rgba(255,255,255,0.55)", fontSize: 11,
          letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 8, marginLeft: 4,
        }}>Niyetin</label>
        <div style={{
          background: "rgba(12,10,24,0.65)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
          border: `1px solid ${focused ? "rgba(255,193,7,0.7)" : "rgba(255,215,0,0.2)"}`,
          borderRadius: 16, padding: 14,
          boxShadow: focused ? "0 0 0 4px rgba(255,193,7,0.08), 0 0 22px rgba(255,193,7,0.18)" : "none",
          transition: "border-color 200ms, box-shadow 200ms",
        }}>
          <textarea value={niyet} onChange={e => setNiyet(e.target.value)}
            onFocus={() => setFocused(true)} onBlur={() => setFocused(false)}
            placeholder="Sorunu veya niyetini yaz…  Örnek: yeni iş teklifimi kabul etmeli miyim?"
            rows={3}
            style={{
              width: "100%", background: "transparent", border: 0, outline: "none",
              color: "#fff", fontSize: 14, lineHeight: 1.6, fontFamily: "inherit",
              resize: "none", padding: 0, boxSizing: "border-box",
            }}
          />
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 6, fontSize: 11, color: "rgba(255,255,255,0.4)" }}>
            <span>{niyet.length} / 200</span>
            <span style={{ color: "rgba(255,215,0,0.6)" }}>Sessizce düşün, sonra yaz.</span>
          </div>
        </div>
      </div>

      {/* CTA */}
      <button onClick={rollDice} disabled={!niyet.trim()} style={{
        width: "100%", maxWidth: 380, height: 60, borderRadius: 14, border: 0,
        background: niyet.trim() ? "linear-gradient(180deg, #E5B225 0%, #C99411 100%)" : "rgba(212,160,23,0.35)",
        color: "#0C0A18",
        fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, fontSize: 17,
        letterSpacing: "0.18em", textTransform: "uppercase", cursor: niyet.trim() ? "pointer" : "not-allowed",
        boxShadow: niyet.trim() ? "0 8px 28px rgba(212,160,23,0.4), inset 0 1px 0 rgba(255,255,255,0.4)" : "none",
        display: "flex", alignItems: "center", justifyContent: "center", gap: 12,
        transition: "transform 180ms, filter 180ms",
        opacity: entered ? 1 : 0, transform: entered ? "translateY(0)" : "translateY(16px)",
        animation: niyet.trim() ? "ib-pulse 2.6s ease-in-out infinite" : "none",
      }}
        onMouseDown={e => niyet.trim() && (e.currentTarget.style.transform = "scale(0.98)")}
        onMouseUp={e => (e.currentTarget.style.transform = "scale(1)")}
        onMouseLeave={e => (e.currentTarget.style.transform = "scale(1)")}
      >
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#0C0A18" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
          <rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="8" cy="8" r="1.2" fill="#0C0A18"/><circle cx="16" cy="16" r="1.2" fill="#0C0A18"/><circle cx="16" cy="8" r="1.2" fill="#0C0A18"/><circle cx="8" cy="16" r="1.2" fill="#0C0A18"/>
        </svg>
        Zar At
      </button>

      <style>{`
        @keyframes ib-float { 0%,100% { transform: translateY(0);} 50% { transform: translateY(-9px);} }
        @keyframes ib-shimmer { 0%,100% { opacity: 0.55; transform: scale(1);} 50% { opacity: 1; transform: scale(1.06);} }
        @keyframes ib-pulse { 0%,100% { box-shadow: 0 8px 28px rgba(212,160,23,0.4), inset 0 1px 0 rgba(255,255,255,0.4);} 50% { box-shadow: 0 10px 32px rgba(212,160,23,0.55), 0 0 30px rgba(255,193,7,0.4), inset 0 1px 0 rgba(255,255,255,0.4);} }
      `}</style>
    </div>
  );
}

function RollingStage({ messages, ritualMsg, dice }) {
  return (
    <div style={{
      minHeight: "100%", boxSizing: "border-box",
      padding: "0 28px", display: "flex", flexDirection: "column", justifyContent: "center", alignItems: "center", gap: 40,
    }}>
      {/* Spinning dice */}
      <div style={{ display: "flex", gap: 18 }}>
        {[0,1,2].map(k => (
          <div key={k} style={{
            width: 80, height: 80, borderRadius: 14, perspective: 600,
            animation: `ib-tumble 0.9s ease-in-out ${k * 0.15}s infinite`,
            transformStyle: "preserve-3d",
            background: "linear-gradient(155deg, rgba(70,40,140,0.85), rgba(12,10,24,0.95))",
            border: "1.5px solid rgba(255,193,7,0.6)",
            boxShadow: "0 16px 36px rgba(0,0,0,0.55), 0 0 28px rgba(255,193,7,0.4), inset 0 1px 0 rgba(255,255,255,0.1)",
            display: "flex", alignItems: "center", justifyContent: "center",
            color: "#FFD56B", fontFamily: "Orkun, serif", fontSize: 30,
            textShadow: "0 0 14px rgba(255,193,7,0.8)",
          }}>
            {["𐰋","𐰃","𐱅"][k]}
          </div>
        ))}
      </div>

      {/* Ritual message */}
      <div style={{
        minHeight: 70, textAlign: "center", maxWidth: 320,
      }}>
        {messages.map((m, i) => (
          <div key={i} style={{
            position: "absolute", left: 0, right: 0,
            color: "#FFC107", fontSize: 16, fontStyle: "italic",
            letterSpacing: "0.04em", textShadow: "0 0 16px rgba(255,193,7,0.5), 0 2px 6px rgba(0,0,0,0.9)",
            opacity: ritualMsg === i ? 1 : 0,
            transform: `translateY(${ritualMsg === i ? 0 : (ritualMsg > i ? -10 : 10)}px)`,
            transition: "opacity 600ms ease, transform 600ms cubic-bezier(0.16,1,0.3,1)",
          }}>{m}</div>
        ))}
      </div>

      {/* Subtle drum waveform */}
      <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
        {[0,1,2,3,4,5,6,7,8].map(k => (
          <div key={k} style={{
            width: 3, height: 6, borderRadius: 2,
            background: "rgba(255,193,7,0.55)",
            animation: `ib-wave 1.2s ease-in-out ${k * 0.08}s infinite`,
          }} />
        ))}
      </div>

      <style>{`
        @keyframes ib-tumble {
          0% { transform: rotateX(0) rotateY(0); }
          50% { transform: rotateX(180deg) rotateY(90deg); }
          100% { transform: rotateX(360deg) rotateY(180deg); }
        }
        @keyframes ib-wave {
          0%,100% { transform: scaleY(1); opacity: 0.4; }
          50% { transform: scaleY(5); opacity: 1; }
        }
      `}</style>
    </div>
  );
}

function ResultStage({ niyet, dice, rollKey, tab, setTab, onAgain, onSave, saved }) {
  // Static sample reading (in real app: lookup `${dice.join('-')}` in fallar.json)
  const reading = {
    gokturkce: "𐰋𐰃𐱅𐰃𐰓𐰢 𐰢𐰤 𐰖𐰃𐰞 𐰆𐰞𐰞𐰸 𐰇𐰲𐰇𐰤 𐰚𐰠𐱅𐰢",
    translit: "Bitidim men yıl olluk üçün kelti",
    turkish: "Yazdım. Yıllık iş için geldi: yorgun bir kara at gördüm, ayakları taşa değdi ama gözleri parlaktı.",
    modern: "Uzun bir çabanın sonuna yaklaşıyorsun. Yorgun görünsen de gözlerin hâlâ açık — bu işaret hayırdır.",
    ai: "Niyetin etrafında dolaşan iki güç var: biri seni bekletiyor, diğeri ileri itiyor. Bekleyeni dinleme. Hareket et — küçük bir adım yeterli. Üç gün içinde bir mesaj veya teklif gelecek; onu hafife alma.",
  };

  const tabs = [
    { k: "gokturkce", label: "Göktürkçe" },
    { k: "translit", label: "Okunuşu" },
    { k: "turkish", label: "Anlamı" },
    { k: "modern", label: "Modern" },
    { k: "ai", label: "AI Yorum" },
  ];

  return (
    <div style={{
      minHeight: "100%", boxSizing: "border-box",
      padding: "24px 20px 32px", display: "flex", flexDirection: "column", gap: 18,
    }}>
      {/* Question echo */}
      <div style={{
        textAlign: "center", color: "rgba(224,224,224,0.7)", fontSize: 13, fontStyle: "italic",
        textShadow: "0 0 10px rgba(0,0,0,0.9)", padding: "0 12px", lineHeight: 1.6,
      }}>
        Sorduğun: <span style={{ color: "rgba(255,215,0,0.9)" }}>“{niyet}”</span>
      </div>

      {/* Dice result row */}
      <div key={rollKey} style={{ display: "flex", justifyContent: "center", gap: 14,
        animation: "ib-reveal 700ms cubic-bezier(0.16,1,0.3,1) both" }}>
        {dice.map((v, k) => {
          const pip = v === 1 ? "o" : v === 2 ? "oo" : v === 3 ? "ooo" : "oooo";
          return (
            <div key={k} style={{
              width: 64, height: 64, borderRadius: 12,
              background: "linear-gradient(155deg, rgba(40,30,80,0.92), rgba(12,10,24,0.95))",
              border: "1.5px solid rgba(255,193,7,0.7)",
              boxShadow: "0 10px 24px rgba(0,0,0,0.5), 0 0 18px rgba(255,193,7,0.3), inset 0 1px 0 rgba(255,255,255,0.08)",
              display: "flex", alignItems: "center", justifyContent: "center",
              color: "#FFD56B", fontSize: 24, fontWeight: 700, letterSpacing: -2,
              animationDelay: `${k * 100}ms`,
              animation: "ib-popin 500ms cubic-bezier(0.34,1.56,0.64,1) both",
            }}>{pip}</div>
          );
        })}
      </div>
      <div style={{ textAlign: "center", color: "rgba(255,255,255,0.5)", fontSize: 11, letterSpacing: "0.15em", textTransform: "uppercase", marginTop: -8 }}>
        Kombinasyon · {dice.join("-")}
      </div>

      {/* Tabs */}
      <div style={{
        display: "flex", gap: 6, overflowX: "auto", padding: "0 4px 4px",
        scrollbarWidth: "none",
      }}>
        {tabs.map(t => {
          const on = tab === t.k;
          const isAi = t.k === "ai";
          return (
            <button key={t.k} onClick={() => setTab(t.k)} style={{
              flex: "0 0 auto", padding: "8px 14px", borderRadius: 18,
              background: on ? (isAi ? "rgba(77,208,225,0.18)" : "rgba(255,193,7,0.18)") : "rgba(255,255,255,0.05)",
              border: `1px solid ${on ? (isAi ? "rgba(77,208,225,0.6)" : "rgba(255,193,7,0.5)") : "rgba(255,255,255,0.08)"}`,
              color: on ? (isAi ? "#4DD0E1" : "#FFC107") : "rgba(255,255,255,0.65)",
              fontSize: 12, fontWeight: 600, letterSpacing: "0.06em",
              cursor: "pointer", whiteSpace: "nowrap",
              transition: "all 220ms",
            }}>{t.label}{isAi && " ✦"}</button>
          );
        })}
      </div>

      {/* Content card */}
      <div style={{
        background: "rgba(12,10,24,0.7)", backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
        border: "1px solid rgba(255,215,0,0.2)", borderRadius: 18, padding: 22,
        minHeight: 180,
      }}>
        {tab === "gokturkce" && (
          <div style={{
            fontFamily: "Orkun, serif", fontSize: 28, lineHeight: 1.5,
            color: "#FFC107", textAlign: "center", letterSpacing: 1.5,
            textShadow: "0 0 22px rgba(255,193,7,0.4)",
            wordBreak: "break-word",
          }}>{reading.gokturkce}</div>
        )}
        {tab === "translit" && (
          <div style={{ color: "rgba(255,255,255,0.92)", fontSize: 17, fontStyle: "italic", lineHeight: 1.7, textAlign: "center" }}>
            {reading.translit}
          </div>
        )}
        {tab === "turkish" && (
          <div>
            <div style={{ color: "#FFE082", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 10, fontWeight: 600 }}>Anlamı</div>
            <div style={{ color: "#fff", fontSize: 15, lineHeight: 1.7 }}>{reading.turkish}</div>
          </div>
        )}
        {tab === "modern" && (
          <div>
            <div style={{ color: "#FFE082", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", marginBottom: 10, fontWeight: 600 }}>Modern Yorum</div>
            <div style={{ color: "#fff", fontSize: 15, lineHeight: 1.7 }}>{reading.modern}</div>
          </div>
        )}
        {tab === "ai" && (
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 10 }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#4DD0E1" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 3v18M3 12h18M5.5 5.5l13 13M18.5 5.5l-13 13"/></svg>
              <div style={{ color: "#4DD0E1", fontSize: 11, letterSpacing: "0.16em", textTransform: "uppercase", fontWeight: 600 }}>Sorunuza AI Yanıtı</div>
            </div>
            <div style={{ color: "rgba(255,255,255,0.92)", fontSize: 15, lineHeight: 1.7 }}>{reading.ai}</div>
          </div>
        )}
      </div>

      {/* Actions */}
      <div style={{ display: "flex", gap: 10, marginTop: 4 }}>
        <button onClick={onSave} disabled={saved} style={{
          flex: 1, height: 52, borderRadius: 14, cursor: saved ? "default" : "pointer",
          background: saved ? "rgba(76,175,80,0.18)" : "rgba(255,255,255,0.05)",
          border: `1px solid ${saved ? "rgba(76,175,80,0.55)" : "rgba(255,215,0,0.35)"}`,
          color: saved ? "#86EFAC" : "#FFD56B", fontWeight: 600, fontSize: 13,
          letterSpacing: "0.12em", textTransform: "uppercase",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
        }}>
          {saved ? (
            <><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5"/></svg>Kaydedildi</>
          ) : (
            <><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>Günlüğüme Kaydet</>
          )}
        </button>
        <button onClick={onAgain} style={{
          flex: 1, height: 52, borderRadius: 14, cursor: "pointer",
          background: "linear-gradient(180deg, #E5B225 0%, #C99411 100%)",
          border: 0, color: "#0C0A18", fontWeight: 700, fontSize: 13,
          fontFamily: "'Cinzel Decorative', serif", letterSpacing: "0.16em", textTransform: "uppercase",
          boxShadow: "0 8px 22px rgba(212,160,23,0.35), inset 0 1px 0 rgba(255,255,255,0.4)",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
        }}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0C0A18" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12a9 9 0 1 1-3-6.7L21 8"/><path d="M21 3v5h-5"/></svg>
          Yeniden Sor
        </button>
      </div>

      <style>{`
        @keyframes ib-popin { 0% { transform: scale(0.5) rotate(-90deg); opacity: 0;} 100% { transform: scale(1) rotate(0); opacity: 1;} }
        @keyframes ib-reveal { 0% { opacity: 0; transform: translateY(10px);} 100% { opacity: 1; transform: translateY(0);} }
      `}</style>
    </div>
  );
}

Object.assign(window, { IrkBitigScreen });
