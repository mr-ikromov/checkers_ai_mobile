# Release checklist

Har safar Play'ga yangi versiya yuklashdan oldin shu ro'yxatni bosib
chiqing.

---

## Kod va testlar

- [ ] `flutter analyze` — xato va ogohlantirish yo'q
- [ ] `flutter test` — barcha unit testlar o'tadi (dvigatel, golden,
      fuzzing, MCTS)
- [ ] `flutter drive --profile --driver=test_driver/integration_test.dart
      --target=integration_test/app_test.dart -d <device>` — qurilmadagi
      uchdan-uchga testlar o'tadi
- [ ] Qo'lda sinaldi: oq bilan, qora bilan, zanjirli urish, damka,
      durang, natija dialogi
- [ ] Uchala tilda interfeys to'g'ri ko'rinadi, matnlar kesilmaydi

## Versiya

- [ ] `pubspec.yaml` → `version: X.Y.Z+N` oshirildi
      (`N` = versionCode, **albatta** oldingisidan katta)
- [ ] `lib/features/info/about_page.dart` → `appVersion` shu bilan mos
- [ ] Release notes yozildi (`release-notes.md`)

## Qurish

- [ ] `flutter clean && flutter pub get`
- [ ] `flutter build appbundle --release --obfuscate --split-debug-info=build/symbols`
- [ ] `build/symbols/` shu relizga tegishli papkaga zaxiralandi
- [ ] AAB imzosi tekshirildi:
      ```bash
      unzip -p build/app/outputs/bundle/release/app-release.aab \
        META-INF/UPLOAD.RSA | keytool -printcert | grep Owner
      ```
      `CN=Shashka AI` chiqishi kerak (`CN=Android Debug` emas!)

## Play talablari

- [ ] `targetSdk = 36` — Play'ning joriy minimal talabidan past emas
- [ ] Barcha native kutubxonalar 16 KB sahifa hajmiga moslangan:
      ```bash
      cd /tmp && rm -rf abi && mkdir abi && cd abi && \
      unzip -q <APK yo'li> "lib/*" && \
      for f in $(find lib -name "*.so"); do \
        printf "%-44s %s\n" "$f" "$(objdump -p $f | awk '/LOAD/{print $NF; exit}')"; \
      done
      ```
      Hammasi `2**14` yoki undan katta bo'lishi kerak
- [ ] 64-bitli (`arm64-v8a`) versiya mavjud
- [ ] Maxfiylik siyosati URL ochiladi va uchala tilda matn bor

## Store listing

- [ ] Uchala tilda nom, qisqa va to'liq tavsif kiritilgan
- [ ] Ikonka 512×512 yuklangan
- [ ] Feature graphic 1024×500 yuklangan
- [ ] Har til uchun kamida 2 ta telefon skrinshoti
- [ ] Kategoriya: O'yin → Taxta o'yinlari
- [ ] Aloqa email'i kiritilgan

## App content

- [ ] Data safety: "No data collected" ([`data-safety.md`](data-safety.md))
- [ ] Content rating anketasi to'ldirildi ([`content-rating.md`](content-rating.md))
- [ ] Target audience: 13+
- [ ] Ads: yo'q
- [ ] Account deletion: akkaunt yo'q

## Yuklashdan keyin

- [ ] Internal testing orqali haqiqiy telefonga o'rnatib ko'rildi
- [ ] Play Console'da "Pre-launch report" xatolarsiz (Google avtomatik
      bir nechta qurilmada ishga tushiradi)
- [ ] `android/upload-keystore.jks` va `android/key.properties`
      zaxiralangan va xavfsiz joyda
