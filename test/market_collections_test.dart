import 'package:flutter_test/flutter_test.dart';
import 'package:project_momentum/services/questwell_cosmetic_models.dart';

QuestwellCosmetic item(String slug,{String? collection})=>QuestwellCosmetic(
 id:slug,slug:slug,name:slug,category:'familiar',rarity:'rare',description:'',
 price:1,premium:false,assetKey:null,requiredArchetype:null,unlockMethod:'shop',
 owned:false,equipped:false,collectionKey:collection);

void main(){
 test('collection metadata distinguishes collection items',(){
   final collectionItems=[item('glass-slime'),item('pumpkin-sprite',collection:'midnight-harvest')]
     .where((i)=>i.collectionKey!=null).toList();
   expect(collectionItems.map((i)=>i.slug),['pumpkin-sprite']);
 });
}
