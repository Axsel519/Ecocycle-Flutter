import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final MapController _mapController = MapController();

  final List<DeliveryOrder> _orders = [
    DeliveryOrder(
      id: "ORD-8801",
      customerName: "Ahmed Youssef",
      phone: "+201001234567",
      address: "Street 9, Building 14, Maadi, Cairo",
      items: "Plastic Bottles (12kg), Aluminum Cans (4kg)",
      payout: "EGP 240",
      status: "Pending",
      lat: 29.9602,
      lng: 31.2569,
    ),
    DeliveryOrder(
      id: "ORD-8802",
      customerName: "Sara Hassan",
      phone: "+201119876543",
      address: "El-Tahrir St, Block 4, Dokki, Giza",
      items: "Paper & Cardboard (25kg)",
      payout: "EGP 150",
      status: "Pending",
      lat: 30.0371,
      lng: 31.2118,
    ),
    DeliveryOrder(
      id: "ORD-8803",
      customerName: "Mohamed Ali",
      phone: "+201223334444",
      address: "Al-Ahram St, Near Giza Square",
      items: "Glass Bottles (18kg), E-Waste (2 units)",
      payout: "EGP 310",
      status: "In Progress",
      lat: 30.0131,
      lng: 31.2089,
    ),
  ];

  DeliveryOrder? _selectedOrder;
  String _filterStatus = "All";

  @override
  void initState() {
    super.initState();
    if (_orders.isNotEmpty) {
      _selectedOrder = _orders.first;
    }
  }

  void _handleStatusUpdate(String orderId, String newStatus) {
    setState(() {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index].status = newStatus;
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = _orders[index];
        }
      }
    });
  }

  void _selectOrder(DeliveryOrder order) {
    setState(() {
      _selectedOrder = order;
    });
    _mapController.move(LatLng(order.lat, order.lng), 15.0);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((order) {
      if (_filterStatus == "All") return true;
      return order.status == _filterStatus;
    }).toList();

    final completedCount = _orders.where((o) => o.status == "Completed").length;
    final inProgressCount = _orders
        .where((o) => o.status == "In Progress")
        .length;

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          "Courier Dashboard",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            _buildBannerSection(inProgressCount, completedCount),
            const SizedBox(height: 20),

            // Grid Layout (Responsive Side-by-Side or Stacked)
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildOrdersListCard(filteredOrders),
                      ),
                      const SizedBox(width: 20),
                      Expanded(flex: 7, child: _buildMapDetailsCard()),
                    ],
                  )
                : Column(
                    children: [
                      _buildOrdersListCard(filteredOrders),
                      const SizedBox(height: 20),
                      _buildMapDetailsCard(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection(int inProgress, int completed) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A47),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmall = constraints.maxWidth < 600;
          return Flex(
            direction: isSmall ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: isSmall ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_shipping,
                            color: Colors.lightBlueAccent,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Courier Logistics Portal",
                            style: TextStyle(
                              color: Colors.lightBlueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Pickup Operations & Logistics",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "View assigned waste collection requests, navigate directly to clients, and manage collection lifecycle.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (isSmall) const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatBox("Active Orders", "$inProgress", Colors.orange),
                  const SizedBox(width: 12),
                  _buildStatBox("Completed Today", "$completed", Colors.green),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBox(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersListCard(List<DeliveryOrder> filteredOrders) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Assigned Tasks (${filteredOrders.length})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Pending", "In Progress", "Completed"]
                  .map(
                    (status) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: _filterStatus == status,
                        onSelected: (_) {
                          setState(() {
                            _filterStatus = status;
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Scrollable Orders List
          filteredOrders.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("No orders found for this filter."),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final isSelected = _selectedOrder?.id == order.id;

                    return InkWell(
                      onTap: () => _selectOrder(order),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.withValues(alpha: 0.05)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                _buildStatusBadge(order.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    order.address,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    order.items,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  order.payout,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMapDetailsCard() {
    if (_selectedOrder == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Select an order from the list to view route & details",
        ),
      );
    }

    final order = _selectedOrder!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(order.id, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.blue),
                    onPressed: () => _makePhoneCall(order.phone),
                    tooltip: "Call Client",
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigation, color: Colors.green),
                    onPressed: () => _openMaps(order.lat, order.lng),
                    tooltip: "Open Navigation",
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Info Block
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pickup Location",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.address,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Waste Items",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.items,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action Buttons
          Row(
            children: [
              const Text(
                "Pickup Status: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (order.status == "Pending")
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _handleStatusUpdate(order.id, "In Progress"),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start Pickup Request"),
                ),
              if (order.status == "In Progress")
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _handleStatusUpdate(order.id, "Completed"),
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Mark as Collected"),
                ),
              if (order.status == "Completed")
                const Chip(
                  avatar: Icon(Icons.verified, color: Colors.green),
                  label: Text("Collected Successfully"),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Interactive Map Container
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(order.lat, order.lng),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(order.lat, order.lng),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case "In Progress":
        color = Colors.orange;
        break;
      case "Completed":
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DeliveryOrder {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final String items;
  final String payout;
  String status;
  final double lat;
  final double lng;

  DeliveryOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
    required this.payout,
    required this.status,
    required this.lat,
    required this.lng,
  });
}
