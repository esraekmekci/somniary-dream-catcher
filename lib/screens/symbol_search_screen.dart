import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';

class SymbolSearchScreen extends StatefulWidget {
  const SymbolSearchScreen({super.key});

  @override
  State<SymbolSearchScreen> createState() => _SymbolSearchScreenState();
}

class _SymbolSearchScreenState extends State<SymbolSearchScreen> {
  final _controller = TextEditingController();
  _SymbolMeaning? _match;
  String _query = '';

  static const _meanings = <_SymbolMeaning>[
    _SymbolMeaning(
      label: 'Yılan',
      aliases: ['yilan', 'yılan', 'snake', 'serpent'],
      meaning:
          'Rüyada yılan görmek genelde bastırılmış korkular, dönüşüm veya güçlü bir içgüdüyle ilişkilendirilir. Bazen bir tehdit hissini, bazen de güçlenme sürecini simgeler. Rüyanın tonu sakinse bu sembol iyileşme ve yenilenmeye de işaret edebilir.',
    ),
    _SymbolMeaning(
      label: 'Su',
      aliases: ['su', 'water', 'ocean', 'sea', 'river'],
      meaning:
          'Su çoğunlukla duygusal durumu temsil eder. Durgun ve berrak su iç huzuru, taşkın veya bulanık su ise yoğun duygusal yükleri anlatabilir. Rüyadaki suyun hareketi, hislerin nasıl aktığını anlamada ipucu verir.',
    ),
    _SymbolMeaning(
      label: 'Uçmak',
      aliases: ['ucmak', 'uçmak', 'flying', 'fly'],
      meaning:
          'Uçma rüyaları özgürleşme isteği, sınırları aşma ve kontrol duygusuyla bağlantılıdır. Yüksekte rahat hissetmek güveni, düşme korkusu ise belirsizlikleri gösterebilir. Genelde kişinin hayatında daha geniş bir bakış aradığını anlatır.',
    ),
    _SymbolMeaning(
      label: 'Düşmek',
      aliases: ['dusmek', 'düşmek', 'falling', 'fall'],
      meaning:
          'Düşme rüyası kontrol kaybı, stres veya güvende hissetmeme duygusuna işaret edebilir. Özellikle ani düşüşler, uyanık hayatta baskı hissettiğin dönemlerle çakışabilir. Bu sembol, yavaşlayıp temeli güçlendirme ihtiyacını hatırlatır.',
    ),
    _SymbolMeaning(
      label: 'Diş',
      aliases: ['dis', 'diş', 'teeth', 'tooth'],
      meaning:
          'Diş rüyaları çoğu zaman öz güven, ifade biçimi ve görünürlük kaygılarıyla ilişkilidir. Bir şeyin eksildiği hissi, yaşamda kontrol etmek istediğin bir alanı yansıtabilir. Aynı zamanda büyük bir değişim eşiğini de simgeleyebilir.',
    ),
    _SymbolMeaning(
      label: 'Ev',
      aliases: ['ev', 'house', 'home'],
      meaning:
          'Ev sembolü genelde kişinin iç dünyasını temsil eder. Evin odaları farklı duygusal alanları, kapalı veya dağınık bölümler ise fark edilmemiş meseleleri gösterebilir. Tanıdık ve güvenli bir ev ise aidiyet ve denge hissini yansıtır.',
    ),
    _SymbolMeaning(
      label: 'Kapı',
      aliases: ['kapi', 'kapı', 'door', 'gate'],
      meaning:
          'Kapı yeni bir döneme geçiş, fırsat veya karar anını simgeler. Açık kapılar olasılıkları, kapalı kapılar ise henüz hazır olunmayan bir alanı anlatabilir. Rüyanın hissi, bu geçişe yaklaşımını anlamakta belirleyicidir.',
    ),
    _SymbolMeaning(
      label: 'Ayna',
      aliases: ['ayna', 'mirror'],
      meaning:
          'Ayna sembolü öz farkındalık ve kendine bakışla ilgilidir. Net bir yansıma kendini daha iyi tanımayı, bozuk veya bulanık yansıma ise kimlik karmaşası ya da öz eleştiri dönemini gösterebilir. Bu tür rüyalar iç konuşmayı yumuşatmayı önerir.',
    ),
    _SymbolMeaning(
      label: 'Merdiven',
      aliases: ['merdiven', 'stairs', 'stairway'],
      meaning:
          'Merdiven, gelişim süreci ve adım adım ilerlemeyi temsil eder. Yukarı çıkmak hedeflere yakınlaşmayı, aşağı inmek içe dönüşü veya geçmişe bakışı simgeleyebilir. Basamakların hissi, süreçteki zorluk düzeyine işaret eder.',
    ),
    _SymbolMeaning(
      label: 'Bebek',
      aliases: ['bebek', 'baby', 'infant'],
      meaning:
          'Bebek rüyası yeni başlangıçlar, kırılganlık veya korunma ihtiyacıyla bağlantılıdır. Hayatındaki yeni bir fikir, ilişki veya sorumluluk bu sembolle belirebilir. Çoğu zaman şefkat ve dikkat gerektiren bir süreci anlatır.',
    ),
    _SymbolMeaning(
      label: 'Ölüm',
      aliases: ['olum', 'ölüm', 'death', 'dead'],
      meaning:
          'Rüyada ölüm görmek çoğu zaman gerçek ölümden çok bir dönemin kapanışı ve dönüşüm anlamı taşır. Eski alışkanlıkların bırakılması, yeni bir kimlik veya yaşam düzenine geçişi simgeleyebilir. Bu sembol genellikle bitişten çok yenilenmeyi anlatır.',
    ),
    _SymbolMeaning(
      label: 'Araba',
      aliases: ['araba', 'car', 'vehicle'],
      meaning:
          'Araba çoğunlukla yaşam yönü ve kontrol algısıyla ilişkilidir. Arabayı sürmek karar mekanizmasını, yolculuğun zorlaşması ise süreçteki engelleri anlatabilir. Bu rüya, hızını ve yönünü yeniden değerlendirme çağrısı olabilir.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String raw) {
    final query = _normalize(raw);
    _SymbolMeaning? result;

    if (query.isNotEmpty) {
      for (final item in _meanings) {
        final keys = item.aliases.map(_normalize);
        if (keys.contains(query)) {
          result = item;
          break;
        }
      }

      if (result == null) {
        for (final item in _meanings) {
          final keys = item.aliases.map(_normalize);
          if (keys.any((k) => k.contains(query) || query.contains(k))) {
            result = item;
            break;
          }
        }
      }
    }

    setState(() {
      _query = raw;
      _match = result;
    });
  }

  String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyQuery = _query.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Dream Symbols')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text(
            'Rüyanda gördüğün bir simgeyi yaz. Sana o simge için genel bir açıklama gösterelim.',
            style: TextStyle(
              color: isDark
                  ? AppPalette.darkTextSecondary
                  : AppPalette.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            onChanged: _search,
            onSubmitted: _search,
            decoration: InputDecoration(
              labelText: 'Simge ara (ör: yılan)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        _search('');
                      },
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          const SizedBox(height: 14),
          if (emptyQuery) ...[
            Text(
              'Popüler simgeler',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _meanings.take(8).map((item) {
                return ActionChip(
                  label: Text(item.label),
                  onPressed: () {
                    _controller.text = item.label;
                    _search(item.label);
                  },
                );
              }).toList(),
            ),
          ] else if (_match == null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDark
                    ? AppPalette.color800.withValues(alpha: 0.4)
                    : AppPalette.color100,
              ),
              child: const Text(
                'Bu simge için henüz bir açıklama bulunamadı. Farklı bir kelime ile tekrar dene.',
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: isDark
                    ? AppPalette.darkSurface.withValues(alpha: 0.92)
                    : AppPalette.lightSurface,
                border: Border.all(
                  color: isDark
                      ? AppPalette.color700.withValues(alpha: 0.35)
                      : AppPalette.color200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _match!.label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _match!.meaning,
                    style: TextStyle(
                      height: 1.55,
                      color: isDark
                          ? AppPalette.darkTextPrimary
                          : AppPalette.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Not: Bunlar genel ve yorumsal açıklamalardır.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppPalette.darkTextSecondary
                          : AppPalette.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SymbolMeaning {
  const _SymbolMeaning({
    required this.label,
    required this.aliases,
    required this.meaning,
  });

  final String label;
  final List<String> aliases;
  final String meaning;
}
