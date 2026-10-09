from PIL import Image
from pathlib import Path
import json
root=Path('assets/images/questwell/hearth')
names=['amberfall_scenery_candidate_v1.png','maple_rug_candidate_v1.png','mooncap_grove_candidate_v1.png','harvest_lanterns_candidate_v1.png','sages_rest_candidate_v1.png','moonbrew_side_table_v1.webp','midnight_visitors_print_v1.webp','moonlit_woodland.webp','moonweb_rug_v1.webp','velvet_batwing_chair_v1.webp','witchlight_bookcase_v1.webp']
rows=[]
for name in names:
 p=root/name; im=Image.open(p).convert('RGBA'); out=root/(p.stem+'_delivery_v1.webp')
 im.save(out,'WEBP',quality=92,method=6,exact=True,alpha_quality=100)
 decoded=Image.open(out).convert('RGBA')
 assert im.size==decoded.size and im.getchannel('A').tobytes()==decoded.getchannel('A').tobytes()
 rows.append({'source':str(p),'delivery':str(out),'source_bytes':p.stat().st_size,'delivery_bytes':out.stat().st_size})
Path('tool/hearth_delivery_manifest.json').write_text(json.dumps(rows))
code="/// Delivery encodings preserve source dimensions and exact alpha.\nabstract final class QuestwellHearthAssets {\n  static const variants = <String, String>{\n"+''.join("    '%s': '%s',\n"%(r['source'],r['delivery']) for r in rows)+"  };\n  static String resolve(String source) => variants[source] ?? source;\n}\n"
Path('lib/widgets/questwell_hearth_assets.dart').write_text(code)
print(sum(r['source_bytes'] for r in rows),sum(r['delivery_bytes'] for r in rows))
