import 'package:flutter/material.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';
import 'package:snowglobe_collection/services/snowglobe_service.dart';

class SnowglobeListPage extends StatefulWidget {
  @override
  _SnowglobeListPageState createState() => _SnowglobeListPageState();
}

class _SnowglobeListPageState extends State<SnowglobeListPage> {
  final SnowglobeService _snowglobeService = SnowglobeService();
  List<Snowglobe> _snowglobes = [];
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Stub per ordinamento e filtri
  String _currentOrdering = 'desc';
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMoreSnowglobes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _loadMoreSnowglobes();
      }
    });
  }

  Future<void> _loadMoreSnowglobes() async {
    setState(() {
      _isLoading = true;
    });
    List<Snowglobe> newSnowglobes = await _snowglobeService.fetchSnowglobes(
      offset: _currentPage * _pageSize,
      limit: _pageSize,
    );
    setState(() {
      _snowglobes.addAll(newSnowglobes);
      _currentPage++;
      _isLoading = false;
    });
  }

  // Stub per cambiare ordinamento
  void _changeOrdering(String ordering) {
    setState(() {
      _currentOrdering = ordering;
      _snowglobes.clear();
      _currentPage = 0;
    });
    _loadMoreSnowglobes();
  }

  // Stub per applicare filtri
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _snowglobes.clear();
      _currentPage = 0;
    });
    _loadMoreSnowglobes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sezione per ordinamento e filtri (stub)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: _currentOrdering,
                items: [
                  DropdownMenuItem(child: Text("Decrescente"), value: "desc"),
                  DropdownMenuItem(child: Text("Crescente"), value: "asc"),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _changeOrdering(value);
                  }
                },
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Mostra opzioni di filtro
                  _applyFilter("stub_filter");
                },
                child: Text('Filtri'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _snowglobes.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _snowglobes.length) {
                final snowglobe = _snowglobes[index];
                return Card(
                  margin:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Immagine grande caricata dal link nel modello
                      (snowglobe.imageUrl != null &&
                              snowglobe.imageUrl!.isNotEmpty)
                          ? Image.network(
                              snowglobe.imageUrl!,
                              width: double.infinity,
                              height: 400,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey,
                              child: Center(
                                child: Text(
                                  'No image available',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome deciso da te
                            Text(
                              snowglobe.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Data: ${snowglobe.date != null ? snowglobe.date!.toLocal().toString().split(" ")[0] : "Sconosciuta"}',
                            ),
                            SizedBox(height: 4),
                            Text('Taglia: ${snowglobe.size}'),
                            SizedBox(height: 4),
                            Text('Codice: ${snowglobe.code}'),
                            SizedBox(height: 4),
                            Text('Forma: ${snowglobe.shape}'),
                            SizedBox(height: 4),
                            Text('Paese: ${snowglobe.country ?? "Sconosciuto"}'),
                            SizedBox(height: 4),
                            Text('Città: ${snowglobe.city ?? "Sconosciuta"}')
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
