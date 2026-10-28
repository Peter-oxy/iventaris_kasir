import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/api_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/view_state.dart';

class ApiDetailScreen extends StatefulWidget {
  final int productId;
  const ApiDetailScreen({super.key, required this.productId});
  @override
  State<ApiDetailScreen> createState() => _ApiDetailScreenState();
}

class _ApiDetailScreenState extends State<ApiDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<ApiProvider>().fetchDetail(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: switch (api.detailState) {
        ViewState.loading => const Center(child: CircularProgressIndicator()),
        ViewState.error || ViewState.empty => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline, size: 72, color: Colors.red.shade200),
                const SizedBox(height: 12),
                Text(api.detailError ?? 'Data tidak ditemukan',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style:
                      FilledButton.styleFrom(minimumSize: const Size(160, 46)),
                  onPressed: () => api.fetchDetail(widget.productId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ]),
            ),
          ),
        ViewState.loaded => ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Card(
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  child: Image.network(api.detail!.thumbnail,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 64)),
                ),
              ),
              const SizedBox(height: 16),
              Text(api.detail!.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                Chip(
                    label: Text(api.detail!.category),
                    backgroundColor: cs.primaryContainer,
                    side: BorderSide.none),
                Chip(
                    avatar: const Icon(Icons.sell_outlined, size: 16),
                    label: Text(api.detail!.brand),
                    side: BorderSide.none),
                Chip(
                    avatar:
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                    label: Text('${api.detail!.rating}'),
                    side: BorderSide.none),
              ]),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Harga referensi',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                              Text('\$${api.detail!.price}',
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800)),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Estimasi Rupiah',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                              Text(rupiah(api.detail!.price * kKursUsdKeRp),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary)),
                            ]),
                      ]),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Deskripsi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(api.detail!.description,
                  style: TextStyle(color: Colors.grey.shade800, height: 1.4)),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Tambah ke Inventaris'),
                onPressed: () async {
                  final uid = context.read<AuthProvider>().user!.uid;
                  final d = api.detail!;
                  final items = context.read<ItemProvider>();
                  await items.add(uid, d.title, 1, d.price * kKursUsdKeRp);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Ditambahkan ke inventaris')));
                  }
                },
              ),
            ],
          ),
      },
    );
  }
}