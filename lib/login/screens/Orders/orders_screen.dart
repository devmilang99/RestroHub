import 'dart:async';
import 'package:flutter/material.dart';
import 'package:restro_hub/core/extensions/context_extension.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          title: Text(
            "My Orders",
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: "In Progress"),
              Tab(text: "Success"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OrderList(status: "In Progress"),
            _OrderList(status: "Success"),
            _OrderList(status: "Cancelled"),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final String status;
  const _OrderList({required this.status});

  @override
  Widget build(BuildContext context) {
    // Mock data based on status
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _OrderCard(status: status, index: index);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String status;
  final int index;
  const _OrderCard({required this.status, required this.index});

  @override
  Widget build(BuildContext context) {
    if (status == "In Progress") {
      return _InProgressOrderCard(index: index);
    } else if (status == "Success") {
      return _SuccessOrderCard(index: index);
    } else {
      return _CancelledOrderCard(index: index);
    }
  }
}

class _SuccessOrderCard extends StatefulWidget {
  final int index;
  const _SuccessOrderCard({required this.index});

  @override
  State<_SuccessOrderCard> createState() => _SuccessOrderCardState();
}

class _SuccessOrderCardState extends State<_SuccessOrderCard> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  int _wordCount = 0;
  String? _sentFeedback;
  DateTime? _sentTimestamp;

  @override
  void initState() {
    super.initState();
    _feedbackController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _feedbackController.removeListener(_updateWordCount);
    _feedbackController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _feedbackController.text.trim();
    if (text.isEmpty) {
      setState(() => _wordCount = 0);
      return;
    }
    final words = text.split(RegExp(r'\s+'));
    setState(() => _wordCount = words.length);
  }

  void _sendFeedback() {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    if (_wordCount > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback cannot exceed 20 words')),
      );
      return;
    }

    // Save feedback and timestamp
    setState(() {
      _sentFeedback = _feedbackController.text.trim();
      _sentTimestamp = DateTime.now();
    });

    // TODO: Save feedback to backend/database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Feedback sent! ($_wordCount words)'),
        backgroundColor: Colors.green,
      ),
    );

    _feedbackController.clear();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.lightGreen.shade300, width: 2),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.lightGreen.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.lightGreen.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #RH-123${widget.index}",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Delivered successfully",
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.lightGreen.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  "Rs. 450",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://i.pravatar.cc/150?u=driver${widget.index}',
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rohan Sharma",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Delivered by", style: textTheme.bodySmall),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = i + 1;
                        });
                      },
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Item Table Layout
            const Text(
              "Order Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow(
                  "Chicken Burger",
                  "x1",
                  "Rs. 350",
                  "assets/food1.webp",
                ),
                _buildTableRow(
                  "Coca Cola",
                  "x1",
                  "Rs. 100",
                  "assets/food2.webp",
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            // Feedback Box or Sent Feedback Card
            _sentFeedback == null
                ? Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _feedbackController,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: "Share your feedback...",
                              filled: false,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.fromLTRB(
                                12,
                                12,
                                12,
                                0,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_wordCount / 20 words',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _wordCount > 20
                                      ? Colors.red
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: _wordCount > 20
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_wordCount > 20)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        'Limit exceeded!',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  InkWell(
                                    onTap: _sendFeedback,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color:
                                            _wordCount > 0 && _wordCount <= 20
                                            ? colorScheme.primary
                                            : Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        size: 16,
                                        color:
                                            _wordCount > 0 && _wordCount <= 20
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Feedback Sent',
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _feedbackController.text = _sentFeedback!;
                                    _sentFeedback = null;
                                    _sentTimestamp = null;
                                  });
                                },
                                icon: Icon(Icons.edit, size: 16),
                                label: Text('Edit'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size(0, 32),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _sentFeedback!,
                              style: textTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sent on ${_formatTimestamp(_sentTimestamp!)}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 16),

            // Order Again Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text("Order Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String item,
    String qty,
    String price,
    String assetPath,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(assetPath),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(item),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(qty),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(price),
        ),
      ],
    );
  }
}

class _CancelledOrderCard extends StatelessWidget {
  final int index;
  const _CancelledOrderCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red.shade300, width: 2),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order #RH-123$index",
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Order cancelled",
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  "Rs. 450",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://i.pravatar.cc/150?u=driver$index',
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rohan Sharma",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Assigned Driver", style: textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.phone, color: colorScheme.primary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Item Table Layout
            const Text(
              "Order Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow(
                  "Chicken Burger",
                  "x1",
                  "Rs. 350",
                  "assets/food1.webp",
                ),
                _buildTableRow(
                  "Coca Cola",
                  "x1",
                  "Rs. 100",
                  "assets/food2.webp",
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Cancellation Reason
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cancellation Reason",
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Restaurant busy - Unable to fulfill order",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    String item,
    String qty,
    String price,
    String assetPath,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(assetPath),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(item),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(qty),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(price),
        ),
      ],
    );
  }
}

class _InProgressOrderCard extends StatefulWidget {
  final int index;
  const _InProgressOrderCard({required this.index});

  @override
  State<_InProgressOrderCard> createState() => _InProgressOrderCardState();
}

class _InProgressOrderCardState extends State<_InProgressOrderCard> {
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.3);
  final ValueNotifier<int> _timeNotifier = ValueNotifier(10);
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeNotifier.value > 0) {
        _timeNotifier.value--;
        _progressNotifier.value = 1.0 - (_timeNotifier.value / 500.0);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _progressNotifier.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')} mins";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.amber.shade600, width: 2),
      ),
      color: colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: _progressNotifier,
                  builder: (context, progress, child) {
                    IconData statusIcon;
                    String statusText;
                    if (progress < 0.33) {
                      statusIcon = Icons.soup_kitchen;
                      statusText = "Cooking your meal...";
                    } else if (progress < 0.66) {
                      statusIcon = Icons.inventory_2;
                      statusText = "Meal is being packed...";
                    } else {
                      statusIcon = Icons.delivery_dining;
                      statusText = "Out for delivery...";
                    }

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            statusIcon,
                            color: colorScheme.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #RH-123${widget.index}",
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              statusText,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                Text(
                  "Rs. 450",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://i.pravatar.cc/150?u=driver${widget.index}',
                    width: 40,
                    height: 40,
                    placeholder: (context, url) => const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rohan Sharma",
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Your Delivery Partner", style: textTheme.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.phone, color: colorScheme.primary, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            // Item Table Layout
            const Text(
              "Order Details",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow(
                  "Chicken Burger",
                  "x1",
                  "Rs. 350",
                  "assets/food1.webp",
                  isHeader: false,
                ),
                _buildTableRow(
                  "Coca Cola",
                  "x1",
                  "Rs. 100",
                  "assets/food2.webp",
                  isHeader: false,
                ),
              ],
            ),

            // Progress Bar & Timer (Hidden when tracking starts)
            ValueListenableBuilder<double>(
              valueListenable: _progressNotifier,
              builder: (context, progress, child) {
                if (progress >= 1.0) return const SizedBox.shrink();
                return Column(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: _timeNotifier,
                      builder: (context, secondsRemaining, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Estimated: ${_formatTime(secondsRemaining)}",
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "${(progress * 100).toInt()}%",
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Three-step Progress Tracker or Live Tracking bar
            ValueListenableBuilder<double>(
              valueListenable: _progressNotifier,
              builder: (context, progress, child) {
                if (progress >= 1.0) {
                  return GestureDetector(
                    onTap: () => _openTrackingSheet(context),
                    child: const _LiveTrackingBar(),
                  );
                }
                return _OrderStepProgress(progress: progress);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openTrackingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DriverTrackingSheet(),
    );
  }

  TableRow _buildTableRow(
    String item,
    String qty,
    String price,
    String assetPath, {
    bool isHeader = false,
  }) {
    final style = isHeader
        ? const TextStyle(fontWeight: FontWeight.bold)
        : null;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(assetPath),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(item, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Text(qty, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(price, style: style),
        ),
      ],
    );
  }
}

class _OrderStepProgress extends StatelessWidget {
  final double progress;
  const _OrderStepProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    // Stage 1: Cooking (0.0 - 0.33)
    double cookingProgress = (progress / 0.33).clamp(0.0, 1.0);
    // Stage 2: Packed (0.33 - 0.66)
    double packedProgress = ((progress - 0.33) / 0.33).clamp(0.0, 1.0);
    // Stage 3: In Route (0.66 - 1.0)
    double inRouteProgress = ((progress - 0.66) / 0.34).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            _ProgressStep(
              label: "Cooking",
              icon: Icons.soup_kitchen,
              progress: cookingProgress,
              isCompleted: progress > 0.33,
            ),
            _ProgressStep(
              label: "Packed",
              icon: Icons.inventory_2,
              progress: packedProgress,
              isCompleted: progress > 0.66,
            ),
            _ProgressStep(
              label: "In Route",
              icon: Icons.delivery_dining,
              progress: inRouteProgress,
              isCompleted: progress >= 1.0,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final double progress;
  final bool isCompleted;

  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = progress > 0;

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: isCompleted
                ? Colors.green
                : (isActive ? colorScheme.primary : Colors.grey.shade400),
            size: 24,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.primaryContainer.withValues(
                  alpha: 0.1,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : colorScheme.primary,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isCompleted
                  ? Colors.green
                  : (isActive ? colorScheme.primary : Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveTrackingBar extends StatefulWidget {
  const _LiveTrackingBar();

  @override
  State<_LiveTrackingBar> createState() => _LiveTrackingBarState();
}

class _LiveTrackingBarState extends State<_LiveTrackingBar>
    with SingleTickerProviderStateMixin {
  int _currentLocationIndex = 0;
  final List<String> _locations = [
    "Driver is at the Restaurant",
    "Passing through New Road",
    "Near Civil Mall",
    "Approaching Narayan Chowk",
    "Arriving at Your Location",
    "Arrived! Driver is Waiting",
  ];
  late Timer _locTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.1,
      end: 0.25,
    ).animate(_pulseController);

    _locTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentLocationIndex < _locations.length - 1) {
        if (mounted) {
          setState(() {
            _currentLocationIndex++;
          });
        }
      } else {
        _locTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _locTimer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isArrived = _currentLocationIndex == _locations.length - 1;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(
                  alpha: isArrived ? 0.2 : _pulseAnimation.value,
                ),
                colorScheme.primary.withValues(alpha: isArrived ? 0.3 : 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isArrived
                  ? Colors.green.withValues(alpha: 0.5)
                  : colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              if (isArrived)
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Row(
            children: [
              if (isArrived)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1.1),
                  duration: const Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.green,
                        size: 28,
                      ),
                    );
                  },
                )
              else
                _MovingIcon(color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArrived ? "PLEASE PICK UP!" : "Order Is Being Carried",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isArrived ? Colors.green.shade700 : null,
                      ),
                    ),
                    Text(
                      isArrived
                          ? "The driver is waiting for you"
                          : _locations[_currentLocationIndex],
                      style: TextStyle(
                        color: isArrived
                            ? Colors.green.shade600
                            : colorScheme.primary,
                        fontSize: 11,
                        fontWeight: isArrived ? FontWeight.w500 : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (isArrived)
                const _BlinkingIcon(icon: Icons.hail, color: Colors.green)
              else
                const Icon(Icons.map_outlined, color: Colors.grey, size: 20),
            ],
          ),
        );
      },
    );
  }
}

class _MovingIcon extends StatefulWidget {
  final Color color;
  const _MovingIcon({required this.color});

  @override
  State<_MovingIcon> createState() => _MovingIconState();
}

class _MovingIconState extends State<_MovingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _move;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _move = Tween<double>(begin: -2.0, end: 2.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _move,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_move.value, 0),
          child: Icon(Icons.delivery_dining, color: widget.color, size: 24),
        );
      },
    );
  }
}

class _BlinkingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _BlinkingIcon({required this.icon, required this.color});

  @override
  State<_BlinkingIcon> createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<_BlinkingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Icon(widget.icon, color: widget.color),
    );
  }
}

class _DriverTrackingSheet extends StatefulWidget {
  const _DriverTrackingSheet();

  @override
  State<_DriverTrackingSheet> createState() => _DriverTrackingSheetState();
}

class _DriverTrackingSheetState extends State<_DriverTrackingSheet> {
  GoogleMapController? _controller;
  late Timer _markerTimer;

  // Mock coordinates for Nepal (Kathmandu area)
  static const LatLng _restaurantLoc = LatLng(27.700769, 85.300140);
  static const LatLng _deliveryLoc = LatLng(27.7172, 85.3240); // Destination

  LatLng _driverLoc = _restaurantLoc;
  int _step = 0;
  final int _totalSteps = 10;

  @override
  void initState() {
    super.initState();
    _markerTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_step < _totalSteps) {
        if (mounted) {
          setState(() {
            _step++;
            // Interpolate position
            double lat =
                _restaurantLoc.latitude +
                (_deliveryLoc.latitude - _restaurantLoc.latitude) *
                    (_step / _totalSteps);
            double lng =
                _restaurantLoc.longitude +
                (_deliveryLoc.longitude - _restaurantLoc.longitude) *
                    (_step / _totalSteps);
            _driverLoc = LatLng(lat, lng);
          });
          _controller?.animateCamera(CameraUpdate.newLatLng(_driverLoc));
        }
      } else {
        _markerTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _markerTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _driverLoc,
                zoom: 15,
              ),
              onMapCreated: (controller) => _controller = controller,
              markers: {
                Marker(
                  markerId: const MarkerId('restaurant'),
                  position: _restaurantLoc,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueOrange,
                  ),
                  infoWindow: const InfoWindow(title: 'Restaurant'),
                ),
                Marker(
                  markerId: const MarkerId('delivery'),
                  position: _deliveryLoc,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                  infoWindow: const InfoWindow(title: 'Delivery Location'),
                ),
                Marker(
                  markerId: const MarkerId('driver'),
                  position: _driverLoc,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: const InfoWindow(title: 'Driver'),
                ),
              },
              // TODO: Add Google Maps API key in AndroidManifest.xml and AppDelegate.swift
            ),
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.close),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        size: 40,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Driver is on the way",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _step == _totalSteps
                                  ? "Arrived!"
                                  : "Estimated time: ${(_totalSteps - _step) * 2} mins",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
