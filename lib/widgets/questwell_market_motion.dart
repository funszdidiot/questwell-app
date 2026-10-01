import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'questwell_typography.dart';

/// Paint-only accents, registered to the approved shopfront artwork.
/// RepaintBoundary keeps ambient ticks out of the static storefront and shop.
class QuestwellMarketAmbience extends StatefulWidget {
  const QuestwellMarketAmbience({super.key});
  @override
  State<QuestwellMarketAmbience> createState() => _QuestwellMarketAmbienceState();
}
class _QuestwellMarketAmbienceState extends State<QuestwellMarketAmbience>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(vsync: this,
    duration: const Duration(seconds: 12));
  bool _enabled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = !MediaQuery.disableAnimationsOf(context) && TickerMode.of(context);
    if (enabled != _enabled) {
      _enabled = enabled;
      if (enabled) { _clock.repeat(); } else { _clock.stop(); }
    }
  }
  @override
  void dispose() { _clock.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: ExcludeSemantics(
    child: RepaintBoundary(child: CustomPaint(
      painter: _ShopLightPainter(_clock, enabled: _enabled)))));
}
class _ShopLightPainter extends CustomPainter {
  _ShopLightPainter(this.clock, {required this.enabled}) : super(repaint: clock);
  final Animation<double> clock;
  final bool enabled;
  @override
  void paint(Canvas canvas, Size size) {
    if (!enabled) return;
    final seconds = clock.value * 12;
    const lights = [(0.039, 0.39, 1.0), (0.961, 0.39, 1.0),
      (0.221, 0.435, 0.65), (0.779, 0.435, 0.65)];
    for (var i = 0; i < lights.length; i++) {
      final light = lights[i];
      final strength = 0.27 + 0.14 * math.sin(seconds * math.pi / 2 + i * 1.7)
        + 0.025 * math.sin(seconds * math.pi * 2 / 3 + i);
      final center = Offset(size.width * light.$1, size.height * light.$2);
      final radius = size.width * .065 * light.$3;
      final paint = Paint()..shader = RadialGradient(colors: [
        const Color(0xFFFFCF73).withValues(alpha: strength),
        const Color(0xFFFFB647).withValues(alpha: strength * .65),
        const Color(0x00FFB647),
      ], stops: const [0, .4, 1]).createShader(Rect.fromCircle(center:center,radius:radius));
      canvas.drawCircle(center, radius, paint);
      // A small bright flame changes height inside the lantern glass.
      final unit=size.width/355;
      final flame=Paint()..isAntiAlias=false
        ..color=const Color(0xFFFFF1B8).withValues(alpha:strength+.22);
      final height=(5+2*math.sin(seconds*math.pi+i))*unit*light.$3;
      canvas.drawRect(Rect.fromLTWH(center.dx-unit,center.dy-height/2,
        2*unit,height),flame);
      canvas.drawRect(Rect.fromLTWH(center.dx,center.dy-height/2-unit,
        unit,unit),flame);
    }
    // Alternate bottles every three seconds; one readable bubble at a time.
    final right=(seconds~/3).isOdd;
    final local=seconds%3;
    if(local>=.3 && local<=2.3){
      final progress=(local-.3)/2;
      final alpha=math.sin(progress*math.pi)*.85;
      final unit=size.width/355;
      final x=size.width*(right?.749:.119);
      final y=size.height*(.565-.07*progress);
      final paint=Paint()..isAntiAlias=false
        ..color=(right?const Color(0xFFBCF3EF):const Color(0xFFEAD0FF))
          .withValues(alpha:alpha);
      final bubble=Rect.fromCenter(center:Offset(x+math.sin(progress*math.pi)*2*unit,y),
        width:3*unit,height:3*unit);
      paint.style=PaintingStyle.stroke;paint.strokeWidth=unit;
      canvas.drawRect(bubble,paint);
      if(progress<.55){
        paint.style=PaintingStyle.fill;
        final center=Offset(x,size.height*.62);
        canvas.drawRect(Rect.fromCenter(center:center,width:unit,height:6*unit),paint);
        canvas.drawRect(Rect.fromCenter(center:center,width:6*unit,height:unit),paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _ShopLightPainter old) => old.enabled != enabled || old.clock != clock;
}

class QuestwellCoinBalance extends StatelessWidget {
  const QuestwellCoinBalance({super.key, required this.coins});
  final int coins;
  Widget _label(int value)=>Text('◈  $value coins',
    style:QuestwellTypography.body(color:const Color(0xFFE0BF79),
      fontWeight:FontWeight.w700,fontSize:16));
  @override
  Widget build(BuildContext context) => Semantics(label:'$coins coins',
    child: ExcludeSemantics(child:MediaQuery.disableAnimationsOf(context)
      ? _label(coins)
      : TweenAnimationBuilder<int>(tween:IntTween(begin:coins,end:coins),
          duration:const Duration(milliseconds:650),curve:Curves.easeOutCubic,
          builder:(context,value,child)=>_label(value))));
}

/// Celebrate only a confirmed unowned -> owned transition, never a button tap.
class QuestwellPurchaseGlow extends StatefulWidget {
  const QuestwellPurchaseGlow({super.key,required this.owned,required this.child});
  final bool owned;
  final Widget child;
  @override
  State<QuestwellPurchaseGlow> createState()=>_QuestwellPurchaseGlowState();
}
class _QuestwellPurchaseGlowState extends State<QuestwellPurchaseGlow>
    with SingleTickerProviderStateMixin {
  late final _pulse=AnimationController(vsync:this,
    duration:const Duration(milliseconds:1200));
  @override
  void didUpdateWidget(covariant QuestwellPurchaseGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.owned && widget.owned && !MediaQuery.disableAnimationsOf(context)) {
      _pulse.forward(from:0);
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(MediaQuery.disableAnimationsOf(context)) {_pulse.stop();_pulse.value=0;}
  }
  @override
  void dispose(){_pulse.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>AnimatedBuilder(animation:_pulse,
    child:widget.child,builder:(context,child){
      final amount=math.sin(_pulse.value*math.pi);
      return DecoratedBox(decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(12),
        boxShadow:[BoxShadow(color:const Color(0xFFE0BF79).withValues(alpha:.48*amount),
          blurRadius:12*amount,spreadRadius:2*amount)]),child:child);
    });
}
