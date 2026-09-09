library;

import 'package:flutter/material.dart';

import '../../core/api/portfolio_repository.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/social_icon.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AsyncView(
      load: repo.profile,
      builder: (context, p) => PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: "Let's Work Together",
              subtitle: 'Have a project or opportunity? Send a message.',
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ContactTile(icon: Icons.mail_outline, label: 'Email', value: p.email),
                _ContactTile(icon: Icons.phone_outlined, label: 'Phone', value: p.phone),
                _ContactTile(icon: Icons.place_outlined, label: 'Location', value: p.location),
              ],
            ),
            const SizedBox(height: 16),
            AsyncView(
              load: repo.socials,
              builder: (context, socials) {
                if (socials.isEmpty) return const SizedBox.shrink();
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final s in socials)
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: SocialIcon(platform: s.platform),
                        label: Text(s.platform),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const _ContactForm(),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _key,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subject,
                decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a subject' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _message,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a message' : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    if (!_key.currentState!.validate()) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Message storage arrives with the backend (Phase 5). Nothing was sent.'),
                      ),
                    );
                  },
                  child: const Text('Send Message'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
