# Google Play'ga joylash — bosqichma-bosqich

Bu hujjat `Shashka AI` ilovasini Google Play Console'ga birinchi marta
yuklash uchun yozilgan. Hamma javoblar tayyor: har bir bo'lim uchun nima
yozish va qaysi faylni yuklash ko'rsatilgan.

---

## 0. Ilova haqida qisqacha (ma'lumot uchun)

| Maydon | Qiymat |
|---|---|
| Nomi | Shashka AI (ru: Шашки ИИ) |
| Paket nomi (`applicationId`) | `uz.deepcontrol.shashka` |
| Versiya | `1.0.0` (versionCode `1`) |
| Minimal Android | 7.0 (API 24) |
| Target SDK | 36 (Android 16) |
| Qo'llab-quvvatlanadigan ABI | arm64-v8a, armeabi-v7a, x86_64 |
| Ruxsatlar | **yo'q** |
| Internet | **talab qilinmaydi** |
| Reklama | yo'q |
| Ilova ichida xarid | yo'q |
| Yuklab olish hajmi | **~29 MB** (arm64-v8a qurilmada) |

> Paket nomi ilova umri davomida **o'zgarmaydi**. Agar boshqa nom
> xohlasangiz, Play'ga birinchi yuklashdan **oldin** o'zgartiring:
> `android/app/build.gradle.kts` dagi `applicationId` va `namespace`,
> hamda `android/app/src/main/kotlin/...` papka yo'li.

---

## 1. Imzo kalitlari (eng muhim qadam)

Release AAB `android/upload-keystore.jks` bilan imzolangan. Parollar
`android/key.properties` faylida. Ikkalasi ham `.gitignore` da — git'ga
tushmaydi.

**Bu ikki faylni hozir zaxiralang** (masalan parol menejeri yoki shifrlangan
disk). Yo'qotsangiz, ilovaga yangilanish chiqarish uchun Google'dan
upload-kalitni tiklashni so'rashga to'g'ri keladi.

Play Console'da **Play App Signing** yoqilgan bo'ladi (standart): siz
yuklagan AAB upload-kalit bilan imzolanadi, Google esa o'zining
release-kaliti bilan qayta imzolaydi.

Kalit barmoq izi (upload):

```
SHA-256: EA:50:47:09:A9:C9:66:87:0B:60:6F:DB:EB:30:F6:85:A8:AD:41:BC:F6:53:9F:6C:BE:5F:1C:1A:CA:B7:99:1F
```

Boshqa kalit yaratmoqchi bo'lsangiz — `android/key.properties.example` ga
qarang.

---

## 2. AAB qurish

```bash
cd shashka_flutter
flutter clean && flutter pub get
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
```

Natija: `build/app/outputs/bundle/release/app-release.aab`

Tekshirish (imzo to'g'ri kalit bilanmi):

```bash
unzip -p build/app/outputs/bundle/release/app-release.aab META-INF/UPLOAD.RSA | keytool -printcert
```

`Owner: CN=Shashka AI, ...` chiqishi kerak. Agar `CN=Android Debug` chiqsa —
`android/key.properties` topilmagan, release debug kalit bilan imzolangan va
Play uni **qabul qilmaydi**.

---

## 3. Play Console: ilova yaratish

**Barcha ilovalar → Ilova yaratish**

| Maydon | Javob |
|---|---|
| Ilova nomi | `Shashka AI` |
| Standart til | O'zbek yoki Rus (keyin boshqa tillar qo'shiladi) |
| Ilova yoki o'yin | **O'yin** |
| Bepul yoki pulli | **Bepul** |
| Deklaratsiyalar | Dasturchi dasturi siyosati — ✔; AQSh eksport qonunlari — ✔ |

---

## 4. Store listing (do'kon sahifasi)

Matnlar tayyor:

| Til | Fayl |
|---|---|
| O'zbek | [`store-listing-uz.md`](store-listing-uz.md) |
| Rus | [`store-listing-ru.md`](store-listing-ru.md) |
| Ingliz | [`store-listing-en.md`](store-listing-en.md) |

Grafikalar:

| Nima | Fayl | Talab |
|---|---|---|
| Ilova ikonkasi | `graphics/play_icon_512.png` | 512×512 PNG ✔ |
| Feature graphic | `graphics/play_feature_1024x500.png` | 1024×500 PNG ✔ |
| Telefon skrinshotlari | `graphics/screenshots/<til>/` | 1269×2256 (9:16), 6 ta ✔ |
| Planshet skrinshotlari | `graphics/screenshots-tablet/<til>/` | 1440×2560 (9:16), 6 ta ✔ |

Skrinshotlar har til uchun alohida (`uz/`, `ru/`, `en/`) — Play Console'da
mos tilga yuklang. Minimal 2 ta kerak, bizda 5 ta.

Tavsiya etilgan tartib: `02-board-start`, `03-board-play`, `01-home`,
`04-rules`, `05-about`.

> Play skrinshot nisbati **16:9 yoki 9:16** bo'lishini talab qiladi.
> `flutter drive` ularni qurilma ekrani o'lchamida oladi, shuning uchun
> qayta yaratgandan keyin `python3 tool/crop_screenshots.py [papka]` ni
> ishga tushiring.
>
> Vosita avval ortiqcha balandlikni chetlardagi bo'sh joydan kesishga
> urinadi. Maket butun ekranni to'ldirgani uchun bo'sh joy yetmasa,
> kontentni qirqmaydi: balandlikni 16 ga karrali qiymatga keltirib,
> enini 9 ga karrali qiymatgacha kengaytiradi va chet ustunlarni har bir
> qator uchun cho'zadi — fon gradienti uzluksiz davom etadi. Telefon
> shu yo'l bilan 1269×2256 bo'ladi.
>
> Planshetda `wm size` ishlagani uchun u to'g'ridan-to'g'ri kerakli
> o'lchamda olinadi: 1440×2596 qo'yilsa Flutter sirti aynan 1440×2560
> chiqadi (tizim panellari 36 px egallaydi). Chiqishni `SHOTS_DIR`
> bilan ajrating:
>
> ```bash
> adb shell wm size 1440x2596
> SHOTS_DIR=docs/play/graphics/screenshots-tablet flutter drive --profile \
>   --driver=test_driver/screenshots.dart \
>   --target=integration_test/screenshots_test.dart -d <planshet>
> ```
>
> Tugagach `adb shell wm size reset`.

> Planshet skrinshotlari majburiy emas, lekin bo'lsa ilova planshetlarda
> ham tavsiya ro'yxatlariga tushadi. Olish uchun planshet yoki emulyator
> ulab: `flutter drive --profile --driver=test_driver/screenshots.dart
> --target=integration_test/screenshots_test.dart -d <device>`

---

## 5. Maxfiylik siyosati (majburiy)

Play barcha ilovalardan maxfiylik siyosati **URL**ini talab qiladi.

Sahifa tayyor va repozitoriyada: [`privacy-policy.html`](privacy-policy.html)
— uchala tilda, aloqa pochtasi kiritilgan.

Uni bepul joylashtirish (GitHub Pages, 1 daqiqa):

1. github.com/mr-ikromov/checkers_ai_mobile → **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: **main**, papka: **/docs** → **Save**
4. 1-2 daqiqadan keyin sahifa ochiladi:

```
https://mr-ikromov.github.io/checkers_ai_mobile/play/privacy-policy.html
```

Shu URL'ni Play Console → **Store listing** → *Privacy Policy* maydoniga
va **App content** → *Privacy policy* ga kiriting.

Matn variantlari alohida ham bor: `privacy-policy-uz.md`,
`privacy-policy-ru.md`, `privacy-policy-en.md`.

---

## 6. App content (ilova mazmuni)

Har bir anketa uchun javoblar:

| Bo'lim | Hujjat |
|---|---|
| Data safety (ma'lumotlar xavfsizligi) | [`data-safety.md`](data-safety.md) |
| Content rating (yosh reytingi) | [`content-rating.md`](content-rating.md) |
| Target audience | 13+ (quyida izoh) |
| Ads (reklama) | **Yo'q** |
| News app | Yo'q |
| COVID-19 contact tracing | Yo'q |
| Data deletion | Akkaunt yo'q — "Ilova akkaunt yaratishni taklif qilmaydi" |
| Government app | Yo'q |
| Financial features | Yo'q |

**Target audience haqida.** 13+ tanlash eng oddiy yo'l. 13 yoshdan
kichiklarni ham qo'shsangiz, ilova Google Play "Families" siyosatiga
tushadi — ilova bu talablarga javob beradi (reklama yo'q, ma'lumot
to'planmaydi, tashqi havola yo'q), lekin qo'shimcha anketa to'ldirish va
Families dasturiga qo'shilish kerak bo'ladi.

---

## 7. Releaseni chiqarish

1. **Test** → **Internal testing** → Yangi release yaratish
2. `app-release.aab` ni yuklang
3. Release nomi: `1.0.0 (1)`
4. Release notes: [`release-notes.md`](release-notes.md) dagi matnlar
5. Testerlar ro'yxatiga o'z pochtangizni qo'shib, havola orqali o'rnatib
   ko'ring
6. Hammasi joyida bo'lsa: **Production** → yangi release → o'sha AAB

> Yangi ilova uchun Google Play birinchi tekshiruvni odatda 1–7 kunda
> yakunlaydi. Shaxsiy (individual) dasturchi akkauntlari uchun qo'shimcha
> talab bor: production'ga chiqishdan oldin **12 testchi bilan 14 kun**
> yopiq test o'tkazish. Shuning uchun Internal/Closed testingdan boshlash
> shart.

To'liq ro'yxat: [`release-checklist.md`](release-checklist.md)

---

## 8. Keyingi versiyalarni chiqarish

`pubspec.yaml` dagi `version: 1.0.0+1` ni oshiring:

- `1.0.1+2` — xatolar tuzatildi
- `1.1.0+3` — yangi imkoniyat

`+` dan keyingi son (`versionCode`) **har safar oshishi shart**, aks holda
Play qabul qilmaydi.

Keyin: `flutter build appbundle --release` va yangi AAB'ni yuklang.
