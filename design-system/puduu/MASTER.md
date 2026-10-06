# Puduu — "Aurora Gloss" Design System v11
**Status:** 🔒 LOCKED OVERRIDES — identitas brand Puduu dipertahankan, eksekusi diglosskan.
**Tanggal:** 2026-10-06 · **Platform:** Flutter (mobile-first, maxWidth 560)

> Skill ui-ux-pro-max di-query 2x untuk arah "glossy vibrant glassmorphism" —
> keduanya me-return Brutalism (mismatch domain, retry gagal). Fallback manual
> eksplisit per aturan skill: arah ditentukan dari referensi modern
> (iOS 26 liquid glass, Headspace, Duolingo, Arc, Raycast).

## 1. Prinsip
1. **Calm brand, premium finish.** Copy-voice Puduu ("Done beats perfect",
   "Slow is still moving") TIDAK berubah. Yang berubah: material & cahaya.
2. **Gloss = cahaya dari atas.** Setiap surface punya sheen: gradient putih
   55% → transparan di 35% teratas, + inner highlight 1px putih 40%.
3. **Depth berwarna, bukan abu.** Shadow selalu tint warna aksen
   (teal 14%, bukan hitam 10%).
4. **Satu aksen, banyak cahaya.** Teal tetap satu-satunya warna primer.
   Amber/moss/sky/lavender hanya untuk kategori & data.

## 2. Warna
| Token | Hex | Pakai |
|---|---|---|
| `ink` | #0F1F1E | teks utama |
| `soft` | #3E5452 | teks sekunder |
| `mute` | #7A8F8D | meta |
| `bg` | #F3F7F6 | base scaffold |
| `teal` | #0E9384 | primer |
| `tealDeep` | #0B6B5F | ujung gradient |
| `mint` | #2DD4BF | highlight gradient |
| `amber` | #F59E0B | kategori Reset |
| `peach` | #FDBA74 | gradient Reset |
| `moss` | #4D7C0F | kategori Habits |
| `lime` | #A3E635 | gradient Habits |
| `sky` | #0EA5E9 | kategori Focus |
| `ice` | #7DD3FC | gradient Focus |
| `lav` | #8B5CF6 | kategori Evening |
| `lilac` | #C4B5FD | gradient Evening |
| `gold` | #EAB308 | shimmer Pro |
| `danger` | #DC2626 | destruktif |

### Gradient kunci
- `heroTeal`: linear 135° `#0B3B36 → #0E9384 → #14B8A6`
- `btnTeal`: linear 180° `#17A894 → #0E9384 → #0B6B5F` (sheen di atas)
- `auroraBlob`: radial washes — mint `#DDF3F0`, peach `#FDEBD3`, lilac `#E9E4FA`
- `tileFocus`: `#0EA5E9 → #7DD3FC` · `tileReset`: `#F59E0B → #FDBA74`
  `tileHabits`: `#4D7C0F → #A3E635` · `tileEvening`: `#8B5CF6 → #C4B5FD`
- `goldSheen`: linear `#FDE68A → #EAB308 → #B45309` (Pro/paywall)

## 3. Tipografi (font sudah ada di assets)
- Display: **Outfit** 700, -0.5 spacing, 24–58px (timer Focus 64px)
- UI: **Work Sans** 400/500/600/700
- Section label: Outfit 700, 11px, tracking 1.6, uppercase, warna tealDeep

## 4. Komponen
- **AuroraBackground**: Stack 3 radial blob (blur 60) di atas `bg`. Dipakai di
  semua page via `GlossScaffold`.
- **GlossCard**: radius 24, gradient `#FFFFFF → #F6FAF9`, border putih 60%
  1px, shadow teal 12% blur 18 y8, sheen overlay.
- **GlossHero** (pengganti DarkHero): `heroTeal` + 2 blob + sheen,
  radius 28, glow shadow teal 35%; tag pill kaca; progress bar gradient
  putih→mint dengan glow.
- **GlossButton**: pill radius 18, `btnTeal`, teks putih Outfit 700,
  shadow teal 35% blur 16; secondary = kaca putih 25% + border putih 40%.
- **CategoryTile**: 56px rounded-20, gradient kategori + ikon putih,
  shadow warna kategori 30%.
- **TaskCard**: GlossCard + tile gradient 40px + tombol aksi pill kecil
  gradient; checkbox = lingkaran gradient saat done.
- **GlassNav** (bottom): pill mengambang, `BackdropFilter` blur 24,
  putih 72%; tab aktif = pill `btnTeal` + glow; label 10px.
- **SearchField**: kaca putih 70% + blur, radius 20, ikon teal.
- **TimerRing** (Focus): ring 260px, sweep gradient mint→teal + glow,
  angka Outfit 700 64px putih di atas hero gelap.
- **Bars** (mood/progress): gradient rounded-8 + glow tipis.
- **Paywall**: hero gelap + `goldSheen` aksen, plan tile terpilih =
  border gradient emas.

## 5. Motion
- Stagger list 60ms, `back.out(1.4)` 350ms; hero scale-in 400ms;
  progress bar animate 600ms easeOut; hormati reduced-motion.

## 6. Jangan
- Jangan kembalikan border abu 1px + shadow hitam (itu v10).
- Jangan pakai emoji sebagai ikon. Jangan ubah copy-voice.
- Jangan tambah font baru (pakai Outfit/Work Sans/Inter yang ada).
