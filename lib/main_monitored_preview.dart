import 'main.dart' as application;
import 'main_preview.dart' as preview;

// Only the development deployment targets this entry point. This controlled
// diagnostic never initializes Supabase or operates on an account.
void main() {
  if (Uri.base.queryParameters['review'] == 'monitoring-check') {
    application.runQuestwell(monitoringCheck: true);
  } else {
    preview.main();
  }
}
