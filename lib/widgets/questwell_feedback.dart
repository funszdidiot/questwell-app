import 'questwell_app_style.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../backend/supabase/supabase.dart';
import '../services/questwell_feedback_draft.dart';
import '../services/questwell_feedback_service.dart';
import 'questwell_typography.dart';

abstract final class QuestwellFeedback {
  static const build = String.fromEnvironment(
    'QUESTWELL_BUILD',
    defaultValue: 'development',
  );
  static QuestwellFeedbackDraft? _previewDraft;

  static Future<void> open(
    BuildContext context, {
    required String screen,
    bool preview = false,
  }) async {
    final ownerId = preview ? null : QuestwellFeedbackService.userId;
    if (!preview && ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to send feedback.')),
      );
      return;
    }
    final store = ownerId == null ? null : QuestwellFeedbackDraftStore(ownerId);
    QuestwellFeedbackDraft? saved;
    try {
      saved = preview ? _previewDraft : await store!.load();
    } catch (_) {}
    if (!context.mounted ||
        (!preview && QuestwellFeedbackService.userId != ownerId)) return;
    final draft = saved ??
        QuestwellFeedbackDraft(
          screen: screen,
          build: build,
          platform:
              '${kIsWeb ? 'web' : 'native'}-${defaultTargetPlatform.name}',
        );
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF152332),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        return Padding(
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: SizedBox(
            height: (media.size.height - media.viewInsets.bottom) * .92,
            child: QuestwellFeedbackForm(
              initialDraft: draft,
              preview: preview,
              ownerId: ownerId,
              onSave: (value) async {
                if (preview) {
                  _previewDraft = value;
                } else {
                  await store!.save(value);
                }
              },
              onClear: () async {
                if (preview) {
                  _previewDraft = null;
                } else {
                  await store!.clear();
                }
              },
              onSubmit: (value) async {
                if (!preview)
                  await QuestwellFeedbackService.submit(value, ownerId!);
              },
              onClose: () => Navigator.of(sheetContext).pop(),
            ),
          ),
        );
      },
    );
  }
}

class QuestwellFeedbackForm extends StatefulWidget {
  const QuestwellFeedbackForm({
    super.key,
    required this.initialDraft,
    required this.onSubmit,
    required this.onSave,
    required this.onClear,
    required this.onClose,
    this.preview = false,
    this.ownerId,
  });
  final QuestwellFeedbackDraft initialDraft;
  final Future<void> Function(QuestwellFeedbackDraft) onSubmit, onSave;
  final Future<void> Function() onClear;
  final VoidCallback onClose;
  final bool preview;
  final String? ownerId;
  @override
  State<QuestwellFeedbackForm> createState() => _QuestwellFeedbackFormState();
}

class _QuestwellFeedbackFormState extends State<QuestwellFeedbackForm> {
  final _form = GlobalKey<FormState>();
  late QuestwellFeedbackDraft _draft = widget.initialDraft;
  Timer? _saveTimer;
  StreamSubscription<AuthState>? _authSubscription;
  bool _accountChanged = false;
  static const _accountMessage =
      'Your account changed. Close this note and reopen feedback.';

  bool get _sameOwner =>
      !_accountChanged &&
      (widget.ownerId == null ||
          QuestwellFeedbackService.userId == widget.ownerId);

  void _requireOwner() {
    if (!mounted || !_sameOwner) {
      throw const QuestwellFeedbackException(_accountMessage);
    }
  }

  @override
  void initState() {
    super.initState();
    for (final attachment in _draft.attachments) {
      _attachmentBytes.add(null);
      _attachmentNames.add(attachment.name);
      _attachmentMimes.add(attachment.mimeType);
    }
    if (widget.ownerId != null) {
      _authSubscription =
          SupaFlow.client.auth.onAuthStateChange.listen((state) {
        if (mounted &&
            (state.session?.user.id != widget.ownerId || !_sameOwner)) {
          _saveTimer?.cancel();
          setState(() => _accountChanged = true);
        }
      });
    }
  }

  bool _sending = false, _sent = false;
  String? _error, _storageNote;
  final List<Uint8List?> _attachmentBytes = [];
  final List<String> _attachmentNames = [], _attachmentMimes = [];
  static const _gold = Color(0xFFE4C586), _muted = Color(0xFFB9C7D7);

  void _edit(QuestwellFeedbackDraft value) {
    setState(() {
      _draft = value;
      _error = null;
    });
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_persist()),
    );
  }

  Future<void> _persist() async {
    try {
      await widget.onSave(_draft);
      if (mounted && _storageNote != null) setState(() => _storageNote = null);
    } catch (_) {
      if (mounted)
        setState(
          () => _storageNote =
              'Could not save a local copy. Keep this form open until your note is sent.',
        );
    }
  }

  Future<void> _close() async {
    if (!_sameOwner) {
      _saveTimer?.cancel();
      // Account-invalidated UI must not wait for network or local storage.
      // The callback/store remains bound to the original owner.
      if (!_sent) unawaited(_persist());
      if (mounted) widget.onClose();
      return;
    }
    if (_sending) return;
    _saveTimer?.cancel();
    if (!_sent) await _persist();
    if (mounted && (!_sameOwner || _storageNote == null || _sent)) {
      widget.onClose();
    }
  }

  Future<void> _pickScreenshot() async {
    try {
      _requireOwner();
      if (_sending || _sent) return;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
        withData: true,
        allowMultiple: true,
      );
      _requireOwner();
      // A picker opened before Send must not change the durable request while
      // its save/receipt/upload is pending, or recreate a draft after success.
      if (_sending || _sent) return;
      if (result == null || result.files.isEmpty) return;
      final remaining =
          QuestwellFeedbackService.maxAttachments - _attachmentBytes.length;
      if (remaining <= 0) {
        setState(() => _error = 'You can attach up to 5 screenshots.');
        return;
      }
      final selected = result.files.take(remaining);
      final bytesToAdd = <Uint8List>[];
      final namesToAdd = <String>[];
      final mimesToAdd = <String>[];
      for (final file in selected) {
        final bytes = file.bytes;
        if (bytes == null) {
          setState(
            () => _error =
                'Could not read one of those screenshots. Please choose it again.',
          );
          return;
        }
        if (bytes.isEmpty ||
            bytes.length > QuestwellFeedbackService.maxAttachmentBytes) {
          setState(() => _error = '${file.name} is larger than 5 MB.');
          return;
        }
        final ext = (file.extension ?? '').toLowerCase();
        final mime = ext == 'png'
            ? 'image/png'
            : ext == 'webp'
                ? 'image/webp'
                : (ext == 'jpg' || ext == 'jpeg')
                    ? 'image/jpeg'
                    : null;
        if (mime == null) {
          setState(() => _error = 'Use PNG, JPEG, or WebP screenshots.');
          return;
        }
        bytesToAdd.add(bytes);
        namesToAdd.add(file.name);
        mimesToAdd.add(mime);
      }
      setState(() {
        _attachmentBytes.addAll(bytesToAdd);
        _attachmentNames.addAll(namesToAdd);
        _attachmentMimes.addAll(mimesToAdd);
        _error = result.files.length > remaining
            ? 'Added $remaining screenshots. You can attach up to 5 per report.'
            : null;
      });
      _edit(_draft.copyWith(edited: true, attachments: [
        ..._draft.attachments,
        for (var i = 0; i < bytesToAdd.length; i++)
          QuestwellFeedbackAttachment.fromBytes(
              namesToAdd[i], mimesToAdd[i], bytesToAdd[i]),
      ]));
    } catch (_) {
      if (mounted)
        setState(
          () => _error = 'Could not open your screenshots. Please try again.',
        );
    }
  }

  Future<void> _submit() async {
    if (_sending || _sent || !_form.currentState!.validate()) return;
    _saveTimer?.cancel();
    final canCleanFreshUploads = !_draft.attempted;
    final wasAttempted = _draft.attempted;
    setState(() {
      _sending = true;
      _error = null;
      _draft = _draft.copyWith(attempted: true);
    });
    final uploadedPaths = <String>[];
    var submissionStarted = false;
    try {
      _requireOwner();
      try {
        // Durable request identity/attachment intent is required before writes.
        await widget.onSave(_draft);
      } catch (_) {
        throw const QuestwellFeedbackException(
            'Could not save this request safely. Keep the form open and try again.');
      }
      _requireOwner();
      final owner = widget.ownerId;
      var received = false;
      if (wasAttempted && !widget.preview && owner != null) {
        received = await QuestwellFeedbackService.isReceived(_draft, owner,
            attachmentPaths:
                QuestwellFeedbackService.attachmentPaths(_draft, owner));
        _requireOwner();
        if (!received && !_draft.attachmentsKnown) {
          throw const QuestwellFeedbackException(
              'This older draft has no saved screenshot details. Edit your note and reattach any screenshots before sending.');
        }
      }
      if (!received && !widget.preview && _attachmentBytes.isNotEmpty) {
        final ownerId = widget.ownerId;
        if (ownerId == null) {
          throw const QuestwellFeedbackException(
            'Sign in before attaching screenshots.',
          );
        }
        for (var i = 0; i < _attachmentBytes.length; i++) {
          final bytes = _attachmentBytes[i];
          uploadedPaths.add(
            bytes == null
                ? await QuestwellFeedbackService.restoreScreenshot(
                    ownerId: ownerId,
                    feedbackId: _draft.id,
                    attachment: _draft.attachments[i],
                    index: i)
                : await QuestwellFeedbackService.uploadScreenshot(
                    ownerId: ownerId,
                    feedbackId: _draft.id,
                    bytes: bytes,
                    mimeType: _attachmentMimes[i],
                    index: i,
                  ),
          );
          _requireOwner();
        }
        submissionStarted = true;
        await QuestwellFeedbackService.submit(
          _draft,
          ownerId,
          attachmentPaths: uploadedPaths,
        );
      } else if (!received) {
        submissionStarted = true;
        await widget.onSubmit(_draft);
      }
      _requireOwner();
      try {
        await widget.onClear();
      } catch (_) {
        if (mounted)
          setState(
            () => _storageNote =
                'Your feedback was sent, but its local draft could not be cleared.',
          );
      }
      _requireOwner();
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      // Once an insert was attempted, a lost response may hide a commit.
      // Retried draft IDs may also refer to an earlier committed report.
      // Only a fresh request's uploads before its first insert are removable.
      if (canCleanFreshUploads &&
          !submissionStarted &&
          _sameOwner &&
          uploadedPaths.isNotEmpty) {
        try {
          await QuestwellFeedbackService.removeScreenshots(uploadedPaths);
        } catch (_) {}
      }
      if (mounted)
        setState(
          () => _error = error is QuestwellFeedbackException
              ? error.message
              : 'We could not confirm delivery. Your note is still here. Check your connection and tap Send feedback to retry.',
        );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _authSubscription?.cancel();
    if (!_sent) unawaited(_persist());
    super.dispose();
  }

  Widget _field({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLength = 1000,
    int lines = 3,
    bool requiredField = false,
    bool email = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          initialValue: value,
          enabled: !_sending,
          style: QuestwellTypography.body(color: const Color(0xFFF0E5CC)),
          minLines: lines,
          maxLines: lines == 1 ? 1 : lines + 2,
          maxLength: maxLength,
          keyboardType: email
              ? TextInputType.emailAddress
              : lines == 1
                  ? TextInputType.text
                  : TextInputType.multiline,
          decoration: InputDecoration(
            labelText: label,
            alignLabelWithHint: true,
            labelStyle: QuestwellTypography.body(color: _muted),
            counterStyle: QuestwellTypography.body(fontSize: 11, color: _muted),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF65563D)),
            ),
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
          validator: (text) {
            final trimmed = text?.trim() ?? '';
            if (requiredField && trimmed.isEmpty)
              return 'Please add a few words.';
            if (email &&
                trimmed.isNotEmpty &&
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(trimmed)) {
              return 'Enter an email address, or leave this blank.';
            }
            return null;
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (!_sameOwner) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_accountMessage,
                  style:
                      QuestwellTypography.body(color: const Color(0xFFF0E5CC))),
              TextButton(
                onPressed: _close,
                child: Text('Close feedback',
                    style: QuestwellTypography.control(color: _gold)),
              ),
            ],
          ),
        ),
      );
    }
    return PopScope(
      canPop: !_sending,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _sent ? 'NOTE RECEIVED' : 'SEND FEEDBACK',
                      style: QuestwellTypography.sectionHeading(size: 11),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close feedback',
                    onPressed: _sending ? null : _close,
                    icon: const Icon(Icons.close, color: _gold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: _sent
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            color: _gold,
                            size: 42,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.preview
                                ? 'Preview complete. No feedback was sent.'
                                : 'Thanks, adventurer. Your note is in our journal.',
                            style: QuestwellTypography.body(
                              fontSize: 18,
                              color: const Color(0xFFF0E5CC),
                            ),
                          ),
                          if (_storageNote != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                _storageNote!,
                                style: QuestwellTypography.body(color: _muted),
                              ),
                            ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _close,
                            child: const Text('Back to Questwell'),
                          ),
                        ],
                      )
                    : Form(
                        key: _form,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Help shape Questwell. A quick observation is enough.',
                              style: QuestwellTypography.body(
                                fontSize: 16,
                                color: const Color(0xFFF0E5CC),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.preview
                                  ? 'Sample preview · Nothing you write here will be sent.'
                                  : 'Sent privately to the Questwell team. Please leave out passwords and private quest details. Drafts stay on this device until sent.',
                              style: QuestwellTypography.body(
                                fontSize: 13,
                                color: _muted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _draft.category,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF152332),
                              style: QuestwellTypography.body(
                                color: const Color(0xFFF0E5CC),
                              ),
                              decoration: InputDecoration(
                                labelText: 'What kind of feedback?',
                                labelStyle: QuestwellTypography.body(
                                  color: _muted,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                for (final entry in QuestwellFeedbackDraft
                                    .categories.entries)
                                  DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: _sending
                                  ? null
                                  : (value) {
                                      if (value != null)
                                        _edit(
                                          _draft.copyWith(
                                            category: value,
                                            edited: true,
                                          ),
                                        );
                                    },
                            ),
                            const SizedBox(height: 20),
                            _field(
                              label: 'What were you trying to do?',
                              value: _draft.goal,
                              maxLength: 300,
                              lines: 2,
                              requiredField: true,
                              onChanged: (v) =>
                                  _edit(_draft.copyWith(goal: v, edited: true)),
                            ),
                            _field(
                              label: 'What happened?',
                              value: _draft.message,
                              maxLength: 3000,
                              requiredField: true,
                              onChanged: (v) => _edit(
                                _draft.copyWith(message: v, edited: true),
                              ),
                            ),
                            ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: Text(
                                'More details (optional)',
                                style: QuestwellTypography.control(
                                  color: _gold,
                                ),
                              ),
                              children: [
                                _field(
                                  label: 'What did you expect?',
                                  value: _draft.expected,
                                  onChanged: (v) => _edit(
                                    _draft.copyWith(expected: v, edited: true),
                                  ),
                                ),
                                _field(
                                  label: 'Steps to repeat it',
                                  value: _draft.steps,
                                  onChanged: (v) => _edit(
                                    _draft.copyWith(steps: v, edited: true),
                                  ),
                                ),
                                _field(
                                  label: 'Device or browser details',
                                  value: _draft.device,
                                  lines: 1,
                                  maxLength: 200,
                                  onChanged: (v) => _edit(
                                    _draft.copyWith(device: v, edited: true),
                                  ),
                                ),
                                _field(
                                  label: 'Email if you want a reply',
                                  value: _draft.replyEmail,
                                  lines: 1,
                                  maxLength: 254,
                                  email: true,
                                  onChanged: (v) => _edit(
                                    _draft.copyWith(
                                      replyEmail: v,
                                      edited: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            OutlinedButton.icon(
                              onPressed: _sending ||
                                      widget.preview ||
                                      _attachmentBytes.length >=
                                          QuestwellFeedbackService
                                              .maxAttachments
                                  ? null
                                  : _pickScreenshot,
                              icon: const Icon(Icons.attach_file),
                              label: Text(
                                _attachmentBytes.isEmpty
                                    ? 'Attach screenshots'
                                    : 'Add screenshots (${_attachmentBytes.length}/5)',
                              ),
                            ),
                            for (var i = 0; i < _attachmentNames.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.image_outlined,
                                      size: 18,
                                      color: _gold,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _attachmentNames[i],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: QuestwellTypography.body(
                                          fontSize: 12,
                                          color: _muted,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove screenshot',
                                      onPressed: _sending
                                          ? null
                                          : () {
                                              _attachmentBytes.removeAt(i);
                                              _attachmentNames.removeAt(i);
                                              _attachmentMimes.removeAt(i);
                                              final attachments = [
                                                ..._draft.attachments
                                              ]..removeAt(i);
                                              _edit(_draft.copyWith(
                                                  edited: true,
                                                  attachments: attachments));
                                            },
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: _muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _attachmentBytes.any((bytes) => bytes == null)
                                    ? 'Saved screenshots will be verified before sending. If recovery fails, remove them and choose them again.'
                                    : 'Optional · up to 5 screenshots · PNG, JPEG, or WebP · 5 MB each · stored privately',
                                style: QuestwellTypography.body(
                                  fontSize: 11,
                                  color: _muted,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Included: ${_draft.screen} · ${_draft.platform} · build ${_draft.build.length > 8 ? _draft.build.substring(0, 8) : _draft.build}',
                              style: QuestwellTypography.body(
                                fontSize: 12,
                                color: _muted,
                              ),
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    _error!,
                                    style: QuestwellTypography.body(
                                      color: const Color(0xFFFFC787),
                                    ),
                                  ),
                                ),
                              ),
                            if (_storageNote != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _storageNote!,
                                  style: QuestwellTypography.body(
                                    color: _muted,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                            FilledButton(
                              onPressed: _sending ? null : _submit,
                              style: QuestwellAppStyle.primaryButton(),
                              child: Text(
                                _sending ? 'Sending…' : 'Send feedback',
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
