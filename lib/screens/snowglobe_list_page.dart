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

  // Sorting and filters state
  String _currentSortField = 'date'; // default field
  String _currentOrdering = 'desc';

  // Date range variables
  DateTime? _startDate;
  DateTime? _endDate;

  Map<String, String> _filters = {
    'code': '',
    'shape': '',
    'size': '',
    'country': '',
    'city': '',
  };

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
      sortField: _currentSortField,
      sortOrder: _currentOrdering,
      filters: _filters,
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() {
      _snowglobes.addAll(newSnowglobes);
      _currentPage++;
      _isLoading = false;
    });
  }

  // Change the sort field
  void _changeSortField(String sortField) {
    setState(() {
      _currentSortField = sortField;
      _snowglobes.clear();
      _currentPage = 0;
    });
    _loadMoreSnowglobes();
  }

  // Change the sort ordering
  void _changeOrdering(String ordering) {
    setState(() {
      _currentOrdering = ordering;
      _snowglobes.clear();
      _currentPage = 0;
    });
    _loadMoreSnowglobes();
  }

  // Helper method to check if any filter is applied
  bool _anyFilterApplied() {
    return _filters.values.any((value) => value.isNotEmpty) ||
        (_startDate != null && _endDate != null);
  }

  // Helper method to generate active filters summary
  String _activeFiltersSummary() {
    List<String> filtersList = [];
    if (_filters['code']!.isNotEmpty) {
      filtersList.add("Code: ${_filters['code']}");
    }
    if (_filters['shape']!.isNotEmpty) {
      filtersList.add("Shape: ${_filters['shape']}");
    }
    if (_filters['size']!.isNotEmpty) {
      filtersList.add("Size: ${_filters['size']}");
    }
    if (_filters['country']!.isNotEmpty) {
      filtersList.add("Country: ${_filters['country']}");
    }
    if (_filters['city']!.isNotEmpty) {
      filtersList.add("City: ${_filters['city']}");
    }
    if (_startDate != null && _endDate != null) {
      filtersList.add(
        "Date: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}",
      );
    }
    return filtersList.join(", ");
  }

  // Show dialog for filters including date range
  void _showFilterDialog() {
    // Controllers for each filter field
    TextEditingController codeController = TextEditingController(
      text: _filters['code'],
    );
    TextEditingController shapeController = TextEditingController(
      text: _filters['shape'],
    );
    TextEditingController sizeController = TextEditingController(
      text: _filters['size'],
    );
    TextEditingController countryController = TextEditingController(
      text: _filters['country'],
    );
    TextEditingController cityController = TextEditingController(
      text: _filters['city'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Snowglobes'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: codeController,
                  decoration: InputDecoration(labelText: 'Code'),
                ),
                TextField(
                  controller: shapeController,
                  decoration: InputDecoration(labelText: 'Shape'),
                ),
                TextField(
                  controller: sizeController,
                  decoration: InputDecoration(labelText: 'Size'),
                ),
                TextField(
                  controller: countryController,
                  decoration: InputDecoration(labelText: 'Country'),
                ),
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(labelText: 'City'),
                ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: Icon(Icons.date_range),
                  label: Text(
                    _startDate == null || _endDate == null
                        ? 'Filter by date range'
                        : '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                  ),
                  onPressed: () async {
                    final DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      initialDateRange:
                          _startDate != null && _endDate != null
                              ? DateTimeRange(
                                start: _startDate!,
                                end: _endDate!,
                              )
                              : null,
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = picked.end;
                      });
                    }
                  },
                ),
                if (_startDate != null || _endDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: Text('Clear date filter'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filters['code'] = codeController.text;
                  _filters['shape'] = shapeController.text;
                  _filters['size'] = sizeController.text;
                  _filters['country'] = countryController.text;
                  _filters['city'] = cityController.text;
                  _snowglobes.clear();
                  _currentPage = 0;
                });
                Navigator.of(context).pop();
                _loadMoreSnowglobes();
              },
              child: Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sorting and filter controls
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              DropdownButton<String>(
                value: _currentSortField,
                items: [
                  DropdownMenuItem(child: Text("Date"), value: "date"),
                  DropdownMenuItem(child: Text("Code"), value: "code"),
                  DropdownMenuItem(child: Text("Shape"), value: "shape"),
                  DropdownMenuItem(child: Text("Size"), value: "size"),
                  DropdownMenuItem(child: Text("Country"), value: "country"),
                  DropdownMenuItem(child: Text("City"), value: "city"),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _changeSortField(value);
                  }
                },
              ),
              SizedBox(width: 16),
              DropdownButton<String>(
                value: _currentOrdering,
                items: [
                  DropdownMenuItem(child: Text("Descending"), value: "desc"),
                  DropdownMenuItem(child: Text("Ascending"), value: "asc"),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _changeOrdering(value);
                  }
                },
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: _showFilterDialog,
                child: Text('Filters'),
              ),
            ],
          ),
        ),
        // Active filters summary
        if (_anyFilterApplied())
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Active Filters: ${_activeFiltersSummary()}",
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
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
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child:
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name displayed in large centered text
                            Center(
                              child: Text(
                                snowglobe.name ?? snowglobe.code,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            // First row: Date and Code
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Date: ${snowglobe.date != null ? _formatDate(snowglobe.date) : "Unknown"}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Code: ${snowglobe.code}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // Second row: Shape and Size
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Shape: ${snowglobe.shape}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Size: ${snowglobe.size}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // Place row (only if  country or city are available)
                            if ((snowglobe.country != null &&
                                    snowglobe.country!.isNotEmpty) ||
                                (snowglobe.city != null &&
                                    snowglobe.city!.isNotEmpty))
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Place: ${snowglobe.city}, ${snowglobe.country}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
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

  // Format the date in a readable format
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
