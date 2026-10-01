import 'package:flutter/material.dart';
import '../services/questwell_cosmetic_models.dart';
import '../services/questwell_equipment_policy.dart';

QuestwellCosmetic? cloakConflict(QuestwellCosmetic next, Iterable<QuestwellCosmetic> items) {
  for (final item in items) {
    if (item.equipped && QuestwellEquipmentPolicy.conflicts(next.slug,next.category,item.slug,item.category)) return item;
  }
  return null;
}

Future<bool> confirmCloakSwap(BuildContext context, QuestwellCosmetic next, QuestwellCosmetic conflict) async =>
  await showDialog<bool>(context:context,builder:(context)=>AlertDialog(
    title:const Text('Swap your equipment?'),
    content:Text('Closed cloaks cover your hands. Remove ${conflict.name} and equip ${next.name}? Both items stay in your inventory.'),
    actions:[
      TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Keep current')),
      FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Swap equipment')),
    ],
  )) ?? false;
