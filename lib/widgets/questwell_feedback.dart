import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/questwell_feedback_draft.dart';
import '../services/questwell_feedback_service.dart';
import 'questwell_typography.dart';

abstract final class QuestwellFeedback {
  static const build = String.fromEnvironment('QUESTWELL_BUILD', defaultValue: 'development');
  static QuestwellFeedbackDraft? _previewDraft;

  static Future<void> open(BuildContext context, {required String screen, bool preview = false}) async {
    final ownerId = preview ? null : QuestwellFeedbackService.userId;
    if (!preview && ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sign in to send feedback.')));
      return;
    }
    final store = ownerId == null ? null : QuestwellFeedbackDraftStore(ownerId);
    QuestwellFeedbackDraft? saved;
    try { saved = preview ? _previewDraft : await store!.load(); } catch (_) {}
    if (!context.mounted) return;
    final draft = saved ?? QuestwellFeedbackDraft(screen: screen, build: build,
      platform: '${kIsWeb ? 'web' : 'native'}-${defaultTargetPlatform.name}');
    await showModalBottomSheet<void>(context: context, isScrollControlled: true,
      useSafeArea: true, isDismissible: false, enableDrag: false,
      backgroundColor: const Color(0xFF152332),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        return Padding(padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: SizedBox(height: (media.size.height - media.viewInsets.bottom) * .92,
            child: QuestwellFeedbackForm(initialDraft: draft, preview: preview,
              onSave: (value) async {
                if (preview) { _previewDraft = value; } else { await store!.save(value); }
              },
              onClear: () async {
                if (preview) { _previewDraft = null; } else { await store!.clear(); }
              },
              onSubmit: (value) async {
                if (!preview) await QuestwellFeedbackService.submit(value, ownerId!);
              },
              onClose: () => Navigator.of(sheetContext).pop(),
            )));
      });
  }
}

class QuestwellFeedbackForm extends StatefulWidget {
  const QuestwellFeedbackForm({super.key, required this.initialDraft,
    required this.onSubmit, required this.onSave, required this.onClear,
    required this.onClose, this.preview = false});
  final QuestwellFeedbackDraft initialDraft;
  final Future<void> Function(QuestwellFeedbackDraft) onSubmit, onSave;
  final Future<void> Function() onClear;
  final VoidCallback onClose;
  final bool preview;
  @override
  State<QuestwellFeedbackForm> createState() => _QuestwellFeedbackFormState();
}

class _QuestwellFeedbackFormState extends State<QuestwellFeedbackForm> {
  final _form = GlobalKey<FormState>();
  late QuestwellFeedbackDraft _draft = widget.initialDraft;
  Timer? _saveTimer;
  bool _sending = false, _sent = false;
  String? _error, _storageNote;
  Uint8List? _attachmentBytes;
  String? _attachmentName, _attachmentMime;
  static const _gold = Color(0xFFE4C586), _muted = Color(0xFFB9C7D7);

  void _edit(QuestwellFeedbackDraft value) {
    setState(() { _draft = value; _error = null; });
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), () => unawaited(_persist()));
  }

  Future<void> _persist() async {
    try {
      await widget.onSave(_draft);
      if (mounted && _storageNote != null) setState(() => _storageNote = null);
    } catch (_) {
      if (mounted) setState(() => _storageNote = 'Could not save a local copy. Keep this form open until your note is sent.');
    }
  }

  Future<void> _close() async {
    if (_sending) return;
    _saveTimer?.cancel();
    if (!_sent) await _persist();
    if (mounted && (_storageNote == null || _sent)) widget.onClose();
  }

  Future<void> _pickScreenshot() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() => _error = 'Could not read that screenshot. Please choose it again.');
        return;
      }
      if (bytes.length > QuestwellFeedbackService.maxAttachmentBytes) {
        setState(() => _error = 'Screenshots must be 5 MB or smaller.');
        return;
      }
      final ext = (file.extension ?? '').toLowerCase();
      final mime = ext == 'png' ? 'image/png' : ext == 'webp' ? 'image/webp'
          : (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : null;
      if (mime == null) {
        setState(() => _error = 'Use a PNG, JPEG, or WebP screenshot.');
        return;
      }
      setState(() {
        _attachmentBytes = bytes;
        _attachmentName = file.name;
        _attachmentMime = mime;
        _error = null;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not open your screenshots. Please try again.');
    }
  }

  Future<void> _submit() async {
    if (_sending || _sent || !_form.currentState!.validate()) return;
    _saveTimer?.cancel();
    setState(() { _sending = true; _error = null; _draft = _draft.copyWith(attempted: true); });
    await _persist();
    String? uploadedPath;
    try {
      if (!widget.preview && _attachmentBytes != null) {
        final ownerId = QuestwellFeedbackService.userId;
        if (ownerId == null) {
          throw const QuestwellFeedbackException('Sign in before attaching a screenshot.');
        }
        uploadedPath = await QuestwellFeedbackService.uploadScreenshot(
          ownerId: ownerId,
          feedbackId: _draft.id,
          bytes: _attachmentBytes!,
          mimeType: _attachmentMime!,
        );
        await QuestwellFeedbackService.submit(_draft, ownerId, attachmentPath: uploadedPath);
      } else {
        await widget.onSubmit(_draft);
      }
      try { await widget.onClear(); } catch (_) {
        if (mounted) setState(() => _storageNote = 'Your feedback was sent, but its local draft could not be cleared.');
      }
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (uploadedPath != null) {
        try { await QuestwellFeedbackService.removeScreenshot(uploadedPath); } catch (_) {}
      }
      if (mounted) setState(() => _error = error is QuestwellFeedbackException
        ? error.message : 'We could not confirm delivery. Your note is still here. Check your connection and tap Send feedback to retry.');
    } finally { if (mounted) setState(() => _sending = false); }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (!_sent) unawaited(_persist());
    super.dispose();
  }

  Widget _field({required String label, required String value,
    required ValueChanged<String> onChanged, int maxLength = 1000,
    int lines = 3, bool requiredField = false, bool email = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(initialValue: value, enabled: !_sending,
        style: QuestwellTypography.body(color: const Color(0xFFF0E5CC)),
        minLines: lines, maxLines: lines == 1 ? 1 : lines + 2, maxLength: maxLength,
        keyboardType: email ? TextInputType.emailAddress : lines == 1 ? TextInputType.text : TextInputType.multiline,
        decoration: InputDecoration(labelText: label, alignLabelWithHint: true,
          labelStyle: QuestwellTypography.body(color: _muted),
          counterStyle: QuestwellTypography.body(fontSize: 11, color: _muted),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF65563D))),
          border: const OutlineInputBorder()),
        onChanged: onChanged,
        validator: (text) {
          final trimmed = text?.trim() ?? '';
          if (requiredField && trimmed.isEmpty) return 'Please add a few words.';
          if (email && trimmed.isNotEmpty && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed)) {
            return 'Enter an email address, or leave this blank.';
          }
          return null;
        }));

  @override
  Widget build(BuildContext context) => PopScope(canPop: !_sending,
    child: SafeArea(top: false, child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 12, 8, 4), child: Row(children: [
        Expanded(child: Text(_sent ? 'NOTE RECEIVED' : 'SEND FEEDBACK',
          style: QuestwellTypography.sectionHeading(size: 11))),
        IconButton(tooltip: 'Close feedback', onPressed: _sending ? null : _close,
          icon: const Icon(Icons.close, color: _gold)),
      ])),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: _sent ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.mark_email_read_outlined, color: _gold, size: 42),
          const SizedBox(height: 16),
          Text(widget.preview ? 'Preview complete. No feedback was sent.'
            : 'Thanks, adventurer. Your note is in our journal.',
            style: QuestwellTypography.body(fontSize: 18, color: const Color(0xFFF0E5CC))),
          if (_storageNote != null) Padding(padding: const EdgeInsets.only(top: 12),
            child: Text(_storageNote!, style: QuestwellTypography.body(color: _muted))),
          const SizedBox(height: 24),
          FilledButton(onPressed: _close, child: const Text('Back to Questwell')),
        ]) : Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Help shape Questwell. A quick observation is enough.',
            style: QuestwellTypography.body(fontSize: 16, color: const Color(0xFFF0E5CC))),
          const SizedBox(height: 8),
          Text(widget.preview ? 'Sample preview · Nothing you write here will be sent.'
            : 'Sent privately to the Questwell team. Please leave out passwords and private quest details. Drafts stay on this device until sent.',
            style: QuestwellTypography.body(fontSize: 13, color: _muted)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(initialValue: _draft.category, isExpanded: true,
            dropdownColor: const Color(0xFF152332),
            style: QuestwellTypography.body(color: const Color(0xFFF0E5CC)),
            decoration: InputDecoration(labelText: 'What kind of feedback?',
              labelStyle: QuestwellTypography.body(color: _muted), border: const OutlineInputBorder()),
            items: [for (final entry in QuestwellFeedbackDraft.categories.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value, maxLines: 1, overflow: TextOverflow.ellipsis))],
            onChanged: _sending ? null : (value) {
              if (value != null) _edit(_draft.copyWith(category: value, edited: true));
            }),
          const SizedBox(height: 20),
          _field(label: 'What were you trying to do?', value: _draft.goal,
            maxLength: 300, lines: 2, requiredField: true,
            onChanged: (v) => _edit(_draft.copyWith(goal: v, edited: true))),
          _field(label: 'What happened?', value: _draft.message,
            maxLength: 3000, requiredField: true,
            onChanged: (v) => _edit(_draft.copyWith(message: v, edited: true))),
          ExpansionTile(tilePadding: EdgeInsets.zero,
            title: Text('More details (optional)', style: QuestwellTypography.control(color: _gold)),
            children: [
              _field(label: 'What did you expect?', value: _draft.expected,
                onChanged: (v) => _edit(_draft.copyWith(expected: v, edited: true))),
              _field(label: 'Steps to repeat it', value: _draft.steps,
                onChanged: (v) => _edit(_draft.copyWith(steps: v, edited: true))),
              _field(label: 'Device or browser details', value: _draft.device, lines: 1, maxLength: 200,
                onChanged: (v) => _edit(_draft.copyWith(device: v, edited: true))),
              _field(label: 'Email if you want a reply', value: _draft.replyEmail,
                lines: 1, maxLength: 254, email: true,
                onChanged: (v) => _edit(_draft.copyWith(replyEmail: v, edited: true))),
            ]),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: _sending || widget.preview ? null : _pickScreenshot,
            icon: const Icon(Icons.attach_file),
            label: Text(_attachmentName == null ? 'Attach screenshot' : 'Replace screenshot'),
          ),
          if (_attachmentName != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(children: [
              const Icon(Icons.image_outlined, size: 18, color: _gold),
              const SizedBox(width: 8),
              Expanded(child: Text(_attachmentName!,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: QuestwellTypography.body(fontSize: 12, color: _muted))),
              IconButton(
                tooltip: 'Remove screenshot',
                onPressed: _sending ? null : () => setState(() {
                  _attachmentBytes = null;
                  _attachmentName = null;
                  _attachmentMime = null;
                }),
                icon: const Icon(Icons.close, size: 18, color: _muted),
              ),
            ]),
          ),
          Padding(padding: const EdgeInsets.only(top: 6),
            child: Text('Optional · PNG, JPEG, or WebP · 5 MB max · stored privately',
              style: QuestwellTypography.body(fontSize: 11, color: _muted))),
          const SizedBox(height: 12),
          Text('Included: ${_draft.screen} · ${_draft.platform} · build ${_draft.build.length > 8 ? _draft.build.substring(0, 8) : _draft.build}',
            style: QuestwellTypography.body(fontSize: 12, color: _muted)),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: 12),
            child: Semantics(liveRegion: true, child: Text(_error!,
              style: QuestwellTypography.body(color: const Color(0xFFFFC787))))),
          if (_storageNote != null) Padding(padding: const EdgeInsets.only(top: 12),
            child: Text(_storageNote!, style: QuestwellTypography.body(color: _muted))),
          const SizedBox(height: 18),
          FilledButton(onPressed: _sending ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFF316D69), foregroundColor: Colors.white,
              textStyle: QuestwellTypography.control()),
            child: Text(_sending ? 'Sending…' : 'Send feedback')),
        ])),
      )),
    ])));
}
