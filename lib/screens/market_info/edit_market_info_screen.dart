import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/providers/market_info_provider.dart';
import 'package:masoko_tips/models/market_info.dart';
import 'package:masoko_tips/widgets/custom_app_bar.dart';
import 'package:masoko_tips/widgets/custom_drawer.dart';
import 'package:masoko_tips/widgets/loading_indicator.dart';
import 'package:masoko_tips/utils/theme.dart';

class EditMarketInfoScreen extends StatefulWidget {
  final MarketInfo? marketInfo;

  const EditMarketInfoScreen({super.key, this.marketInfo});

  @override
  State<EditMarketInfoScreen> createState() => _EditMarketInfoScreenState();
}

class _EditMarketInfoScreenState extends State<EditMarketInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.marketInfo != null) {
      _titleController.text = widget.marketInfo!.title;
      _contentController.text = widget.marketInfo!.content;
      _locationController.text = widget.marketInfo!.location ?? '';
      _categoryController.text = widget.marketInfo!.category ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveMarketInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final marketInfoProvider =
          Provider.of<MarketInfoProvider>(context, listen: false);

      if (widget.marketInfo == null) {
        await marketInfoProvider.addMarketInfo(
          title: _titleController.text,
          content: _contentController.text,
          location: _locationController.text,
          category: _categoryController.text,
        );
      } else {
        await marketInfoProvider.updateMarketInfo(
          id: widget.marketInfo!.id,
          title: _titleController.text,
          content: _contentController.text,
          location: _locationController.text,
          category: _categoryController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
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
      appBar: CustomAppBar(
        title:
            widget.marketInfo == null ? 'Add Market Info' : 'Edit Market Info',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveMarketInfo,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const LoadingIndicator()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter content';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveMarketInfo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.marketInfo == null
                          ? 'Add Market Info'
                          : 'Save Changes',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
