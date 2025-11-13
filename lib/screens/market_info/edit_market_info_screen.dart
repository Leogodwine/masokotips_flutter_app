import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masoko_tips/providers/market_info_provider.dart';
import 'package:masoko_tips/models/market_info.dart';

class EditMarketInfoScreen extends StatefulWidget {
  final MarketInfo? marketInfo;

  const EditMarketInfoScreen({Key? key, this.marketInfo}) : super(key: key);

  @override
  State<EditMarketInfoScreen> createState() => _EditMarketInfoScreenState();
}

class _EditMarketInfoScreenState extends State<EditMarketInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _categoryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.marketInfo?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.marketInfo?.description ?? '');
    _locationController =
        TextEditingController(text: widget.marketInfo?.location ?? '');
    _categoryController =
        TextEditingController(text: widget.marketInfo?.category ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveMarketInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final marketInfoProvider =
          Provider.of<MarketInfoProvider>(context, listen: false);

      if (widget.marketInfo == null) {
        await marketInfoProvider.addMarketInfo(
          title: _titleController.text,
          description: _descriptionController.text,
          content: _descriptionController.text,
          location: _locationController.text,
          category: _categoryController.text,
        );
      } else {
        await marketInfoProvider.updateMarketInfo(
          id: widget.marketInfo?.id.toString() ?? '',
          title: _titleController.text,
          description: _descriptionController.text,
          content: _descriptionController.text,
          location: _locationController.text,
          category: _categoryController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving market info: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.marketInfo == null ? 'Add Market Info' : 'Edit Market Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveMarketInfo,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMarketInfo,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(widget.marketInfo == null ? 'Add' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
