import 'dart:math' as math;
import 'package:flutter/material.dart';

/// New catalog layers use the same authored 240×320 registration as the avatar.
/// Garments are continuous canvas shapes; familiars have a dedicated art layer.
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
    final p=Paint()..isAntiAlias=true;
    void fill(Path path,Color color){p.shader=null;p.style=PaintingStyle.fill;p.color=color;c.drawPath(path,p);}
    void line(Path path,Color color,double width){p.shader=null;p.style=PaintingStyle.stroke;p.strokeWidth=width;p.color=color;c.drawPath(path,p);p.style=PaintingStyle.fill;}
    if(rear){c.restore();return;}
    if(items['feet']=='pathfinder-boots') {
      for(final x in [female?89.0:88.0,female?140.0:141.0]) {
        final path=Path()..moveTo(x,259)..lineTo(x+16,259)..lineTo(x+18,288)..quadraticBezierTo(x+25,294,x+23,299)..lineTo(x-3,299)..lineTo(x-2,290)..close();
        fill(path,const Color(0xFF59422D));line(path,const Color(0xFF2C2923),1.7);
        line(Path()..moveTo(x+2,264)..lineTo(x+14,264),const Color(0xFFBF9F62),3);
        for(final ly in [273.0,278.0,283.0])line(Path()..moveTo(x+4,ly)..lineTo(x+12,ly),const Color(0xFFB29564),1);
        line(Path()..moveTo(x-2,297)..lineTo(x+22,297),const Color(0xFF302B26),3);
      }
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

/// Only the glass layer repaints; room art and wooden framing remain cached.
class QuestwellRainyWindow extends StatefulWidget {
  const QuestwellRainyWindow({super.key});
  @override
  State<QuestwellRainyWindow> createState() => _QuestwellRainyWindowState();
}
class _QuestwellRainyWindowState extends State<QuestwellRainyWindow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rain = AnimationController(
    vsync: this, duration: const Duration(seconds: 6));
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) || !TickerMode.of(context)) {
      _rain.stop();
      _rain.value = 0;
    } else if (!_rain.isAnimating) {
      _rain.repeat();
    }
  }
  @override
  void dispose() { _rain.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: RepaintBoundary(
    child: AnimatedBuilder(animation: _rain, builder: (context, _) =>
      CustomPaint(painter: QuestwellRainyWindowOverlay(phase: _rain.value)))));
}

/// Glass coordinates are registered to hearth_environment_v2's 768px canvas.
/// Match its cover crop exactly, leaving every wooden mullion unobscured.
class QuestwellRainyWindowOverlay extends CustomPainter {
  const QuestwellRainyWindowOverlay({this.phase = 0});
  final double phase;
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
    p.isAntiAlias=true;
    for(var i=0;i<40;i++) {
      final near=i%3==0;
      final travel=((i*37)+phase*320*(near?2:1))%320;
      final x=726.0+(i*13)%48-travel*.025;
      final y=60.0+travel;
      p.color=near?const Color(0xCDD3ECE7):const Color(0x808EBACB);
      p.strokeWidth=near?1.8:1.1;
      canvas.drawLine(Offset(x,y),Offset(x-2.5,y+(near?13:8)),p);
    }
    // A few slower beads slide down the inside of the glass.
    for(var i=0;i<5;i++) {
      final y=60.0+(i*67+phase*320)%320;
      final x=729.0+(i*11)%38;
      p.color=const Color(0x809CBBC9);p.strokeWidth=2.2;
      canvas.drawLine(Offset(x,y-18),Offset(x,y),p);
      p.color=const Color(0xCCD4E4E5);
      canvas.drawOval(Rect.fromCenter(center:Offset(x,y),width:2.6,height:4),p);
    }
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant QuestwellRainyWindowOverlay oldDelegate)=>oldDelegate.phase!=phase;
}
