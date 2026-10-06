# Puduu — "Candy Pop" Design System v12
**Status:** 🔒 LOCKED — arah pilihan Verdy 2026-10-06 ("Candy Pop — playful berani").
Menggantikan total v11 "Aurora Gloss" (dibuang: teal, Outfit/Work Sans, kaca, sheen).
**Platform:** Flutter (mobile-first, maxWidth 560)

## 1. Prinsip
1. **Loud, bukan calm.** Warna berani, bentuk tebal, tipografi gemuk.
2. **Chunky = border tinta + bayangan keras.** Setiap surface: border 3px
   `#2A2320`, hard shadow offset (5,5) blur 0. Tidak ada blur/glass.
3. **Stiker di mana-mana.** Badge miring (rotate ±6°) untuk tag, status, angka.
4. **Bar tebal bergaris.** Progress bar 18-20px dengan garis diagonal putih.

## 2. Warna
| Token | Hex | Pakai |
|---|---|---|
| `cream` | #FFF3DC | background |
| `paper` | #FFFFFF | kartu |
| `ink` | #2A2320 | border, teks, shadow |
| `cocoa` | #6B5D52 | teks sekunder |
| `clay` | #A89880 | meta |
| `coral` | #FF5C6C | primer / Today |
| `sun` | #FFC53D | sekunder / Focus, progress |
| `grape` | #7C5CFF | tersier / Reset |
| `mint` | #2ED3A3 | sukses / Habits |
| `sky` | #4FC3F7 | info / Yours |

Warna tab: Today coral, Focus sun, Reset grape, Progress mint, Yours sky.

## 3. Tipografi
- Display: **Baloo2** 800 (assets/fonts/Baloo2.ttf, variable)
- UI/body: **Nunito** 600/700/800 (assets/fonts/Nunito.ttf, variable)
- Label section: Baloo2 800, 13px, tracking 1.2, uppercase + bar aksen

## 4. Komponen (lib/widgets/puduu_widgets.dart)
- **PopBackground**: cream + dot grid + bentuk candy melayang
- **PopCard**: paper, border 3px ink, hard shadow (5,5), radius 24
- **PopButton**: warna candy, border 3px ink, hard shadow (4,4), label Baloo2;
  varian `color`/`textColor`, `small`, `expanded`
- **PopTile**: tile ikon warna candy, border 2.5px, shadow (3,3)
- **PopBar**: 18-20px, border 2.5px ink, garis diagonal putih di atas fill
- **Sticker**: badge pill miring, border 2.5px + shadow (3,3)
- **PopHero**: hero warna solid candy, border 3px, shadow (6,6), radius 30,
  Sticker tag, judul Baloo2 26px putih, PopBar, tombol paper + ink
- **TaskCard**: PopCard + PopTile/dot + pill aksi (sun/mint)
- **Tab bar**: bar putih chunky mengambang, tab aktif = pill warna candy
  + border ink
- **Sheet**: cream, border ink 3px atas, handle pill ink, pilihan chunky

## 5. Jangan
- Jangan pakai teal #0E9384 / Outfit / Work Sans / glass / blur / sheen.
- Jangan pakai emoji sebagai ikon (Material rounded).
- Copy-voice boleh tetap kalem — kontrasnya justru jadi pesona.
