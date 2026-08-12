import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_user_model.dart';
import '../services/report_pdf_service.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import 'access_denied_screen.dart';

enum _DateRangePreset { today, thisWeek, thisMonth, custom }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final Stream<AppUserModel?> _profileStream;
  final ReportService _reportService = ReportService();

  ReportType _selectedType = ReportType.feeCollection;
  _DateRangePreset _datePreset = _DateRangePreset.thisMonth;
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  String? _selectedBatchId;
  String? _selectedCourseId;

  bool _isLoadingFilters = true;
  bool _isGenerating = false;
  bool _isExportingPdf = false;
  bool _isExportingCsv = false;
  String? _error;
  ReportResult? _result;
  List<ReportFilterOption> _batches = const [];
  List<ReportFilterOption> _courses = const [];

  @override
  void initState() {
    super.initState();
    _profileStream = UserService.instance.streamCurrentUserProfile();
    _loadFiltersAndInitialReport();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUserModel?>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
          );
        }

        final appUser = snapshot.data;
        if (appUser == null || !appUser.canViewReports) {
          return const AccessDeniedScreen();
        }

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text(
              'Reports',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: _isGenerating ? null : _generateReport,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  const SizedBox(height: 16),
                  _ReportTypeSelector(
                    selected: _selectedType,
                    onChanged: (type) => setState(() => _selectedType = type),
                  ),
                  const SizedBox(height: 14),
                  _DateRangeSelector(
                    selected: _datePreset,
                    startDate: _startDate,
                    endDate: _endDate,
                    onPresetChanged: _setDatePreset,
                    onCustomTap: _pickCustomDateRange,
                  ),
                  const SizedBox(height: 14),
                  _FilterRow(
                    isLoading: _isLoadingFilters,
                    batches: _batches,
                    courses: _courses,
                    selectedBatchId: _selectedBatchId,
                    selectedCourseId: _selectedCourseId,
                    onBatchChanged: (value) =>
                        setState(() => _selectedBatchId = value),
                    onCourseChanged: (value) =>
                        setState(() => _selectedCourseId = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isGenerating ? null : _generateReport,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow_rounded),
                          label: const Text('Generate Report'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _ReportArea(
                    result: _result,
                    error: _error,
                    isLoading: _isGenerating,
                    isExportingPdf: _isExportingPdf,
                    isExportingCsv: _isExportingCsv,
                    canExport: appUser.canExportReports,
                    onSharePdf: _sharePdf,
                    onShareCsv: _shareCsv,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadFiltersAndInitialReport() async {
    setState(() {
      _isLoadingFilters = true;
      _isGenerating = true;
      _error = null;
    });
    try {
      final filters = await _reportService.loadFilterData();
      final result = await _reportService.generate(
        type: _selectedType,
        filters: _currentFilters(),
      );
      if (!mounted) return;
      setState(() {
        _batches = filters.batches;
        _courses = filters.courses;
        _result = result;
        _isLoadingFilters = false;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Report data could not be loaded.';
        _isLoadingFilters = false;
        _isGenerating = false;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    try {
      final result = await _reportService.generate(
        type: _selectedType,
        filters: _currentFilters(),
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Report data could not be loaded.';
        _isGenerating = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    final result = _result;
    if (result == null) return;
    setState(() => _isExportingPdf = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shared = await ReportPdfService.sharePdf(result);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            shared
                ? 'Report PDF ready to share.'
                : 'Sharing is not supported on this platform.',
          ),
          backgroundColor: shared ? AppTheme.success : AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  Future<void> _shareCsv() async {
    final result = _result;
    if (result == null) return;
    setState(() => _isExportingCsv = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final shared = await ReportPdfService.shareCsv(result);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            shared
                ? 'CSV/Text report ready to share.'
                : 'Sharing is not supported on this platform.',
          ),
          backgroundColor: shared ? AppTheme.success : AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExportingCsv = false);
    }
  }

  Future<void> _pickCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked == null) return;
    setState(() {
      _datePreset = _DateRangePreset.custom;
      _startDate = picked.start;
      _endDate = picked.end;
    });
  }

  void _setDatePreset(_DateRangePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _datePreset = preset;
      switch (preset) {
        case _DateRangePreset.today:
          _startDate = today;
          _endDate = today;
        case _DateRangePreset.thisWeek:
          _startDate = today.subtract(Duration(days: today.weekday - 1));
          _endDate = today;
        case _DateRangePreset.thisMonth:
          _startDate = DateTime(today.year, today.month, 1);
          _endDate = today;
        case _DateRangePreset.custom:
          break;
      }
    });
  }

  ReportFilters _currentFilters() {
    return ReportFilters(
      startDate: _startDate,
      endDate: _endDate,
      batchId: _selectedBatchId,
      courseId: _selectedCourseId,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reports',
          style: TextStyle(
            color: AppTheme.text,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Fees, attendance and student insights',
          style: TextStyle(color: AppTheme.muted),
        ),
      ],
    );
  }
}

class _ReportTypeSelector extends StatelessWidget {
  const _ReportTypeSelector({required this.selected, required this.onChanged});

  final ReportType selected;
  final ValueChanged<ReportType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReportType.values.map((type) {
        final isSelected = selected == type;
        return ChoiceChip(
          label: Text(type.label),
          selected: isSelected,
          onSelected: (_) => onChanged(type),
          selectedColor: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          side: const BorderSide(color: AppTheme.border),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppTheme.text,
            fontWeight: FontWeight.w800,
          ),
        );
      }).toList(),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.selected,
    required this.startDate,
    required this.endDate,
    required this.onPresetChanged,
    required this.onCustomTap,
  });

  final _DateRangePreset selected;
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<_DateRangePreset> onPresetChanged;
  final VoidCallback onCustomTap;

  @override
  Widget build(BuildContext context) {
    final labels = {
      _DateRangePreset.today: 'Today',
      _DateRangePreset.thisWeek: 'This Week',
      _DateRangePreset.thisMonth: 'This Month',
      _DateRangePreset.custom: 'Custom',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: labels.entries.map((entry) {
            final isSelected = selected == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              side: const BorderSide(color: AppTheme.border),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.text,
                fontWeight: FontWeight.w800,
              ),
              onSelected: (_) {
                if (entry.key == _DateRangePreset.custom) {
                  onCustomTap();
                } else {
                  onPresetChanged(entry.key);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
          style: const TextStyle(color: AppTheme.muted),
        ),
      ],
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.isLoading,
    required this.batches,
    required this.courses,
    required this.selectedBatchId,
    required this.selectedCourseId,
    required this.onBatchChanged,
    required this.onCourseChanged,
  });

  final bool isLoading;
  final List<ReportFilterOption> batches;
  final List<ReportFilterOption> courses;
  final String? selectedBatchId;
  final String? selectedCourseId;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<String?> onCourseChanged;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _Card(
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Loading filters...', style: TextStyle(color: AppTheme.muted)),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;
        final children = [
          Expanded(
            child: _ReportDropdown(
              label: 'All Batches',
              value: selectedBatchId,
              options: batches,
              onChanged: onBatchChanged,
            ),
          ),
          const SizedBox(width: 10, height: 10),
          Expanded(
            child: _ReportDropdown(
              label: 'All Courses',
              value: selectedCourseId,
              options: courses,
              onChanged: onCourseChanged,
            ),
          ),
        ];
        if (isNarrow) {
          return Column(
            children: [
              _ReportDropdown(
                label: 'All Batches',
                value: selectedBatchId,
                options: batches,
                onChanged: onBatchChanged,
              ),
              const SizedBox(height: 10),
              _ReportDropdown(
                label: 'All Courses',
                value: selectedCourseId,
                options: courses,
                onChanged: onCourseChanged,
              ),
            ],
          );
        }
        return Row(children: children);
      },
    );
  }
}

class _ReportDropdown extends StatelessWidget {
  const _ReportDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<ReportFilterOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasValue = options.any((option) => option.id == value);
    return DropdownButtonFormField<String?>(
      initialValue: hasValue ? value : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.filter_alt_rounded, color: AppTheme.muted),
      ),
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(label)),
        ...options.map(
          (option) => DropdownMenuItem<String?>(
            value: option.id,
            child: Text(option.name, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ReportArea extends StatelessWidget {
  const _ReportArea({
    required this.result,
    required this.error,
    required this.isLoading,
    required this.isExportingPdf,
    required this.isExportingCsv,
    required this.canExport,
    required this.onSharePdf,
    required this.onShareCsv,
  });

  final ReportResult? result;
  final String? error;
  final bool isLoading;
  final bool isExportingPdf;
  final bool isExportingCsv;
  final bool canExport;
  final VoidCallback onSharePdf;
  final VoidCallback onShareCsv;

  @override
  Widget build(BuildContext context) {
    if (isLoading && result == null) {
      return const _StateCard(
        icon: Icons.hourglass_top_rounded,
        title: 'Generating report...',
        subtitle: 'This will only refresh the report area.',
      );
    }

    if (error != null) {
      return _StateCard(
        icon: Icons.cloud_off_rounded,
        title: 'Report data could not be loaded.',
        subtitle: error!,
      );
    }

    final report = result;
    if (report == null) {
      return const _StateCard(
        icon: Icons.analytics_rounded,
        title: 'Generate a report',
        subtitle: 'Choose filters and tap Generate Report.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(color: AppTheme.primary),
          ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      color: AppTheme.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    report.subtitle,
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MetricGrid(metrics: report.metrics),
        const SizedBox(height: 14),
        if (canExport) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isExportingPdf || report.rows.isEmpty
                      ? null
                      : onSharePdf,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                  ),
                  icon: isExportingPdf
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Share PDF'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isExportingCsv || report.rows.isEmpty
                      ? null
                      : onShareCsv,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.success,
                    side: const BorderSide(color: AppTheme.success),
                  ),
                  icon: isExportingCsv
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.table_view_rounded),
                  label: const Text('Share CSV/Text'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        if (report.rows.isEmpty)
          const _StateCard(
            icon: Icons.search_off_rounded,
            title: 'No report data found for this period.',
            subtitle: 'Try changing the date range or filters.',
          )
        else
          _ReportTable(report: report),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<ReportMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: metrics.map((metric) {
        final color = switch (metric.tone) {
          ReportTone.success => AppTheme.success,
          ReportTone.warning => AppTheme.warning,
          ReportTone.danger => AppTheme.danger,
          ReportTone.primary => AppTheme.primary,
        };
        return SizedBox(
          width: 150,
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded, color: color),
                const SizedBox(height: 10),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.label,
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({required this.report});

  final ReportResult report;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
            color: AppTheme.text,
            fontWeight: FontWeight.w900,
          ),
          dataTextStyle: const TextStyle(color: AppTheme.text),
          columns: report.columns
              .map((column) => DataColumn(label: Text(column)))
              .toList(),
          rows: report.rows
              .take(80)
              .map(
                (row) => DataRow(
                  cells: row.map((value) => DataCell(Text(value))).toList(),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
