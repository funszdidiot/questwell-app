import '/flutter_flow/flutter_flow_util.dart';
import 'add_task_page_widget.dart' show AddTaskPageWidget;
import 'package:flutter/material.dart';

class AddTaskPageModel extends FlutterFlowModel<AddTaskPageWidget> {
  ///  Local state fields for this page.

  int selectedFriction = 0;

  int selectedXp = 0;

  int selectedCoins = 0;

  ///  State fields for stateful widgets in this page.

  // State field(s) for taskTitleField widget.
  FocusNode? taskTitleFieldFocusNode;
  TextEditingController? taskTitleFieldTextController;
  String? Function(BuildContext, String?)?
      taskTitleFieldTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    taskTitleFieldFocusNode?.dispose();
    taskTitleFieldTextController?.dispose();
  }
}
