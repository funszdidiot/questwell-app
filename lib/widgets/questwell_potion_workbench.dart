import 'dart:math' as math;
import 'package:flutter/material.dart';

class QuestwellPotionWorkbench extends StatelessWidget {
  const QuestwellPotionWorkbench({super.key});
  static const slug = 'copper-potion-workbench';
  static const asset = 'assets/images/questwell/hearth/copper_potion_workbench_v1.webp';
  static Rect bounds(Size scene, String slot) {
    final avatarHeight=math.min(scene.height*.76,scene.width*.62*4/3);
    final height=math.min(avatarHeight*.62,scene.width*.45*1173/1341);
    final width=height*1341/1173;
    final left=slot=='left' ? scene.width*.16 : scene.width*.98-width;
    // Visible plinth ends at source row 1119; ignore transparent bottom padding.
    return Rect.fromLTWH(left,scene.height*.70-height*1119/1173,width,height);
  }
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Copper potion workbench placed in the Hearth', image: true,
    child: IgnorePointer(child: Image.asset(asset,fit:BoxFit.contain,
      filterQuality:FilterQuality.high,excludeFromSemantics:true)));
}
