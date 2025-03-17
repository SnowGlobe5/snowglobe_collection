import 'package:flutter/material.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';
import 'package:snowglobe_collection/services/snowglobe_service.dart';
import 'package:snowglobe_collection/screens/snowglobe_insertion_page.dart';
import '../colors.dart';

class SnowGlobeListPage extends StatefulWidget {
  @override
  _SnowGlobeListPageState createState() => _SnowGlobeListPageState();
}

class _SnowGlobeListPageState extends State<SnowGlobeListPage> {
  final SnowGlobeService _snowglobeService = SnowGlobeService();
  List<SnowGlobe> _snowglobes = [];
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

  // Tap counts for each snowglobe id
  Map<int, int> _tapCounts = {};

  @override
  void initState() {
    super.initState();
    _loadMoreSnowGlobes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _loadMoreSnowGlobes();
      }
    });
  }

  Future<void> _loadMoreSnowGlobes() async {
    setState(() {
      _isLoading = true;
    });
    List<SnowGlobe> newSnowGlobes = await _snowglobeService.fetchSnowGlobes(
      offset: _currentPage * _pageSize,
      limit: _pageSize,
      sortField: _currentSortField,
      sortOrder: _currentOrdering,
      filters: _filters,
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() {
      _snowglobes.addAll(newSnowGlobes);
      _currentPage++;
      _isLoading = false;
    });
  }

  Future<void> _refreshSnowGlobes() async {
    setState(() {
      _snowglobes.clear();
      _currentPage = 0;
    });
    await _loadMoreSnowGlobes();
  }

  void _showSortDialog() {
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
                            ? AppColors.primary.withOpacity(0.2)
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
                            ? AppColors.primary.withOpacity(0.2)
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
                  Navigator.of(dialogContext).pop();
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
                  Navigator.of(dialogContext).pop();
                  _loadMoreSnowGlobes();
                },
                child: Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    TextEditingController codeController = TextEditingController(text: _filters['code']);
    // For shape and size, use dropdowns
    String tempShape = _filters['shape'] ?? '';
    String tempSize = _filters['size'] ?? '';
    TextEditingController countryController = TextEditingController(text: _filters['country']);
    TextEditingController cityController = TextEditingController(text: _filters['city']);

    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Filter SnowGlobes'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(labelText: 'Code'),
                  ),
                  DropdownButtonFormField<String>(
                    value: tempShape.isEmpty ? null : tempShape,
                    items: ['', 'Classic', 'Heart', 'Half Pyramid', 'Other']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.isEmpty ? 'Any' : value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Shape'),
                    onChanged: (newValue) {
                      setDialogState(() {
                        tempShape = newValue ?? '';
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: tempSize.isEmpty ? null : tempSize,
                    items: ['', 'XS', 'S', 'M', 'L', 'XL'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.isEmpty ? 'Any' : value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Size'),
                    onChanged: (newValue) {
                      setDialogState(() {
                        tempSize = newValue ?? '';
                      });
                    },
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
                        initialDateRange: tempStartDate != null && tempEndDate != null
                            ? DateTimeRange(start: tempStartDate!, end: tempEndDate!)
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
                  Navigator.of(dialogContext).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Clear all filters
                  codeController.clear();
                  setDialogState(() {
                    tempShape = '';
                    tempSize = '';
                    countryController.clear();
                    cityController.clear();
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
                    _filters['shape'] = tempShape;
                    _filters['size'] = tempSize;
                    _filters['country'] = countryController.text;
                    _filters['city'] = cityController.text;
                    _startDate = tempStartDate;
                    _endDate = tempEndDate;
                    _snowglobes.clear();
                    _currentPage = 0;
                  });
                  Navigator.of(dialogContext).pop();
                  _loadMoreSnowGlobes();
                },
                child: Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleCardTap(SnowGlobe snowglobe) {
    int currentCount = _tapCounts[snowglobe.id] ?? 0;
    currentCount++;
    _tapCounts[snowglobe.id] = currentCount;
    if (currentCount >= 5) {
      // Reset tap count for this record
      _tapCounts[snowglobe.id] = 0;
      _showCardOptions(snowglobe);
    }
  }

  void _showCardOptions(SnowGlobe snowglobe) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Options'),
        content: Text('Would you like to modify or delete this record?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Delete option
              _confirmDelete(snowglobe);
            },
            child: Text('Delete'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              // Modify option: navigate to insertion screen with record data
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SnowGlobeInsertionPage(snowglobe: snowglobe),
                ),
              );
              if (result == true) {
                _refreshSnowGlobes();
              }
            },
            child: Text('Modify'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SnowGlobe snowglobe) {
    showDialog(
      context: context,
      builder: (BuildContext confirmContext) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(confirmContext).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(confirmContext).pop();
              bool deleted = await _snowglobeService.deleteSnowGlobe(snowglobe.id);
              if (deleted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Record deleted successfully')),
                );
                _refreshSnowGlobes();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting record')),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
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
            color: AppColors.primary,
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort',
            color: AppColors.primary,
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
                  return GestureDetector(
                    onTap: () => _handleCardTap(snowglobe),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 28, 28, 28),
                            Color.fromARGB(255, 28, 28, 28)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: (snowglobe.imageUrl != null && snowglobe.imageUrl!.isNotEmpty)
                                ? Image.network(
                                    snowglobe.imageUrl!,
                                    width: double.infinity,
                                    height: 400,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: AppColors.unselectedItem,
                                    child: Center(
                                      child: Text(
                                        'No image available',
                                        style: TextStyle(color: AppColors.foreground)
                                      ),
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text(
                                    snowglobe.name ?? snowglobe.code,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.foreground,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Date: ${snowglobe.date != null ? _formatDate(snowglobe.date) : "Unknown"}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.foreground),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Code: ${snowglobe.code}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.foreground),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Shape: ${snowglobe.shape}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.foreground),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Size: ${snowglobe.size}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppColors.foreground),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                if ((snowglobe.country != null && snowglobe.country!.isNotEmpty) ||
                                    (snowglobe.city != null && snowglobe.city!.isNotEmpty))
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Place: ${snowglobe.city ?? ""}, ${snowglobe.country ?? ""}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: AppColors.foreground),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
