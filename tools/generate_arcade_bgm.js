/** Generate six original, 90-second arcade BGM WAV files with Node only. */
const fs = require("fs");
const path = require("path");

const RATE = 22050, SECONDS = 90, OUT = path.join("assets", "audio", "music");
let randomState = 20260819;
const random = () => ((randomState = (randomState * 1664525 + 1013904223) >>> 0) / 4294967296);
const midi = n => 440 * Math.pow(2, (n - 69) / 12);
const env = (t, len, a, r) => t < 0 || t >= len ? 0 : t < a ? t / a : t > len - r ? Math.max(0, (len - t) / r) : 1;
function osc(shape, p) {
  p -= Math.floor(p);
  if (shape === "square") return p < .5 ? 1 : -1;
  if (shape === "triangle") return 1 - 4 * Math.abs(p - .5);
  if (shape === "pulse") return p < .25 ? 1 : -.72;
  return 2 * p - 1;
}
function addNote(buf, start, len, pitch, vol, shape, pan = 0, vib = 0) {
  const begin = Math.max(0, Math.floor(start * RATE)), end = Math.min(buf.length / 2, Math.floor((start + len) * RATE)), freq = midi(pitch);
  const left = vol * (1 - pan) * .5, right = vol * (1 + pan) * .5;
  for (let i = begin; i < end; ++i) {
    const t = i / RATE - start, f = 1 + vib * Math.sin(t * Math.PI * 10);
    const sample = osc(shape, t * freq * f) * env(t, len, .008, Math.min(.08, len * .3));
    buf[i * 2] += sample * left; buf[i * 2 + 1] += sample * right;
  }
}
function kick(buf, start, vol) {
  const begin = Math.floor(start * RATE), length = Math.floor(.16 * RATE);
  for (let n = 0; n < length && begin + n < buf.length / 2; ++n) {
    const t = n / RATE, value = Math.sin(2 * Math.PI * (145 * Math.exp(-t * 22) + 38) * t) * Math.exp(-t * 20) * vol;
    buf[(begin + n) * 2] += value * .5; buf[(begin + n) * 2 + 1] += value * .5;
  }
}
function noise(buf, start, vol, length, decay) {
  const begin = Math.floor(start * RATE);
  for (let n = 0; n < Math.floor(length * RATE) && begin + n < buf.length / 2; ++n) {
    const value = (random() * 2 - 1) * Math.exp(-(n / RATE) * decay) * vol * .22;
    buf[(begin + n) * 2] += value; buf[(begin + n) * 2 + 1] += value;
  }
}
function build(name, bpm, root, mode, melody, chords, intensity, cosmic) {
  const buf = new Float32Array(SECONDS * RATE * 2), beat = 60 / bpm, bar = beat * 4, bars = Math.ceil(SECONDS / bar), bass = [0, 0, 7, 0, 5, 0, 7, 0];
  for (let measure = 0; measure < bars; ++measure) {
    const start = measure * bar, section = measure % 16, chord = chords[Math.floor(measure / 2) % chords.length], transposed = root + chord[0];
    for (let s = 0; s < 8; ++s) {
      const time = start + s * beat * .5;
      noise(buf, time, .07 * intensity, .035, 90);
      if (s === 0 || s === 4) kick(buf, time, .25 * intensity);
      if (s === 2 || s === 6) noise(buf, time, .16 * intensity, .11, 31);
      const arp = root + chord[s % chord.length] + (s >= 4 ? 12 : 0);
      addNote(buf, time, beat * .43, arp, .11 * intensity, "pulse", s % 2 ? .32 : -.32);
      const low = (s === 0 || s === 3 || s === 4 || s === 7) ? chord[0] : bass[s];
      addNote(buf, time, beat * .37, root - 12 + low, .17 * intensity, "square", -.08);
    }
    if (section >= 2 || name === "pause") for (let s = 0; s < 8; ++s) {
      const degree = melody[(measure * 3 + s) % melody.length];
      const pitch = root + mode[degree % mode.length] + 12 + (degree >= mode.length ? 12 : 0);
      addNote(buf, start + s * beat * .5, beat * (s === 7 ? .8 : .38), pitch, .13 * intensity, "square", .12, cosmic ? .006 : 0);
    }
    if ([8, 9, 10, 11, 14, 15].includes(section)) for (const s of [1, 5]) {
      addNote(buf, start + s * beat * .5, beat * .65, transposed + chord[(s + measure) % chord.length] + 24, .075 * intensity, "triangle", s === 1 ? -.45 : .45);
    }
  }
  for (let i = Math.floor((SECONDS - 1.5) * RATE); i < SECONDS * RATE; ++i) { const f = (SECONDS * RATE - i) / (1.5 * RATE); buf[i * 2] *= f; buf[i * 2 + 1] *= f; }
  return buf;
}
const tracks = [
  ["main_title",150,48,[0,2,3,7,8,10],[0,2,4,5,4,2,1,2],[[0,3,7],[8,0,3],[5,8,0],[7,10,2]],1,false],
  ["ground",136,53,[0,2,4,5,7,9,11],[0,2,4,2,5,4,2,1],[[0,4,7],[5,9,0],[7,11,2],[4,7,11]],.82,false],
  ["planetary",148,50,[0,2,3,5,7,9,10],[0,3,5,6,4,2,4,1],[[0,3,7],[5,8,0],[10,2,5],[7,10,2]],.96,true],
  ["galactic",158,40,[0,1,3,5,7,8,10],[0,3,5,7,6,4,2,1],[[0,3,7],[8,0,3],[10,1,5],[7,10,1]],1.08,true],
  ["result",128,48,[0,2,4,5,7,9,11],[0,2,4,7,6,4,2,0],[[0,4,7],[5,9,0],[3,7,10],[0,4,7]],.76,false],
  ["pause",100,45,[0,2,3,5,7,8,10],[0,2,4,2,1,2,4,5],[[0,3,7],[5,8,0],[7,10,2],[3,7,10]],.48,true],
];
function writeWav(file, samples) {
  let peak = 1; for (const sample of samples) peak = Math.max(peak, Math.abs(sample));
  const dataSize = samples.length * 2, output = Buffer.alloc(44 + dataSize);
  output.write("RIFF", 0); output.writeUInt32LE(36 + dataSize, 4); output.write("WAVEfmt ", 8); output.writeUInt32LE(16, 16); output.writeUInt16LE(1, 20); output.writeUInt16LE(2, 22); output.writeUInt32LE(RATE, 24); output.writeUInt32LE(RATE * 4, 28); output.writeUInt16LE(4, 32); output.writeUInt16LE(16, 34); output.write("data", 36); output.writeUInt32LE(dataSize, 40);
  for (let i = 0; i < samples.length; ++i) output.writeInt16LE(Math.max(-32767, Math.min(32767, Math.round(samples[i] / peak * .82 * 32767))), 44 + i * 2);
  fs.writeFileSync(file, output);
}
fs.mkdirSync(OUT, { recursive: true });
for (const track of tracks) { const [name, ...args] = track; writeWav(path.join(OUT, `${name}.wav`), build(name, ...args)); console.log(`Generated ${name}.wav (${SECONDS}s)`); }
