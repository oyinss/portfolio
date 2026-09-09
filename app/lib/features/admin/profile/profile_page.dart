/// Owner profile editor (§19) with photo + resume uploads (§52).
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/api/portfolio_repository.dart';
import '../../../core/utils/image_optimize.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _key = GlobalKey<FormState>();
  final _fields = <String, TextEditingController>{};
  bool _saving = false;
  bool _uploadingPhoto = false;
  bool _uploadingResume = false;

  static const _defs = [
    ('name', 'Name'),
    ('headline', 'Headline (e.g. HELLO, I\'M)'),
    ('title', 'Professional Title'),
    ('intro', 'Short Introduction'),
    ('bio', 'Biography'),
    ('email', 'Email'),
    ('phone', 'Phone'),
    ('location', 'Location'),
    ('availability', 'Availability'),
    ('yearsExperience', 'Years of Experience'),
    ('currentRole', 'Current Role'),
    ('interests', 'Interests (comma separated)'),
    ('profileImageUrl', 'Profile Photo URL'),
    ('resumeUrl', 'Resume URL'),
  ];

  TextEditingController _c(String key, [String initial = '']) =>
      _fields.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    final admin = AdminRepository(auth: AuthScope.of(context));
    setState(() => _saving = true);
    try {
      await admin.updateProfile({
        for (final (key, _) in _defs)
          if (key == 'interests')
            'interests': _c(key).text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          else
            key: _c(key).text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved.')));
      }
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final auth = AuthScope.of(context);
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final optimized = optimizeImage(await picked.readAsBytes(), picked.name);
      final res = await AdminRepository(auth: auth).uploadImage(
        bytes: optimized.bytes,
        filename: optimized.filename,
        mimeType: optimized.mimeType,
      );
      _c('profileImageUrl').text = (res['url'] as String?) ?? (res['proxyUrl'] as String?) ?? '${res['key']}';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Photo uploaded — save to apply.')));
      }
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _uploadResume() async {
    final auth = AuthScope.of(context);
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    final file = files.singleOrNull;
    if (file == null) return;
    setState(() => _uploadingResume = true);
    try {
      final res = await AdminRepository(auth: auth).uploadImage(
        bytes: (await file.readAsBytes()).toList(),
        filename: file.name,
        mimeType: 'application/pdf',
      );
      _c('resumeUrl').text = (res['url'] as String?) ?? (res['proxyUrl'] as String?) ?? '${res['key']}';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Resume uploaded — save to apply.')));
      }
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _uploadingResume = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AdminScaffold(
      title: 'Profile',
      action:
          FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
      body: AsyncView(
        load: repo.profile,
        builder: (context, p) {
          _c('name', p.name);
          _c('headline', p.headline);
          _c('title', p.title);
          _c('intro', p.intro);
          _c('bio', p.bio);
          _c('email', p.email);
          _c('phone', p.phone);
          _c('location', p.location);
          _c('availability', p.availability);
          _c('yearsExperience', p.yearsExperience);
          _c('currentRole', p.currentRole);
          _c('interests', p.interests.join(', '));
          _c('profileImageUrl', p.profileImageUrl ?? '');
          _c('resumeUrl', p.resumeUrl ?? '');
          return Form(
            key: _key,
            child: Column(
              children: [
                _UploadRow(label: 'Profile Photo', busy: _uploadingPhoto, onUpload: _uploadPhoto),
                _UploadRow(label: 'Resume (PDF)', busy: _uploadingResume, onUpload: _uploadResume),
                const SizedBox(height: 8),
                for (final (key, label) in _defs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _c(key),
                      maxLines: key == 'bio' || key == 'intro' ? 3 : 1,
                      decoration:
                          InputDecoration(labelText: label, border: const OutlineInputBorder()),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onUpload;
  const _UploadRow({required this.label, required this.busy, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          OutlinedButton.icon(
            onPressed: busy ? null : onUpload,
            icon: busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload, size: 18),
            label: const Text('Upload'),
          ),
        ],
      ),
    );
  }
}
