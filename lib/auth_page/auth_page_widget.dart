import '/auth/supabase_auth/auth_util.dart';
import '/auth/questwell_auth_callback.dart';
import '/backend/supabase/questwell_network.dart';
import '/services/questwell_auth_service.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/widgets/questwell_pixel_art.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
export 'auth_page_model.dart';

class AuthPageWidget extends StatefulWidget {
  const AuthPageWidget({super.key, this.authService});
  final QuestwellAuthService? authService;
  static String routeName = 'AuthPage';
  static String routePath = '/authPage';
  @override
  State<AuthPageWidget> createState() => _AuthPageWidgetState();
}

class _AuthPageWidgetState extends State<AuthPageWidget> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _visible = false, _busy = false, _creating = false, _reset = false;
  String? _message;
  late final _auth = widget.authService ?? QuestwellAuthService();
  bool get _recovering => QuestwellAuthCallback.recovering || GoRouter.of(context).routeInformationProvider.value.uri
      .queryParameters['recovery'] == 'true';
  bool get _resetting => _reset || GoRouter.of(context).routeInformationProvider.value.uri
      .queryParameters['reset'] == 'true';
  bool get _invalidRecovery => _recovering &&
      (QuestwellAuthCallback.linkFailed || !_auth.hasSession);

  @override
  void initState() {
    super.initState();
    if (QuestwellAuthCallback.linkFailed) {
      _message = 'This email link is invalid or has expired. Request a new link.';
    }
  }

  void _requestNewLink() {
    QuestwellAuthCallback.clear();
    GoRouter.of(context).clearRedirectLocation();
    context.goNamed(AuthPageWidget.routeName, queryParameters: {'reset': 'true'});
    setState(() { _reset = true; _creating = false; _message = null;
      _password.clear(); _form.currentState?.reset(); });
  }

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    final recovering = _recovering;
    setState(() { _busy = true; _message = null; });
    try {
      if (recovering) {
        if (_invalidRecovery) {
          setState(() => _message = 'This reset link has expired. Request a new link.');
          return;
        }
        await _auth.savePassword(_password.text);
        if (!mounted) return;
        _password.clear();
        QuestwellAuthCallback.clear();
        GoRouter.of(context).clearRedirectLocation();
        context.goNamedAuth(HomePageWidget.routeName, mounted);
      } else if (_resetting) {
        await _auth.sendReset(_email.text.trim());
        if (mounted) setState(() => _message = 'If an account matches that email, you’ll receive a password reset link.');
      } else {
        GoRouter.of(context).prepareAuthEvent();
        final signedIn = _creating
          ? await _auth.signUp(_email.text.trim(), _password.text)
          : await _auth.signIn(_email.text.trim(), _password.text);
        if (!mounted) return;
        if (!signedIn) {
          _password.clear();
          setState(() => _message = _creating
            ? 'Check your email to confirm your account, then return to sign in.'
            : 'Sign-in did not finish. Check your details and try again.');
          return;
        }
        // The database signup trigger creates the profile and starter gear.
        QuestwellAuthCallback.clear();
        GoRouter.of(context).clearRedirectLocation();
        if (mounted) context.goNamedAuth(HomePageWidget.routeName, mounted);
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } on QuestwellNetworkException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (_) {
      if (mounted) setState(() => _message = 'We couldn’t finish that request. Please try again.');
    } finally {
      AppStateNotifier.instance.updateNotifyOnAuthChange(true);
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label, filled: true, fillColor: const Color(0xFFFFF6DF),
    labelStyle: const TextStyle(color: Color(0xFF655039)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
    border: const OutlineInputBorder(borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: Color(0xFF967344))),
    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: Color(0xFF967344))),
    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: Color(0xFF326F69), width: 2)),
    errorMaxLines: 3,
  );

  @override
  Widget build(BuildContext context) {
    final recovering = _recovering;
    final title = recovering ? 'A fresh start' : _resetting ? 'Find your way back'
      : _creating ? 'Your adventure starts here' : 'Welcome back, adventurer';
    return Scaffold(backgroundColor: const Color(0xFF101925), body: Stack(children: [
      Positioned.fill(child: Image.asset('assets/images/questwell/hearth/hearth_environment_v2.webp',
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF1D2834)))),
      const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xC9101925), Color(0xA6271D19), Color(0xE8101925)])))),
      SafeArea(child: LayoutBuilder(builder: (context, bounds) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: ConstrainedBox(constraints: BoxConstraints(minHeight: (bounds.maxHeight - 56).clamp(0.0, double.infinity).toDouble()),
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const QuestwellBrandWordmark(),
              const SizedBox(height: 26),
              QuestwellParchmentPanel(padding: const EdgeInsets.all(24), child: AutofillGroup(
                child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(title, style: GoogleFonts.roboto(fontSize: 24, height: 1.2,
                    fontWeight: FontWeight.w800, color: const Color(0xFF34291F))),
                  const SizedBox(height: 10),
                  Text(recovering ? 'Choose a new password for your Questwell account.'
                    : _resetting ? 'Enter your email and we’ll send a recovery link.'
                    : _creating ? 'Turn small wins into your next adventure.' : 'Your next small win is waiting.',
                    style: GoogleFonts.roboto(fontSize: 15, height: 1.4, color: const Color(0xFF66543D))),
                  const SizedBox(height: 24),
                  if (!recovering) ...[
                    TextFormField(controller: _email, enabled: !_busy,
                      keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email],
                      autocorrect: false, textInputAction: _resetting ? TextInputAction.done : TextInputAction.next,
                      style: const TextStyle(color: Color(0xFF34291F), fontSize: 16),
                      decoration: _decoration('Email'),
                      validator: (v) => (v != null && RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim()))
                        ? null : 'Enter a valid email address.',
                      onFieldSubmitted: (_) { if (_resetting) _submit(); }),
                    const SizedBox(height: 18),
                  ],
                  if ((!_resetting || recovering) && !_invalidRecovery) ...[
                    TextFormField(controller: _password, enabled: !_busy, obscureText: !_visible,
                      autofillHints: [_creating || recovering ? AutofillHints.newPassword : AutofillHints.password],
                      autocorrect: false, enableSuggestions: false, textInputAction: TextInputAction.done,
                      style: const TextStyle(color: Color(0xFF34291F), fontSize: 16),
                      decoration: _decoration(recovering ? 'New password' : 'Password').copyWith(
                        suffixIcon: TextButton(onPressed: _busy ? null : () => setState(() => _visible = !_visible),
                          child: Text(_visible ? 'Hide' : 'Show', style: const TextStyle(color: Color(0xFF326F69))))),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your password.'
                        : (_creating || recovering) && v.length < 8 ? 'Use at least 8 characters.' : null,
                      onFieldSubmitted: (_) => _submit()),
                    const SizedBox(height: 12),
                  ],
                  if (!_creating && !_resetting && !recovering)
                    Align(alignment: Alignment.centerRight, child: TextButton(
                      onPressed: _busy ? null : () => setState(() { _reset = true; _message = null; }),
                      child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF375C57))))),
                  if (_message != null) Padding(padding: const EdgeInsets.only(bottom: 16),
                    child: Semantics(liveRegion: true, child: Text(_message!,
                      style: const TextStyle(color: Color(0xFF593B28), height: 1.4)))),
                  if (_invalidRecovery && _message == null)
                    const Padding(padding: EdgeInsets.only(bottom: 16),
                      child: Text('This reset link has expired. Request a new link.',
                        style: TextStyle(color: Color(0xFF593B28), height: 1.4))),
                  const SizedBox(height: 6),
                  FilledButton(onPressed: _busy ? null : _invalidRecovery ? _requestNewLink : _submit,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF326F69),
                      foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52),
                      padding: const EdgeInsets.all(16), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    child: Text(_busy ? 'Please wait…' : _invalidRecovery ? 'Request a new reset link' : recovering ? 'Save new password'
                      : _resetting ? 'Send reset link' : _creating ? 'Create account' : 'Enter the Hearth',
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _busy ? null : () {
                    if (recovering) {
                      QuestwellAuthCallback.clear();
                      context.goNamed(AuthPageWidget.routeName);
                      setState(() { _message = null; _password.clear(); });
                      return;
                    }
                    if (_resetting) {
                      context.goNamed(AuthPageWidget.routeName);
                      setState(() { _reset = false; _message = null; _password.clear(); });
                      return;
                    }
                    setState(() { _creating = !_creating;
                      _message = null; _password.clear(); _form.currentState?.reset(); });
                  }, child: Text(_resetting || _creating || recovering ? 'Back to sign in' : 'New here? Create an account',
                    textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF375C57)))),
                ])),
              )),
              const SizedBox(height: 20),
              const Text('A little progress. A warmer tomorrow.', textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFE7D5B3), fontSize: 13)),
            ]),
          )),
        ),
      ))),
    ]));
  }
}
