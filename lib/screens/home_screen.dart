import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../providers/view_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text('Anda harus login lagi untuk mengakses data.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(90, 42)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<ItemProvider>().stop();
    await context.read<AuthProvider>().logout();
  }

  Future<void> _showForm({ItemModel? item}) async {
    final uid = context.read<AuthProvider>().user!.uid;
    final provider = context.read<ItemProvider>();
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: item?.name ?? '');
    final stock = TextEditingController(text: item?.stock.toString() ?? '');
    final price =
        TextEditingController(text: item?.price.toStringAsFixed(0) ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            Text(item == null ? 'Tambah Barang' : 'Edit Barang',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            TextFormField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Nama barang',
                  prefixIcon: Icon(Icons.label_outline)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Stok',
                      prefixIcon: Icon(Icons.inventory_2_outlined)),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null) return 'Angka';
                    if (n < 0) return 'Tidak boleh negatif';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Harga (Rp)',
                      prefixIcon: Icon(Icons.payments_outlined)),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    if (n == null) return 'Angka';
                    if (n < 0) return 'Tidak boleh negatif';
                    return null;
                  },
                ),
              ),
            ]),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final s = int.parse(stock.text);
                final p = double.parse(price.text);
                Navigator.pop(ctx);
                if (item == null) {
                  await provider.add(uid, name.text.trim(), s, p);
                } else {
                  await provider.update(ItemModel(
                    id: item.id,
                    name: name.text.trim(),
                    stock: s,
                    price: p,
                    createdAt: item.createdAt,
                    uid: item.uid,
                  ));
                }
              },
              child: Text(item == null ? 'Simpan' : 'Perbarui'),
            ),
          ]),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(ItemModel it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus barang?'),
        content: Text('"${it.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red, minimumSize: const Size(90, 42)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ItemProvider>();

    // Filter pencarian di sisi client (Dart)
    final filtered = p.items
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    final totalStok = p.items.fold<int>(0, (a, e) => a + e.stock);
    final nilaiAset = p.items.fold<double>(0, (a, e) => a + e.stock * e.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: switch (p.state) {
        ViewState.loading => const Center(child: CircularProgressIndicator()),
        ViewState.error => _Message(
            icon: Icons.error_outline,
            color: Colors.red,
            title: 'Terjadi kesalahan',
            subtitle: p.errorMessage ?? '',
          ),
        ViewState.empty => const _Message(
            icon: Icons.inventory_2_outlined,
            color: Colors.grey,
            title: 'Belum ada barang',
            subtitle: 'Tekan tombol Tambah untuk mulai mencatat stok.',
          ),
        ViewState.loaded => Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(children: [
                _StatCard(
                    icon: Icons.category_outlined,
                    label: 'Jenis',
                    value: '${p.items.length}'),
                const SizedBox(width: 10),
                _StatCard(
                    icon: Icons.layers_outlined,
                    label: 'Total stok',
                    value: '$totalStok'),
                const SizedBox(width: 10),
                _StatCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Nilai aset',
                    value: rupiah(nilaiAset),
                    small: true),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                    hintText: 'Cari barang...',
                    prefixIcon: Icon(Icons.search)),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const _Message(
                      icon: Icons.search_off,
                      color: Colors.grey,
                      title: 'Tidak ditemukan',
                      subtitle: 'Coba kata kunci lain.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final it = filtered[i];
                        return _ItemCard(
                          item: it,
                          onEdit: () => _showForm(item: it),
                          confirm: () => _confirmDelete(it),
                          onDelete: () => p.delete(it.id),
                        );
                      },
                    ),
            ),
          ]),
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool small;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      this.small = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      fontSize: small ? 15 : 20, fontWeight: FontWeight.w800)),
            ),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ]),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onEdit;
  final Future<bool> Function() confirm;
  final VoidCallback onDelete;
  const _ItemCard(
      {required this.item,
      required this.onEdit,
      required this.confirm,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final low = item.stock <= 5;
    final badge =
        item.stock == 0 ? Colors.red : (low ? Colors.orange : Colors.green);
    final badgeText =
        item.stock == 0 ? 'Habis' : (low ? 'Stok menipis' : 'Tersedia');

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirm(),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
            child: Row(children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(rupiah(item.price),
                          style: TextStyle(color: Colors.grey.shade700)),
                    ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${item.stock} pcs',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badge.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badgeText,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badge)),
                ),
              ]),
              // Tombol hapus yang selalu terlihat
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  if (await confirm()) onDelete();
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _Message(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 72, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
        ]),
      ),
    );
  }
}