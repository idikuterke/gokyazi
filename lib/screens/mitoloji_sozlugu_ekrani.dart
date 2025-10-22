import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/mitoloji_karakteri.dart';

class MitolojiSozluguEkrani extends StatefulWidget {
  const MitolojiSozluguEkrani({super.key});

  @override
  State<MitolojiSozluguEkrani> createState() => _MitolojiSozluguEkraniState();
}

class _MitolojiSozluguEkraniState extends State<MitolojiSozluguEkrani> {
  late Future<List<MitolojiKarakteri>> _karakterler;

  @override
  void initState() {
    super.initState();
    _karakterler = _loadKarakterler();
  }

  Future<List<MitolojiKarakteri>> _loadKarakterler() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/mitoloji.json',
    );
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => MitolojiKarakteri.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Mitoloji Sözlüğü"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/genel_arkaplan.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<List<MitolojiKarakteri>>(
          future: _karakterler,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Veriler yüklenemedi: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Gösterilecek karakter bulunamadı.'),
              );
            }

            final karakterler = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              itemCount: karakterler.length,
              itemBuilder: (context, index) {
                final karakter = karakterler[index];
                return Card(
                  color: Colors.black.withOpacity(0.5),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            karakter.resimYolu,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 80,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                karakter.ad,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                karakter.unvan,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                              const Divider(height: 16, color: Colors.white24),
                              Text(
                                karakter.aciklama,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
