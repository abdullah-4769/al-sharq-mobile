// lib/organizer_view/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/services.dart';
import '../../view_model/dashboard_view_model.dart';
import 'data/response_models/dashboard_response_model.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> with TickerProviderStateMixin {
  final DashboardViewModel dashboardVM = Get.put(DashboardViewModel()); // Changed from Get.put to Get.find
  late AnimationController _fadeController;
  late AnimationController _slideController;
  String selectedFilter = 'Weekly';
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Check if we need to fetch data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = dashboardVM.dashboardData.value;
      if (data == null && dashboardVM.isLoading.value) {
        dashboardVM.fetchDashboardData();
      }
    });

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _generateCSV() {
    final data = dashboardVM.dashboardData.value;
    if (data == null) return 'No data available';

    StringBuffer csv = StringBuffer();

    // Header
    csv.writeln('Dashboard Export Report');
    csv.writeln('Generated on: ${DateTime.now()}');
    csv.writeln('');

    // Daily Attendance
    csv.writeln('Daily Attendance');
    csv.writeln('Date,Count');
    for (var attendance in data.dailyAttendance) {
      csv.writeln('${attendance.date},${attendance.count}');
    }
    csv.writeln('');

    // Top Sessions
    csv.writeln('Top Sessions');
    csv.writeln('Rank,Title,Speakers,Registrations');
    for (int i = 0; i < data.topSessions.length; i++) {
      final session = data.topSessions[i];
      csv.writeln('${i + 1},"${session.title}","${session.speakerNames}",${session.totalRegistrations}');
    }
    csv.writeln('');

    // Summary Statistics
    csv.writeln('Summary Statistics');
    csv.writeln('Metric,Value');
    csv.writeln('Total Participants,${dashboardVM.getTotalParticipants()}');
    csv.writeln('Checked In Today,${dashboardVM.getCheckedInToday()}');
    csv.writeln('Active Sessions,${data.topSessions.length}');

    return csv.toString();
  }

  Future<void> _exportPDF() async {
    try {
      final pdfBytes = await _generateDashboardPDF();

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: "dashboard_report.pdf",
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<Uint8List> _generateDashboardPDF() async {
    final data = dashboardVM.dashboardData.value;
    if (data == null) return Uint8List(0);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "Dashboard Report",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Generated: ${DateTime.now()}"),
          pw.Divider(),

          // Attendance Section
          pw.Text("Daily Attendance", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ["Date", "Count"],
            data: data.dailyAttendance
                .map((e) => [e.date.toString(), e.count.toString()])
                .toList(),
          ),
          pw.SizedBox(height: 20),

          // Top Sessions Section
          pw.Text("Popular Sessions", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ["Rank", "Title", "Speakers", "Registrations"],
            data: data.topSessions.asMap().entries.map((e) {
              final i = e.key + 1;
              final s = e.value;
              return [i.toString(), s.title, s.speakerNames, s.totalRegistrations.toString()];
            }).toList(),
          ),
          pw.SizedBox(height: 20),

          // Summary
          pw.Text("Summary", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            headers: ["Metric", "Value"],
            data: [
              ["Total Participants", dashboardVM.getTotalParticipants().toString()],
              ["Checked In Today", dashboardVM.getCheckedInToday().toString()],
              ["Active Sessions", data.topSessions.length.toString()],
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Obx(() {
        final data = dashboardVM.dashboardData.value;
        final isLoading = dashboardVM.isLoading.value;
        final error = dashboardVM.error.value;

        // Show loading when loading AND no data
        if (isLoading && data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent[600]!),
                ),
                const SizedBox(height: 16),
                const Text('Loading dashboard...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // Show error when there's an error AND no data
        if (error.isNotEmpty && data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error Loading Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      dashboardVM.fetchDashboardData();
                      _fadeController.forward(from: 0);
                      _slideController.forward(from: 0);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Show loading if no data (even if not actively loading)
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent[600]!),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading dashboard data...',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // We have data, show the dashboard
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTimeFilters(),
                        const SizedBox(height: 20),
                        _buildStatsCards(data),
                        const SizedBox(height: 20),
                        _buildAttendanceChart(),
                        const SizedBox(height: 20),
                        _buildEngagementChart(),
                        const SizedBox(height: 20),
                        _buildPopularSessions(data),
                        const SizedBox(height: 20),
                        _buildExportButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Event Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.redAccent[50]!, Colors.purple[50]!],
            ),
          ),
        ),
      ),
      actions: [
        Obx(() => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Center(
            child: Text(
              dashboardVM.lastUpdated.value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
        )),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black87),
          onPressed: () {
            dashboardVM.fetchDashboardData();
            _fadeController.forward(from: 0);
            _slideController.forward(from: 0);
          },
        ),
      ],
    );
  }

  Widget _buildTimeFilters() {
    final filters = ['Daily', 'Weekly', '10Days', '90Days'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => setState(() => selectedFilter = filter),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [Colors.redAccent[600]!, Colors.redAccent[400]!],
                  )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Colors.redAccent.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                      blurRadius: isSelected ? 8 : 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsCards(DashboardResponseModel data) {
    final stats = [
      {
        'title': 'Checked In',
        'value': dashboardVM.getCheckedInToday().toString(),
        'icon': Icons.login,
        'color': Colors.redAccent
      },
      {
        'title': 'Total Users',
        'value': dashboardVM.getTotalParticipants().toString(),
        'icon': Icons.people,
        'color': Colors.green
      },
      {
        'title': 'Sessions',
        'value': data.topSessions.length.toString(),
        'icon': Icons.event,
        'color': Colors.orange
      },
      {
        'title': 'Rate',
        'value': '78%',
        'icon': Icons.trending_up,
        'color': Colors.purple
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _buildStatCard(
                stat['title'] as String,
                stat['value'] as String,
                stat['icon'] as IconData,
                stat['color'] as Color,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart, color: Colors.redAccent[600], size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Attendance',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Last 7 days overview',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: 0,
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.grey[200],
                  dashArray: const [5, 5],
                ),
                labelStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              plotAreaBorderWidth: 0,
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ColumnSeries<double, String>>[
                ColumnSeries<double, String>(
                  dataSource: dashboardVM.getAttendanceChartData(),
                  xValueMapper: (_, index) => dashboardVM.getDayLabels()[index],
                  yValueMapper: (data, _) => data,
                  gradient: LinearGradient(
                    colors: [Colors.redAccent[400]!, Colors.redAccent[600]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  width: 0.7,
                  spacing: 0.1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.pie_chart, color: Colors.purple[600], size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Engagement Distribution',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Event participants breakdown',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: SfCircularChart(
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: const TextStyle(fontSize: 11),
              ),
              series: <PieSeries<Map<String, dynamic>, String>>[
                PieSeries<Map<String, dynamic>, String>(
                  dataSource: [
                    {'category': 'Participants', 'value': 78, 'color': Colors.redAccent[600]},
                    {'category': 'Speakers', 'value': 15, 'color': Colors.green[600]},
                    {'category': 'Sponsors', 'value': 7, 'color': Colors.orange[600]},
                  ],
                  xValueMapper: (data, _) => data['category'],
                  yValueMapper: (data, _) => data['value'],
                  pointColorMapper: (data, _) => data['color'],
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  explode: true,
                  explodeIndex: 0,
                  explodeOffset: '5%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSessions(DashboardResponseModel data) {
    final sessions = data.topSessions;

    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'No sessions available',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.star, color: Colors.orange[600], size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular Sessions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Top sessions by registrations',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔥 Animated list of sessions
          ...sessions.asMap().entries.map((entry) {
            final index = entry.key;
            final session = entry.value;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.orange.withOpacity(0.15),
                            child: Text(
                              "${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  session.speakerNames,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${session.totalRegistrations}",
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.redAccent[600]!, Colors.purple[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.file_download, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Copy data to clipboard (CSV format)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final csv = _generateCSV();
                Clipboard.setData(ClipboardData(text: csv));
                Get.snackbar(
                  'Success',
                  'CSV data copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy to Clipboard'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.redAccent[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}