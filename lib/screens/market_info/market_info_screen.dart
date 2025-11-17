import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/providers/market_info_provider.dart';
import 'package:masoko_tips/screens/market_info/market_info_detail_screen.dart';
import 'package:masoko_tips/widgets/loading_indicator.dart';
import 'package:masoko_tips/widgets/error_message.dart';
import 'package:masoko_tips/widgets/empty_state.dart';
import 'package:masoko_tips/widgets/market_info_card.dart';

class MarketInfoScreen extends StatefulWidget {
  final bool showAppBar;

  const MarketInfoScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<MarketInfoScreen> createState() => _MarketInfoScreenState();
}

class _MarketInfoScreenState extends State<MarketInfoScreen> {
  @override
  void initState() {
    super.initState();
    // Data is loaded via the provider, which is initialized earlier.
    // We can trigger a refresh here if needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMarketInfo();
    });
  }

  Future<void> _loadMarketInfo() async {
    final provider = Provider.of<MarketInfoProvider>(context, listen: false);
    await provider.loadMarketInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Market News'),
            )
          : null,
      body: Consumer<MarketInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (provider.error != null) {
            return ErrorMessage(
                error: provider.error!, onRetry: _loadMarketInfo);
          }

          if (provider.marketInfoList.isEmpty) {
            return const EmptyState(
              icon: Icons.newspaper_outlined,
              message: 'No market news is available right now.',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMarketInfo,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: provider.marketInfoList.length,
              itemBuilder: (context, index) {
                final marketInfo = provider.marketInfoList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: MarketInfoCard(
                    marketInfo: marketInfo,
                    width: double.infinity, // Make card take full width
                    height: 250, // Adjust height for vertical list
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
