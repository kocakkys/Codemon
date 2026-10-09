# CODEMON

Starter project Flutter untuk game RPG belajar coding.

## Fitur versi ini

- Home menjadi profil player.
- Upload foto player dari galeri.
- Edit nama player.
- World berbentuk tower + horizontal swipe.
- HTML, CSS, JavaScript world.
- Slime, Goblin, Dragon.
- Level minimum:
  - Slime: 1-5
  - Goblin: 6-10
  - Dragon: 11-15
- Level tinggi tetap boleh melawan musuh level rendah.
- Tidak memakai energy.
- Reward coin + EXP.
- Battle Point = total damage semua Codemon.
- Komputer = koleksi Codemon.
- 3 active slot.
- Capture Codemon setelah menang.
- Chance capture:
  - Slime 50%
  - Goblin 25%
  - Dragon 10%
- Merge 3 Codemon sejenis untuk naik level dan damage.
- Saat battle, hanya Codemon dengan bahasa yang sesuai soal yang menyerang.
- Soal muncul sebagai popup di battle.
- Countdown sebelum soal.
- Audio countdown/click/correct/wrong/attack/victory/defeat.
- Store untuk potion.
- Bag untuk menggunakan potion.
- Background dan gambar sudah disiapkan sebagai placeholder agar aplikasi langsung bisa dijalankan.

## Ganti asset sendiri

Pertahankan nama file asset supaya kode tidak perlu diubah.

Folder utama:
- assets/backgrounds/
- assets/world/
- assets/enemies/
- assets/codemons/
- assets/audio/

## Jalankan

```bash
flutter clean
flutter pub get
flutter test
flutter run
```

Jika mau mengganti gambar, cukup replace PNG di folder assets dengan gambar sendiri menggunakan nama file yang sama.
