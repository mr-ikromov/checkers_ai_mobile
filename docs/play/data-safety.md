# Data safety — Play Console anketasiga javoblar

Play Console → **App content → Data safety**

Ilovada internet ruxsati yo'q (`AndroidManifest.xml` da bitta ham
`<uses-permission>` yo'q), tarmoqqa chiquvchi kod yo'q, SDK'lar ham yo'q
(analitika, reklama, crash-reporting — hech qaysi biri). Shuning uchun
barcha javoblar "yo'q".

---

## 1-bo'lim: Data collection and security

| Savol | Javob |
|---|---|
| Does your app collect or share any of the required user data types? | **No** |
| Is all of the user data collected by your app encrypted in transit? | *(savol chiqmaydi)* |
| Do you provide a way for users to request that their data be deleted? | *(savol chiqmaydi)* |

Birinchi savolga **No** javob berilgandan keyin qolgan bo'limlar
avtomatik yopiladi va anketa tugaydi.

---

## Nega "No"

Google'ning ta'rifiga ko'ra "collection" — ma'lumotning **qurilmadan
tashqariga** chiqishi. Ilova quyidagilarni faqat qurilmaning o'zida
saqlaydi va hech qayerga yubormaydi:

| Nima saqlanadi | Qayerda | Tashqariga chiqadimi |
|---|---|---|
| Tanlangan til | `SharedPreferences` | Yo'q |
| Tanlangan tomon (oq/qora) | `SharedPreferences` | Yo'q |
| Mavzu, animatsiya, tebranish, koordinata sozlamalari | `SharedPreferences` | Yo'q |
| G'alaba / durang / mag'lubiyat soni | `SharedPreferences` | Yo'q |

Bu ma'lumotlar Android'ning standart zaxiralash (Auto Backup) mexanizmi
orqali foydalanuvchining o'z Google Drive'iga tushishi mumkin — bu
Google'ning o'z platforma funksiyasi va Data safety anketasida
e'lon qilinishi talab qilinmaydi. Zaxiraga faqat `SharedPreferences`
tushadi (`res/xml/backup_rules.xml`).

ONNX model fayli qurilma xotirasiga umuman yozilmaydi: u ilova
ichida shifrlangan asset sifatida turadi va faqat operativ xotirada
ochilib, to'g'ridan-to'g'ri ONNX Runtime'ga uzatiladi.

---

## Tekshirib ko'rish

Ruxsatlar yo'qligini APK'dan tasdiqlash:

```bash
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```

Chiqishda faqat bitta qator bo'ladi:

```
uses-permission: name='uz.deepcontrol.shashka.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
```

Bu — AndroidX kutubxonasi o'zi qo'shadigan ichki `signature` darajasidagi
ruxsat (ilova o'z ichidagi broadcast receiver'ni himoyalash uchun). U
ilovaning o'ziga tegishli, Play Store sahifasida ko'rinmaydi va Data
safety anketasiga ta'sir qilmaydi.

`INTERNET`, `ACCESS_NETWORK_STATE`, joylashuv, kamera yoki xotira
ruxsatlari **yo'q** — buni ham shu buyruq bilan tekshirish mumkin:

```bash
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk \
  | grep -ci "INTERNET\|LOCATION\|CAMERA\|STORAGE"
# natija: 0
```

---

## 2-bo'lim: Boshqa e'lonlar

| Savol | Javob |
|---|---|
| Ads — ilovada reklama bormi? | **No, my app does not contain ads** |
| In-app purchases | Yo'q |
| Government app | No |
| Financial features | None of these |
| Health apps | No |
| News app | No |
| Account deletion | "My app does not allow users to create an account" |
