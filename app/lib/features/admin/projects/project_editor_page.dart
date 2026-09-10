/// Add/edit project (§21) with screenshot upload → R2 (§22).
library;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/utils/image_optimize.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class ProjectEditorPage extends StatefulWidget {
  final String? id; // null = new
  const ProjectEditorPage({super.key, this.id});

  @override
  State<ProjectEditorPage> createState() => _ProjectEditorPageState();
}

class _ProjectEditorPageState extends State<ProjectEditorPage> {
  final _key = GlobalKey<FormState>();
  final _f = <String, TextEditingController>{};
  bool _featured = false;
  String _status = 'draft';
  bool _saving = false;
  bool _uploading = false;
  bool _loaded = false;

  TextEditingController _c(String k, [String v = '']) =>
      _f.putIfAbsent(k, () => TextEditingController(text: v));

  @override
  void dispose() {
    for (final c in _f.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(Map<String, dynamic> p) {
    if (_loaded) return;
    _loaded = true;
    _c('title', '${p['title'] ?? ''}');
    _c('slug', '${p['slug'] ?? ''}');
    _c('short', '${p['short_description'] ?? ''}');
    _c('description', '${p['description'] ?? ''}');
    _c('image', '${p['image_url'] ?? ''}');
    _c('live', '${p['live_url'] ?? ''}');
    _c('github', '${p['github_url'] ?? ''}');
    _c('techs', ((p['technologies'] as List?) ?? []).join(', '));
    _c('type', '${p['type'] ?? ''}');
    _c('order', '${p['display_order'] ?? 0}');
    _c('date', '${p['date_label'] ?? ''}');
    _c('problem', '${p['problem'] ?? ''}');
    _c('solution', '${p['solution'] ?? ''}');
    _c('features', ((p['features'] as List?) ?? []).join('\n'));
    _featured = (p['featured'] as int? ?? 0) == 1;
    _status = '${p['status'] ?? 'draft'}';
  }

  Map<String, dynamic> _data() => {
        'title': _c('title').text.trim(),
        if (_c('slug').text.trim().isNotEmpty) 'slug': _c('slug').text.trim(),
        'shortDescription': _c('short').text.trim(),
        'description': _c('description').text.trim(),
        if (_c('image').text.trim().isNotEmpty) 'imageUrl': _c('image').text.trim(),
        if (_c('live').text.trim().isNotEmpty) 'liveUrl': _c('live').text.trim(),
        if (_c('github').text.trim().isNotEmpty) 'githubUrl': _c('github').text.trim(),
        'technologies':
            _c('techs').text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'type': _c('type').text.trim(),
        'featured': _featured,
        'status': _status,
        'displayOrder': int.tryParse(_c('order').text.trim()) ?? 0,
        'dateLabel': _c('date').text.trim(),
        'problem': _c('problem').text.trim(),
        'solution': _c('solution').text.trim(),
        'features': _c('features')
            .text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      };

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    final admin = AdminRepository(auth: AuthScope.of(context));
    setState(() => _saving = true);
    try {
      await admin.saveProject(_data(), id: widget.id);
      if (mounted) goBackAfterSave(context, '/admin/projects');
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final auth = AuthScope.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final raw = await picked.readAsBytes();
      final optimized = optimizeImage(raw, picked.name);
      final res = await AdminRepository(auth: auth).uploadImage(
        bytes: optimized.bytes,
        filename: optimized.filename,
        mimeType: optimized.mimeType,
      );
      final url = (res['url'] as String?) ?? (res['proxyUrl'] as String?);
      _c('image').text = url ?? '${res['key']}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(url == null ? 'Uploaded (no public URL configured yet).' : 'Screenshot uploaded.')),
        );
      }
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.id == null;
    return AdminScaffold(
      title: isNew ? 'Add Project' : 'Edit Project',
      backTo: '/admin/projects',
      action: FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
      body: isNew
          ? _form()
          : AsyncView(
              load: () async {
                final all = await AdminRepository(auth: AuthScope.of(context)).allProjects();
                return all.firstWhere((p) => '${p['id']}' == widget.id, orElse: () => {});
              },
              builder: (context, p) {
                if (p.isEmpty) return const Text('Project not found.');
                _fill(p);
                return _form();
              },
            ),
    );
  }

  Widget _form() {
    return Form(
      key: _key,
      child: Column(
        children: [
          _field('title', 'Project Name', required: true),
          _field('slug', 'Slug (auto from title if empty)'),
          _field('short', 'Short Description', lines: 2),
          _field('description', 'Full Description', lines: 4),
          Row(
            children: [
              Expanded(child: _field('image', 'Screenshot URL')),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _uploading ? null : _pickAndUpload,
                icon: _uploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload, size: 18),
                label: const Text('Upload'),
              ),
            ],
          ),
          _field('live', 'Live Project URL'),
          _field('github', 'GitHub URL'),
          _field('techs', 'Technologies (comma separated)'),
          _field('type', 'Project Type'),
          _field('order', 'Display Order', number: true),
          _field('date', 'Date Label (e.g. 2025)'),
          _field('problem', 'Problem', lines: 3),
          _field('solution', 'Solution', lines: 3),
          _field('features', 'Features (one per line)', lines: 4),
          SwitchListTile(title: const Text('Featured (homepage)'), value: _featured, onChanged: (v) => setState(() => _featured = v)),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'draft', child: Text('Draft')),
              DropdownMenuItem(value: 'published', child: Text('Published')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'draft'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _field(String key, String label, {bool required = false, int lines = 1, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _c(key),
        maxLines: lines,
        keyboardType: number ? TextInputType.number : null,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
      ),
    );
  }
}
