/* global React */
const { useState } = React;

function Tamga({ src, size = 60, alt = "" }) {
  return <img src={src} alt={alt} style={{ height: size, width: "auto", objectFit: "contain" }} />;
}

function RuneButton({ icon, label, onClick }) {
  const [hover, setHover] = useState(false);
  return (
    <button
      onClick={onClick}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        background: "rgba(0,0,0,0.2)",
        border: "1px solid rgba(255,255,255,0.1)",
        borderRadius: 15,
        padding: 16,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 10,
        color: "#fff",
        fontFamily: "'Cinzel Decorative', serif",
        fontWeight: 700,
        letterSpacing: "1.5px",
        fontSize: 14,
        textShadow: "0 0 5px rgba(0,0,0,0.85)",
        boxShadow: hover ? "0 0 25px 3px rgba(0,255,255,0.6)" : "none",
        transition: "box-shadow 200ms",
        cursor: "pointer",
        aspectRatio: "1 / 1",
      }}
    >
      <img src={icon} style={{ height: 60, objectFit: "contain" }} alt="" />
      <div>{label}</div>
    </button>
  );
}

function PrimaryButton({ children, onClick, disabled }) {
  return (
    <button
      disabled={disabled}
      onClick={onClick}
      style={{
        background: disabled ? "rgba(255,160,0,0.3)" : "#FFA000",
        color: "#000",
        border: 0,
        borderRadius: 25,
        padding: "15px 40px",
        fontFamily: "'Cinzel Decorative', serif",
        fontWeight: 700,
        fontSize: 18,
        letterSpacing: "1px",
        minHeight: 50,
        cursor: disabled ? "not-allowed" : "pointer",
      }}
    >
      {children}
    </button>
  );
}

function Dice({ value, idle }) {
  const pips = { 1: "o", 2: "oo", 3: "ooo", 4: "oooo" };
  return (
    <div
      style={{
        width: 72,
        height: 72,
        borderRadius: 12,
        background: "rgba(0,0,0,0.3)",
        border: "2px solid rgba(255,255,255,0.7)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        color: idle ? "rgba(255,255,255,0.3)" : "#fff",
        fontSize: 28,
        fontWeight: 700,
        letterSpacing: -2,
      }}
    >
      {idle ? "?" : pips[value]}
    </div>
  );
}

function Card({ children, variant = "default", style }) {
  const base = {
    default: {
      background: "rgba(20,18,38,0.8)",
      border: "1px solid rgba(255,255,255,0.2)",
      borderRadius: 15,
      padding: 20,
    },
    soft: {
      background: "rgba(0,0,0,0.5)",
      border: "1px solid rgba(255,255,255,0.1)",
      borderRadius: 12,
      padding: 16,
    },
    amber: {
      background: "rgba(0,0,0,0.5)",
      border: "1px solid rgba(255,193,7,0.5)",
      borderRadius: 12,
      padding: 16,
    },
  }[variant];
  return <div style={{ ...base, ...style }}>{children}</div>;
}

function LevelMeter({ level, points, goal }) {
  const pct = Math.min(100, (points / goal) * 100);
  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between", fontSize: 14, marginBottom: 8, color: "#fff" }}>
        <span style={{ fontFamily: "'Cinzel Decorative', serif", letterSpacing: "1.5px", color: "#FFC107" }}>Seviye {level}</span>
        <span style={{ color: "rgba(255,255,255,0.7)" }}>{points} / {goal} DP</span>
      </div>
      <div style={{ height: 10, background: "#424242", borderRadius: 4, overflow: "hidden" }}>
        <div style={{ height: "100%", width: `${pct}%`, background: "#FFC107" }} />
      </div>
    </div>
  );
}

function Scrim({ children, bg, opacity = 0.5 }) {
  return (
    <div style={{ position: "absolute", inset: 0, overflow: "hidden" }}>
      <img src={bg} style={{ position: "absolute", inset: 0, width: "100%", height: "100%", objectFit: "cover" }} />
      <div style={{ position: "absolute", inset: 0, background: `rgba(0,0,0,${opacity})` }} />
      <div style={{ position: "relative", width: "100%", height: "100%" }}>{children}</div>
    </div>
  );
}

function AppBar({ title, onBack }) {
  return (
    <div style={{
      position: "absolute", top: 0, left: 0, right: 0, height: 56,
      display: "flex", alignItems: "center", padding: "0 12px",
      color: "#fff", zIndex: 10,
    }}>
      {onBack && (
        <button onClick={onBack} style={{ background: "transparent", border: 0, color: "#fff", fontSize: 24, cursor: "pointer", width: 40, height: 40 }}>‹</button>
      )}
      <div style={{
        flex: 1, textAlign: "center",
        fontFamily: "'Cinzel Decorative', serif", fontWeight: 700, letterSpacing: "1.5px",
        textShadow: "0 0 10px rgba(0,0,0,0.9)", fontSize: 18,
      }}>{title}</div>
      <div style={{ width: 40 }} />
    </div>
  );
}

Object.assign(window, { Tamga, RuneButton, PrimaryButton, Dice, Card, LevelMeter, Scrim, AppBar });
