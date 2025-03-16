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

  // Change the sort field and ordering
  void _showSortDialog() {
    // Variabili temporanee per tenere traccia delle modifiche nella dialog
    String tempSortField = _currentSortField;
    String tempOrdering = _currentOrdering;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Sort by'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Date'),
                  trailing: Radio<String>(
                    value: 'date',
                    groupValue: tempSortField,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempSortField = value;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text('Code'),
                  trailing: Radio<String>(
                    value: 'code',
                    groupValue: tempSortField,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempSortField = value;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text('Shape'),
                  trailing: Radio<String>(
                    value: 'shape',
                    groupValue: tempSortField,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempSortField = value;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text('Size'),
                  trailing: Radio<String>(
                    value: 'size',
                    groupValue: tempSortField,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempSortField = value;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text('Country'),
                  trailing: Radio<String>(
                    value: 'country',
                    groupValue: tempSortField,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempSortField = value;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text('City'),
                  trailing: Radio<String>(
                    value: 'city',
                    groupValue: tempSortField,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          tempSortField = value;
                        });
                      }
                    },
                  ),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.arrow_upward),
                      label: Text('Ascending'),
                      onPressed: () {
                        setDialogState(() {
                          tempOrdering = 'asc';
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: tempOrdering == 'asc'
                            ? Colors.deepPurpleAccent.withOpacity(0.2)
                            : null,
                      ),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.arrow_downward),
                      label: Text('Descending'),
                      onPressed: () {
                        setDialogState(() {
                          tempOrdering = 'desc';
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: tempOrdering == 'desc'
                            ? Colors.deepPurpleAccent.withOpacity(0.2)
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
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
                    _currentSortField = tempSortField;
                    _currentOrdering = tempOrdering;
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
      ),
    );
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

    // Variabili temporanee per date
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                      tempStartDate == null || tempEndDate == null
                          ? 'Filter by date range'
                          : '${_formatDate(tempStartDate)} - ${_formatDate(tempEndDate)}',
                    ),
                    onPressed: () async {
                      final DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        initialDateRange:
                            tempStartDate != null && tempEndDate != null
                                ? DateTimeRange(
                                  start: tempStartDate!,
                                  end: tempEndDate!,
                                )
                                : null,
                      );
                      if (picked != null) {
                        setDialogState(() {
                          tempStartDate = picked.start;
                          tempEndDate = picked.end;
                        });
                      }
                    },
                  ),
                  if (tempStartDate != null || tempEndDate != null)
                    TextButton(
                      onPressed: () {
                        setDialogState(() {
                          tempStartDate = null;
                          tempEndDate = null;
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
              TextButton(
                onPressed: () {
                  // Resetta tutti i filtri
                  codeController.clear();
                  shapeController.clear();
                  sizeController.clear();
                  countryController.clear();
                  cityController.clear();
                  setDialogState(() {
                    tempStartDate = null;
                    tempEndDate = null;
                  });
                },
                child: Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _filters['code'] = codeController.text;
                    _filters['shape'] = shapeController.text;
                    _filters['size'] = sizeController.text;
                    _filters['country'] = countryController.text;
                    _filters['city'] = cityController.text;
                    _startDate = tempStartDate;
                    _endDate = tempEndDate;
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
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SnowGlobe Collection'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
            color: Colors.deepPurpleAccent,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
            color: Colors.deepPurpleAccent,
          ),
        ],
      ),
      body: _snowglobes.isEmpty && !_isLoading
          ? Center(
              child: Text(
                'No snowglobes found',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _snowglobes.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _snowglobes.length) {
                  final snowglobe = _snowglobes[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      gradient: LinearGradient(
                        //colors: [Colors.deepPurple, Color.fromARGB(255, 28, 28, 28)],
                        colors: [Color.fromARGB(255, 28, 28, 28), Color.fromARGB(255, 28, 28, 28)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
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
                              // Nome
                              Center(
                                child: Text(
                                  snowglobe.name ?? snowglobe.code,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              // Data e Codice
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Date: ${snowglobe.date != null ? _formatDate(snowglobe.date) : "Unknown"}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Code: ${snowglobe.code}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              // Forma e Dimensione
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Shape: ${snowglobe.shape}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Size: ${snowglobe.size}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              // Luogo (se presente)
                              if ((snowglobe.country != null &&
                                      snowglobe.country!.isNotEmpty) ||
                                  (snowglobe.city != null &&
                                      snowglobe.city!.isNotEmpty))
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Place: ${snowglobe.city ?? ""}, ${snowglobe.country ?? ""}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.white),
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