import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_item_icon.dart';

/// New catalog layers use the same authored 240×320 registration as the avatar.
/// Garments are continuous canvas shapes; miniature companions retain pixel art.
class QuestwellCatalogEquipment extends StatelessWidget {
  const QuestwellCatalogEquipment({super.key, required this.equipment, required this.body, this.rear = false});
  final Map<String,String> equipment;
  final String body;
  final bool rear;
  @override
  Widget build(BuildContext context) => IgnorePointer(child: CustomPaint(
    key: ValueKey(rear?'catalog-rear-equipment':'catalog-front-equipment'),
    painter: _EquipmentPainter(equipment,body,rear)));
}
class _EquipmentPainter extends CustomPainter {
  const _EquipmentPainter(this.items,this.body,this.rear);
  final Map<String,String> items;
  final String body;
  final bool rear;
  @override
  void paint(Canvas c, Size size) {
    final s=math.min(size.width/240,size.height/320);
    c.save();c.translate((size.width-240*s)/2,size.height-320*s);c.scale(s);
    final female=body=='female';
    final y=female?-5.0:body=='male'?1.0:0.0;
    final p=Paint()..isAntiAlias=true;
    void fill(Path path,Color color){p.shader=null;p.style=PaintingStyle.fill;p.color=color;c.drawPath(path,p);}
    void line(Path path,Color color,double width){p.shader=null;p.style=PaintingStyle.stroke;p.strokeWidth=width;p.color=color;c.drawPath(path,p);p.style=PaintingStyle.fill;}
    void icon(String slug,Rect rect) {c.save();c.translate(rect.left,rect.top);QuestwellItemIconPainter(slug).paint(c,rect.size);c.restore();}
    final cloak=items['chest']=='moss-green-cloak'||items['chest']=='hearthguard-mantle';
    final guardian=items['chest']=='hearthguard-mantle';
    final main=guardian?const Color(0xFF803646):const Color(0xFF38634D);
    final dark=guardian?const Color(0xFF3D2434):const Color(0xFF192E29);
    if(cloak) {
      if(rear) {
        final path=Path()..moveTo(90,81+y)..quadraticBezierTo(120,68+y,150,83+y)
          ..cubicTo(179,127,173,208,187,262)..quadraticBezierTo(153,282,118,264)
          ..quadraticBezierTo(81,281,54,260)..cubicTo(65,203,60,120,90,81+y)..close();
        p.shader=LinearGradient(colors:[dark,main,dark,main,dark]).createShader(const Rect.fromLTWH(54,80,133,192));c.drawPath(path,p);p.shader=null;
        line(path,const Color(0xFFAB8750),1.3);
        for(final x in [71.0,84.0,155.0,167.0])line(Path()..moveTo(120+(x-120)*.5,98)..quadraticBezierTo(x,185,x-3,260),dark.withValues(alpha:.7),2);
      } else {
        final shoulders=Path()..moveTo(92,77+y)..quadraticBezierTo(76,80+y,68,98+y)
          ..quadraticBezierTo(80,111+y,109,109+y)..lineTo(119,90+y)..lineTo(130,109+y)
          ..quadraticBezierTo(152,111+y,169,99+y)..quadraticBezierTo(163,82+y,145,77+y)
          ..quadraticBezierTo(120,100+y,92,77+y)..close();
        fill(shoulders,main);line(shoulders,const Color(0xFFB19763),1.2);
        line(Path()..moveTo(80,97+y)..quadraticBezierTo(100,106+y,113,98+y),dark,2);
        line(Path()..moveTo(135,98+y)..quadraticBezierTo(151,107+y,161,97+y),dark,2);
        p.color=const Color(0xFFD2B678);c.drawOval(Rect.fromLTWH(116,94+y,9,7),p);p.color=guardian?const Color(0xFFEAC785):const Color(0xFF8DC3A6);c.drawOval(Rect.fromLTWH(118,95+y,5,4),p);
      }
    }
    if(rear){c.restore();return;}
    if(items['back']=='wayfarer-satchel') {
      final strap=Path()..moveTo(148,85+y)..quadraticBezierTo(129,125+y,91,164+y);
      line(strap,const Color(0xFF342A23),7);line(strap,const Color(0xFF98744B),4);
      final bag=RRect.fromRectAndRadius(Rect.fromLTWH(70,152+y,42,40),const Radius.circular(5));
      p.color=const Color(0xFF263E35);c.drawRRect(bag,p);p.color=const Color(0xFF53715A);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(70,152+y,42,17),const Radius.circular(4)),p);
      p.color=const Color(0xFFD0B279);c.drawRect(Rect.fromLTWH(87,164+y,8,9),p);p.color=const Color(0xFF624B35);c.drawRect(Rect.fromLTWH(89,166+y,4,5),p);
      p.color=const Color(0xFFDBCBA2);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(66,147+y,50,7),const Radius.circular(3)),p);
      line(Path()..moveTo(77,148+y)..lineTo(77,156+y)..moveTo(105,148+y)..lineTo(105,156+y),const Color(0xFF735237),2);
    }
    if(items['hands']=='annotated-grimoire') {
      final x=female?145.0:150.0;
      p.color=const Color(0xFF34233D);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x,182+y,31,40),const Radius.circular(2)),p);
      p.color=const Color(0xFFDBCCAE);c.drawRect(Rect.fromLTWH(x+3,184+y,26,35),p);
      p.color=const Color(0xFF624C78);c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x-1,181+y,28,37),const Radius.circular(2)),p);
      line(Path()..moveTo(x+4,183+y)..lineTo(x+4,216+y),const Color(0xFFCFAD6E),2);
      p.color=const Color(0xFFC5AE72);c.drawCircle(Offset(x+16,196+y),4,p);p.color=const Color(0xFFAF806F);c.drawRect(Rect.fromLTWH(x+26,189+y,5,4),p);
      line(Path()..moveTo(x+10,207+y)..lineTo(x+23,207+y)..moveTo(x+12,211+y)..lineTo(x+21,211+y),const Color(0xFFD8C9A9),1);
    }
    if(items['feet']=='pathfinder-boots') {
      for(final x in [female?89.0:88.0,female?140.0:141.0]) {
        final path=Path()..moveTo(x,259)..lineTo(x+16,259)..lineTo(x+18,288)..quadraticBezierTo(x+25,294,x+23,299)..lineTo(x-3,299)..lineTo(x-2,290)..close();
        fill(path,const Color(0xFF59422D));line(path,const Color(0xFF2C2923),1.7);
        line(Path()..moveTo(x+2,264)..lineTo(x+14,264),const Color(0xFFBF9F62),3);
        for(final ly in [273.0,278.0,283.0])line(Path()..moveTo(x+4,ly)..lineTo(x+12,ly),const Color(0xFFB29564),1);
        line(Path()..moveTo(x-2,297)..lineTo(x+22,297),const Color(0xFF302B26),3);
      }
    }
    final familiar=items['familiar'];
    if(familiar!=null){
      final flying=familiar.contains('owl')||familiar.contains('moth');
      if(!flying){p.color=const Color(0x44201F22);c.drawOval(const Rect.fromLTWH(171,294,51,7),p);}
      icon(familiar,flying?const Rect.fromLTWH(179,97,53,53):const Rect.fromLTWH(170,245,58,58));
    }
    if(items['effect']=='victory-sparkle'||items['effect']=='focus-tonic') {
      final tonic=items['effect']=='focus-tonic';
      for(var i=0;i<8;i++) {
        final x=i.isEven?51.0-(i%3)*5:185.0+(i%3)*5;
        final sy=98.0+i*24;
        p.color=tonic?const Color(0xBB95D3A0):const Color(0xCCF3D898);
        if(tonic){p.style=PaintingStyle.stroke;p.strokeWidth=1.2;c.drawCircle(Offset(x,sy),2+i%3,p);p.style=PaintingStyle.fill;}
        else {c.drawRect(Rect.fromLTWH(x-3,sy,7,1.5),p);c.drawRect(Rect.fromLTWH(x,sy-3,1.5,7),p);}
      }
    }
    c.restore();
  }
  @override
  bool shouldRepaint(covariant _EquipmentPainter oldDelegate)=>oldDelegate.items!=items||oldDelegate.body!=body||oldDelegate.rear!=rear;
}

/// The window occupies its own architectural slot; lanterns use floor spots.
class QuestwellCatalogRoomArt extends StatelessWidget {
  const QuestwellCatalogRoomArt({super.key,required this.slug});
  final String slug;
  @override
  Widget build(BuildContext context)=>CustomPaint(painter:_RoomArt(slug));
}
class _RoomArt extends CustomPainter {
  const _RoomArt(this.slug);
  final String slug;
  @override
  void paint(Canvas c,Size size) {
    c.save();c.scale(size.width/100,size.height/140);
    final p=Paint()..isAntiAlias=true;
    void rect(double x,double y,double w,double h,Color color){p.color=color;c.drawRect(Rect.fromLTWH(x,y,w,h),p);}
    if(slug=='rainy-window') {
      rect(2,2,96,136,const Color(0xFF332820));rect(5,5,90,126,const Color(0xFF996A43));rect(11,11,78,114,const Color(0xFF1E3545));
      p.shader=const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFF24384D),Color(0xFF537277)]).createShader(const Rect.fromLTWH(13,13,74,110));c.drawRect(const Rect.fromLTWH(13,13,74,110),p);p.shader=null;
      for(var i=0;i<20;i++){final x=17.0+(i*19)%66, y=18.0+(i*31)%94;p.color=const Color(0x667FC6D5);p.strokeWidth=.9;c.drawLine(Offset(x,y),Offset(x-3,y+8),p);}
      rect(46,10,7,116,const Color(0xFF886144));rect(10,64,80,6,const Color(0xFF886144));rect(7,128,88,4,const Color(0xFFBF9063));rect(0,133,100,5,const Color(0xFF4B3425));
    } else {
      p.color=const Color(0x55201810);c.drawOval(const Rect.fromLTWH(13,128,74,9),p);
      p.shader=const RadialGradient(colors:[Color(0xAAFFE3A2),Color(0x00F9CB75)]).createShader(const Rect.fromLTWH(0,15,100,110));c.drawOval(const Rect.fromLTWH(0,15,100,110),p);p.shader=null;
      p.color=const Color(0xFFBC9C60);p.style=PaintingStyle.stroke;p.strokeWidth=4;c.drawOval(const Rect.fromLTWH(35,6,30,29),p);p.style=PaintingStyle.fill;
      rect(25,33,50,6,const Color(0xFFBE9A57));rect(20,39,60,5,const Color(0xFF51412D));
      p.shader=const LinearGradient(colors:[Color(0xFF87673B),Color(0xFFF2D492),Color(0xFF8B6734)]).createShader(const Rect.fromLTWH(26,44,48,75));c.drawRect(const Rect.fromLTWH(26,44,48,75),p);p.shader=null;
      rect(32,48,36,64,const Color(0xFF294D43));rect(37,51,26,56,const Color(0xFF5F8C68));
      p.color=const Color(0xFFE8F0B3);c.drawOval(const Rect.fromLTWH(44,65,13,36),p);rect(45,96,11,12,const Color(0xFFFFEDC4));
      rect(25,118,50,6,const Color(0xFFD6B671));rect(21,125,58,7,const Color(0xFF55422C));
    }
    c.restore();
  }
  @override
  bool shouldRepaint(covariant _RoomArt oldDelegate)=>oldDelegate.slug!=slug;
}

/// Glass coordinates are registered to hearth_environment_v2's 768px canvas.
/// Match its cover crop exactly, leaving every wooden mullion unobscured.
class QuestwellRainyWindowOverlay extends CustomPainter {
  const QuestwellRainyWindowOverlay();
  @override
  void paint(Canvas canvas,Size size) {
    final side=math.max(size.width,size.height);
    canvas.save();canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width-side)/2,(size.height-side)*.52);
    canvas.scale(side/768);
    final panes=Path();
    void pane(List<Offset> points){panes.addPolygon(points,true);}
    pane(const [Offset(725,151),Offset(724,132),Offset(731,104),Offset(744,83),Offset(750,80),Offset(750,145)]);
    pane(const [Offset(759,72),Offset(768,66),Offset(768,143),Offset(758,145)]);
    pane(const [Offset(724,166),Offset(750,158),Offset(750,222),Offset(725,225)]);
    pane(const [Offset(759,156),Offset(768,153),Offset(768,221),Offset(759,222)]);
    pane(const [Offset(725,236),Offset(750,232),Offset(750,297),Offset(725,298)]);
    pane(const [Offset(759,232),Offset(768,230),Offset(768,297),Offset(759,297)]);
    pane(const [Offset(725,308),Offset(750,306),Offset(750,372),Offset(725,370)]);
    pane(const [Offset(759,306),Offset(768,306),Offset(768,375),Offset(759,373)]);
    canvas.clipPath(panes);
    final p=Paint()..color=const Color(0x99435762);
    canvas.drawRect(const Rect.fromLTWH(720,60,50,320),p);
    p.color=const Color(0xBBC1E2DE);p.strokeWidth=1.5;p.isAntiAlias=true;
    for(var i=0;i<66;i++){
      final x=723.0+(i*13)%47,y=68.0+(i*37)%310;
      canvas.drawLine(Offset(x,y),Offset(x-3,y+10),p);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellRainyWindowOverlay oldDelegate)=>false;
}
