import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared 32-pixel artwork with the shading and limited palettes of 16-bit RPGs.
/// Integer coordinates and no anti-aliasing keep Inventory and Market consistent.
class QuestwellItemIcon extends StatelessWidget {
  const QuestwellItemIcon({super.key, required this.slug, this.size = 64, this.locked = false});
  final String slug;
  final double size;
  final bool locked;
  @override
  Widget build(BuildContext context) => Semantics(label: '${slug.replaceAll('-', ' ')} icon',
    image: true, child: SizedBox.square(dimension: size,
      child: CustomPaint(painter: QuestwellItemIconPainter(slug, locked: locked))));
}

class QuestwellItemIconPainter extends CustomPainter {
  const QuestwellItemIconPainter(this.slug, {this.locked = false});
  final String slug;
  final bool locked;
  static const ink = Color(0xFF172329), gold = Color(0xFFE6BD69), goldShade = Color(0xFF916039),
    cream = Color(0xFFFFEBC0), wood = Color(0xFF865435), woodLight = Color(0xFFBE8755),
    woodDark = Color(0xFF4B332B), green = Color(0xFF4C956E), greenDark = Color(0xFF28534A),
    mint = Color(0xFF95D3A0), red = Color(0xFFAA4D59), redDark = Color(0xFF612F40),
    purple = Color(0xFF8170B3), purpleDark = Color(0xFF493D72), blue = Color(0xFF75B8D1);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    final scale = math.min(size.width, size.height) / 32;
    canvas.translate((size.width - 32*scale)/2, (size.height - 32*scale)/2);
    canvas.scale(scale);
    final paint = Paint()..isAntiAlias = false;
    void r(num x, num y, num w, num h, Color c) { paint.color=c; canvas.drawRect(Rect.fromLTWH(x.toDouble(),y.toDouble(),w.toDouble(),h.toDouble()),paint); }
    void gem(int x, int y, Color c) {r(x+1,y,2,1,c);r(x,y+1,4,3,c);r(x+1,y+4,2,1,c);r(x+1,y+1,1,1,cream);}
    void star(int x, int y, Color c) {r(x,y-2,1,5,c);r(x-2,y,5,1,c);}
    void panel(int x,int y,int w,int h,Color c,Color light,Color dark) {
      r(x,y,w,h,ink);r(x+1,y+1,w-2,h-2,c);r(x+1,y+1,w-2,1,light);r(x+1,y+1,1,h-2,light);r(x+w-2,y+2,1,h-3,dark);r(x+2,y+h-2,w-3,1,dark);
    }
    if (slug == 'pathfinder-boots') {
      // Paired 32px leather boots, olive folded cuffs and brass ankle buckles.
      const leather = Color(0xFF704832), light = Color(0xFFA16B46),
        shadow = Color(0xFF3C2B27), olive = Color(0xFF66633D),
        oliveLight = Color(0xFF96905B), brass = Color(0xFFC4A366);
      for (final x in [6, 19]) {
        r(x, 5, 8, 18, ink); r(x+1, 7, 6, 15, leather);
        r(x+1, 10, 2, 9, light); r(x+6, 11, 1, 11, shadow);
        r(x-1, 4, 10, 6, ink); r(x, 5, 8, 4, olive);
        r(x, 5, 7, 1, oliveLight); r(x+1, 9, 6, 1, brass);
        r(x, 19, 8, 3, shadow); r(x+1, 19, 6, 1, light);
        r(x+3, 18, 3, 4, brass); r(x+4, 19, 1, 2, shadow);
      }
      r(3, 22, 11, 5, ink); r(1, 25, 13, 4, ink);
      r(4, 22, 9, 4, leather); r(2, 26, 11, 2, leather);
      r(3, 25, 7, 1, light); r(2, 28, 12, 2, shadow);
      r(19, 22, 10, 5, ink); r(19, 25, 12, 4, ink);
      r(20, 22, 8, 4, leather); r(20, 26, 10, 2, leather);
      r(23, 25, 6, 1, light); r(19, 28, 12, 2, shadow);
    } else if (slug == 'emerald-dragon') {
      // Stepped emerald wings, golden horns, sage belly, and curled tail.
      r(3,12,3,11,ink);r(6,10,3,15,ink);r(9,14,3,10,ink);
      r(4,14,2,7,greenDark);r(6,12,2,11,green);r(8,17,2,6,mint);
      r(22,10,3,15,ink);r(25,12,3,12,ink);r(28,15,2,8,ink);
      r(23,12,2,11,green);r(25,14,2,8,greenDark);r(27,17,1,4,mint);
      r(11,4,3,5,ink);r(20,3,3,7,ink);
      r(12,4,1,4,gold);r(20,4,2,4,goldShade);r(21,3,1,3,gold);
      r(11,8,12,8,ink);r(8,11,5,5,ink);r(10,10,12,5,green);
      r(12,8,8,4,green);r(9,12,5,3,mint);r(10,14,3,1,greenDark);
      r(15,10,4,3,gold);r(16,10,2,3,ink);r(16,10,1,1,cream);
      r(21,12,2,3,greenDark);r(13,15,9,12,ink);r(14,15,7,11,green);
      r(14,17,4,8,mint);r(14,19,4,1,greenDark);r(14,22,4,1,greenDark);
      r(20,17,2,7,greenDark);r(21,18,2,2,goldShade);
      r(9,26,15,3,ink);r(10,26,5,2,green);r(18,26,5,2,green);
      r(10,28,2,1,gold);r(19,28,2,1,gold);
      r(23,24,5,2,greenDark);r(26,22,3,4,green);r(25,21,2,2,gold);
    } else if (slug.contains('owl')) {
      final archive=slug=='archive-owl';
      final main=archive?purple:woodLight;
      r(8,6,3,7,woodDark);r(21,6,3,7,woodDark);r(9,8,14,3,ink);
      r(7,11,18,12,ink);r(9,23,14,3,ink);r(9,10,14,13,main);
      r(8,15,3,7,archive?purpleDark:wood);r(21,15,3,7,archive?purpleDark:wood);
      r(11,20,10,4,cream);r(12,21,2,1,woodLight);r(17,22,2,1,woodLight);
      for(final x in [10,18]) {r(x,12,5,6,cream);r(x+2,14,2,3,ink);r(x+2,14,1,1,blue);}
      r(15,17,2,2,gold);r(11,26,3,2,goldShade);r(18,26,3,2,goldShade);
      if(archive) {r(6,27,20,3,purpleDark);r(8,28,16,1,cream);r(9,12,7,1,gold);r(17,12,7,1,gold);r(15,14,2,1,gold);}
    } else if(slug=='mushroom-familiar') {
      r(13,14,7,13,ink);r(14,15,5,11,cream);r(18,18,1,8,gold);
      r(5,12,23,6,ink);r(7,9,19,4,ink);r(10,6,13,4,ink);r(13,4,7,3,ink);
      r(7,12,19,4,redDark);r(8,10,17,4,red);r(11,7,11,5,red);r(14,5,5,3,red);
      r(11,9,3,2,cream);r(20,11,3,3,cream);r(15,6,2,2,cream);r(8,14,4,1,cream);
      r(14,21,1,2,ink);r(18,21,1,2,ink);r(16,24,1,1,red);r(12,27,3,1,greenDark);r(19,27,3,1,greenDark);
    } else if(slug=='glass-slime') {
      r(11,9,10,2,ink);r(8,11,16,3,ink);r(6,14,20,5,ink);r(4,19,24,8,ink);
      r(8,15,16,10,green);r(6,20,20,5,blue);r(9,12,14,10,blue);r(12,10,8,2,blue);
      r(9,14,3,6,cream);r(12,12,4,2,cream);r(23,20,2,4,greenDark);
      r(11,20,2,3,ink);r(20,20,2,3,ink);r(15,24,3,1,greenDark);r(8,26,16,1,mint);
      star(24,8,cream);
    } else if(slug=='signal-fox') {
      r(7,4,3,10,ink);r(22,4,3,10,ink);r(8,6,3,8,woodLight);r(21,6,3,8,woodLight);
      r(10,9,12,3,ink);r(6,12,20,9,ink);r(9,21,14,3,ink);r(12,24,8,3,ink);
      r(8,12,16,8,woodLight);r(10,11,12,10,woodLight);r(11,20,10,4,cream);
      r(7,16,5,5,cream);r(20,16,5,5,cream);r(10,15,2,3,ink);r(20,15,2,3,ink);
      r(14,20,4,2,ink);r(14,26,5,2,green);gem(15,25,gold);star(27,10,gold);
    } else if(slug=='moss-moth') {
      for(final x in [4,19]) {r(x,6,9,3,ink);r(x-1,9,11,11,ink);r(x+1,20,7,6,ink);r(x,9,9,10,green);r(x+2,20,5,4,greenDark);r(x+1,9,6,3,mint);gem(x+3,14,gold);}
      r(14,9,4,17,woodDark);r(15,10,2,13,gold);r(13,5,1,5,gold);r(18,5,1,5,gold);r(12,4,1,2,mint);r(19,4,1,2,mint);
    } else if(slug.contains('glasses')) {
      for(final x in [3,18]) {r(x+2,10,7,1,goldShade);r(x,12,11,7,goldShade);r(x+2,20,7,1,goldShade);r(x+1,12,9,7,gold);r(x+2,13,7,5,greenDark);r(x+3,13,2,2,blue);r(x+5,14,1,1,cream);}
      r(13,14,6,2,gold);r(1,12,3,2,gold);r(28,12,3,2,gold);
    } else if(slug.contains('hat')) {
      r(17,3,5,2,ink);r(14,5,7,4,ink);r(12,9,8,5,ink);r(10,14,12,7,ink);
      r(4,22,24,4,ink);r(7,26,18,2,ink);r(6,22,20,3,purple);r(11,15,10,7,purpleDark);
      r(13,10,6,7,purple);r(15,6,5,5,purple);r(18,4,3,2,purple);r(12,16,2,4,purple);
      r(10,20,12,2,gold);gem(16,19,blue);r(7,23,8,1,cream);
    } else if(slug.contains('scarf')) {
      panel(5,5,22,7,green,mint,greenDark);panel(8,11,9,17,green,mint,greenDark);panel(20,11,6,13,greenDark,green,ink);
      r(9,24,7,2,gold);r(21,20,4,2,gold);for(final x in [9,12,15]) r(x,28,1,2,green);r(21,24,1,2,greenDark);r(24,24,1,2,greenDark);
    } else if(slug.contains('suit')||slug.contains('cloak')||slug.contains('mantle')) {
      final suit=slug.contains('suit'), guardian=slug.contains('mantle');
      final c=suit?const Color(0xFF626D7F):guardian?red:green;
      final dark=suit?const Color(0xFF35404D):guardian?redDark:greenDark;
      r(10,4,12,3,ink);r(7,7,18,5,ink);r(5,12,22,15,ink);r(8,27,16,2,ink);
      r(8,9,16,17,c);r(6,13,3,13,dark);r(23,13,3,13,dark);r(10,6,12,4,c);
      r(20,10,3,16,dark);r(9,10,2,14,suit?blue:guardian?const Color(0xFFCC7881):mint);
      r(15,11,2,17,ink);r(12,6,8,3,suit?cream:gold);r(14,9,4,3,suit?cream:goldShade);
      if(suit){r(15,7,2,2,red);r(15,10,2,7,red);r(11,7,1,5,blue);r(12,12,2,2,blue);r(20,7,1,5,blue);}else{gem(14,8,gold);r(8,26,7,1,gold);r(17,26,7,1,gold);}
    } else if(slug.contains('boot')) {
      for(final x in [4,18]) {panel(x+3,5,7,17,wood,woodLight,woodDark);r(x,21,10,5,ink);r(x+1,21,8,3,wood);r(x,26,11,2,woodDark);r(x+4,10,5,2,gold);r(x+4,15,3,1,cream);r(x+4,18,3,1,cream);r(x+1,22,3,1,woodLight);}
    } else if(slug.contains('satchel')) {
      final way=slug=='wayfarer-satchel';
      r(10,4,12,2,woodDark);r(8,6,3,8,woodDark);r(21,6,3,8,woodDark);r(10,6,2,5,goldShade);
      panel(4,13,24,15,way?const Color(0xFF414B2C):wood,way?const Color(0xFF76804A):woodLight,woodDark);panel(5,11,22,9,way?const Color(0xFF626D3D):woodLight,way?const Color(0xFFA4A66B):gold,woodDark);
      panel(13,17,6,6,gold,cream,goldShade);r(15,18,2,3,woodDark);r(7,23,3,1,goldShade);r(22,23,3,1,goldShade);
      if(way){r(5,26,22,2,wood);r(14,13,4,4,wood);r(14,23,4,3,wood);r(5,9,22,3,cream);r(6,11,20,1,goldShade);r(8,8,2,5,wood);r(22,8,2,5,wood);r(25,9,2,3,gold);r(26,10,1,1,woodDark);}
    } else if(slug.contains('grimoire')||slug.contains('seal')) {
      final book = slug == 'annotated-grimoire';
      panel(7,4,20,24,book?const Color(0xFF49344F):purple,book?const Color(0xFF79586E):purple,purpleDark);r(8,5,3,22,goldShade);r(11,6,13,1,cream);r(12,25,12,1,cream);
      r(25,8,3,4,red);r(25,16,4,3,blue);gem(16,12,gold);r(14,20,8,1,cream);r(15,22,5,1,gold);r(5,6,2,21,purpleDark);
      if(book){r(23,5,3,2,gold);r(23,24,3,2,gold);r(12,27,3,4,redDark);r(13,27,1,3,red);star(17,14,gold);r(17,14,1,1,cream);}
    } else if(slug.contains('tonic')||slug.contains('phial')) {
      panel(12,3,8,5,wood,woodLight,woodDark);r(13,8,6,5,blue);r(9,13,14,3,ink);r(6,16,20,11,ink);r(9,27,14,2,ink);
      r(8,17,16,9,green);r(10,14,12,4,blue);r(10,24,12,3,greenDark);r(9,18,3,5,mint);r(10,16,2,3,cream);r(15,20,3,2,mint);r(20,22,2,1,cream);star(25,9,gold);
    } else if(slug.contains('lantern')) {
      final ward=slug=='warding-lantern';
      r(12,2,8,2,goldShade);r(10,4,2,5,gold);r(20,4,2,5,goldShade);r(8,10,16,2,ink);r(6,12,20,2,goldShade);
      panel(8,14,16,13,gold,cream,goldShade);r(11,15,10,10,ward?greenDark:const Color(0xFFCB732F));r(12,16,8,8,ward?green:gold);
      r(15,17,2,4,cream);r(14,21,4,3,cream);r(10,15,1,10,woodDark);r(21,15,1,10,woodDark);r(6,27,20,2,goldShade);r(8,29,16,1,ink);if(ward)gem(14,7,mint);
    } else if(slug.contains('brooch')) {
      for(final y in [5,7,9,11,13,15,17,19,21]) {final w=y<13?y-1:25-y;r(16-w~/2,y,w,2,goldShade);}
      r(11,8,10,13,gold);r(13,6,6,17,gold);r(12,10,8,9,blue);r(14,8,4,13,blue);r(13,10,2,5,cream);r(16,17,3,2,purple);r(14,23,4,3,goldShade);star(6,10,cream);
    } else if(slug=='victory-sparkle'||slug=='guardian-crest') {
      star(15,14,gold);r(14,9,3,11,gold);r(10,13,11,3,gold);r(14,13,3,3,cream);star(7,23,mint);star(25,7,cream);star(24,25,goldShade);r(6,8,2,2,blue);
    } else if(slug.contains('window')) {
      panel(5,3,22,26,wood,woodLight,woodDark);r(8,6,16,19,const Color(0xFF29475A));r(9,7,6,8,const Color(0xFF35576A));
      for(final pos in [const Offset(10,9),const Offset(20,8),const Offset(12,19),const Offset(21,20)]){r(pos.dx,pos.dy,1,3,blue);r(pos.dx-1,pos.dy+3,1,2,blue);}
      r(15,6,2,19,woodLight);r(8,15,16,2,woodLight);r(3,28,26,2,woodDark);r(3,27,26,1,goldShade);
    } else if(slug.contains('bookshelf')) {
      panel(4,3,24,26,wood,woodLight,woodDark);r(7,6,18,20,woodDark);
      for(final y in [6,14,22]) {for(var j=0;j<4;j++){final c=[green,red,purple,blue][j];r(8+j*4,y,3,5,c);r(8+j*4,y+1,2,1,gold);}r(6,y+6,20,2,woodLight);}
      r(6,29,3,2,woodDark);r(23,29,3,2,woodDark);
    } else if(slug.contains('chair')) {
      panel(8,3,16,18,red,const Color(0xFFD28385),redDark);panel(6,18,20,9,red,red,redDark);panel(4,16,5,9,red,cream,redDark);panel(23,16,5,9,red,cream,redDark);
      r(8,27,3,4,wood);r(21,27,3,4,wood);for(final x in [12,19])for(final y in [9,14])r(x,y,1,1,gold);
    } else if(slug.contains('table')) {
      panel(3,17,26,4,wood,woodLight,woodDark);r(6,21,3,9,wood);r(23,21,3,9,wood);r(7,22,1,5,goldShade);r(24,22,1,5,goldShade);
      panel(6,12,12,4,green,green,greenDark);r(7,14,10,1,cream);panel(8,8,12,4,red,red,redDark);r(9,10,10,1,cream);r(24,6,2,11,cream);r(22,16,6,1,gold);r(24,3,2,3,gold);
    } else if(slug=='hearth-fern') {
      panel(10,22,12,7,woodLight,gold,wood);r(9,21,14,2,gold);r(15,5,2,17,greenDark);
      for(final y in [7,11,15,19]) {r(10,y-2,5,2,green);r(7,y-4,4,2,mint);r(17,y-1,5,2,green);r(21,y-3,4,2,mint);}r(15,3,2,4,mint);
    } else if(slug=='fern-study'||slug=='celestial-study'||slug=='moonlit-woodland') {
      final landscape=slug=='moonlit-woodland';
      panel(landscape?2:7,4,landscape?28:18,24,wood,woodLight,woodDark);r(landscape?4:9,6,landscape?24:14,20,gold);
      r(landscape?5:10,7,landscape?22:12,18,slug=='fern-study'?cream:const Color(0xFF293B61));
      if(slug=='fern-study'){r(15,9,1,14,greenDark);for(final y in [11,15,19]){r(12,y-1,3,2,green);r(16,y,3,2,green);}}else{r(18,9,5,5,cream);r(20,9,4,4,const Color(0xFF293B61));star(12,11,gold);if(landscape){r(7,17,5,7,greenDark);r(8,14,3,5,green);r(16,20,9,4,green);}else{star(13,19,gold);r(19,22,1,1,cream);}}
    } else if(slug=='first-journey-trophy'||slug=='starlit-orrery'||slug.contains('compass')||slug.contains('map')) {
      final orrery=slug=='starlit-orrery';
      r(8,27,16,3,wood);r(10,25,12,2,gold);r(15,20,2,6,goldShade);
      for(var a=0;a<24;a++){final angle=a*math.pi/12; r((16+10*math.cos(angle)).round(),(14+10*math.sin(angle)).round(),2,2,goldShade);}
      if(orrery){r(7,13,20,2,gold);r(15,5,2,19,gold);gem(14,12,blue);gem(6,8,mint);gem(23,16,purple);}else{r(15,7,2,14,gold);r(9,13,14,2,gold);r(14,10,4,7,cream);r(15,8,2,7,red);}
    } else {
      gem(14,12,gold);star(8,8,mint);star(23,22,blue);
    }
    if(locked) r(0,0,32,32,const Color(0x55314349));
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellItemIconPainter oldDelegate) => oldDelegate.slug!=slug||oldDelegate.locked!=locked;
}
