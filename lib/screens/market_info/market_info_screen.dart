import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/models/market_info.dart';
import 'package:masoko_tips/providers/market_info_provider.dart';
import 'package:masoko_tips/screens/market_info/market_info_detail_screen.dart';
import 'package:masoko_tips/widgets/loading_indicator.dart';
import 'package:masoko_tips/widgets/error_message.dart';
import 'package:masoko_tips/widgets/empty_state.dart';

class MarketInfoScreen extends StatefulWidget {
  final bool showAppBar;

  const MarketInfoScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<MarketInfoScreen> createState() => _MarketInfoScreenState();
}

class _MarketInfoScreenState extends State<MarketInfoScreen> {
  bool _isLoading = false;
  String? _error;
  List<MarketInfo> _marketInfoList = [];

  @override
  void initState() {
    super.initState();
    _loadMarketInfo();
  }

  Future<void> _loadMarketInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<MarketInfoProvider>(context, listen: false);
      await provider.loadMarketInfo();
      setState(() {
        _marketInfoList = provider.marketInfoList;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Market News'),
            )
          : null,
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? ErrorMessage(error: _error!, onRetry: _loadMarketInfo)
              : _marketInfoList.isEmpty
                  ? const EmptyState(
                      icon: Icons.info_outline,
                      message: 'No market news available',
                      actionText: '',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMarketInfo,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _marketInfoList.length,
                        itemBuilder: (context, index) {
                          final marketInfo = _marketInfoList[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MarketInfoDetailScreen(
                                      marketInfo: marketInfo,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: marketInfo.imageUrl.isNotEmpty
                                        ? Image.network(
                                            marketInfo.imageUrl,
                                            height: 180,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 180,
                                                color: Colors.grey[200],
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 180,
                                            color: Colors.grey[300],
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          marketInfo.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          marketInfo.content,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
