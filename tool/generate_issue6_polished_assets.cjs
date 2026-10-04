const fs = require('node:fs');
const path = require('node:path');
const sharp = require('sharp');

const root = path.resolve(__dirname, '..');
const outDir = path.join(root, 'assets/images/questwell/hearth');
fs.mkdirSync(outDir, {recursive:true});

const lantern = `
<svg xmlns="http://www.w3.org/2000/svg" width="900" height="1500" viewBox="0 0 900 1500">
  <defs>
    <linearGradient id="brass" x1="0" x2="1">
      <stop offset="0" stop-color="#5f3f25"/><stop offset=".18" stop-color="#b98b4d"/>
      <stop offset=".42" stop-color="#f0cf82"/><stop offset=".62" stop-color="#9c6e3b"/>
      <stop offset=".84" stop-color="#d9ad62"/><stop offset="1" stop-color="#4f3423"/>
    </linearGradient>
    <linearGradient id="wood" x1="0" x2="1">
      <stop offset="0" stop-color="#3e2a22"/><stop offset=".25" stop-color="#76513a"/>
      <stop offset=".52" stop-color="#9d7048"/><stop offset=".75" stop-color="#644330"/>
      <stop offset="1" stop-color="#34231d"/>
    </linearGradient>
    <linearGradient id="glass" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#16372f"/><stop offset=".22" stop-color="#2f6b53"/>
      <stop offset=".48" stop-color="#6e9d69"/><stop offset=".62" stop-color="#284e40"/>
      <stop offset="1" stop-color="#112a27"/>
    </linearGradient>
    <radialGradient id="ward" cx=".5" cy=".5" r=".58">
      <stop offset="0" stop-color="#fff8bd"/><stop offset=".28" stop-color="#dfeaa3"/>
      <stop offset=".62" stop-color="#72a16c"/><stop offset="1" stop-color="#214d3e"/>
    </radialGradient>
    <radialGradient id="glow">
      <stop offset="0" stop-color="#c9e884" stop-opacity=".48"/>
      <stop offset=".45" stop-color="#70a96c" stop-opacity=".22"/>
      <stop offset="1" stop-color="#70a96c" stop-opacity="0"/>
    </radialGradient>
    <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="16"/>
    </filter>
    <filter id="soft" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur stdDeviation="8"/>
    </filter>
    <pattern id="hammer" width="28" height="28" patternUnits="userSpaceOnUse">
      <circle cx="6" cy="8" r="2" fill="#f1d58c" opacity=".20"/>
      <circle cx="20" cy="18" r="2.5" fill="#3d291d" opacity=".20"/>
      <path d="M2 23l9-3M17 5l8-2" stroke="#fff4be" stroke-width="1.5" opacity=".12"/>
    </pattern>
  </defs>
  <ellipse cx="450" cy="1415" rx="255" ry="38" fill="#110c09" opacity=".36" filter="url(#shadow)"/>
  <ellipse cx="450" cy="610" rx="330" ry="390" fill="url(#glow)"/>

  <!-- walnut pedestal -->
  <path d="M355 1032h190l34 44-18 44H339l-18-44z" fill="#201611"/>
  <path d="M366 1040h168l24 35-11 28H352l-10-28z" fill="url(#wood)"/>
  <path d="M408 1104h84v244h-84z" fill="#2a1b17"/>
  <path d="M419 1110h62v232h-62z" fill="url(#wood)"/>
  <path d="M426 1110h14v232" stroke="#c08a52" stroke-width="5" opacity=".40"/>
  <path d="M368 1336h164l34 42-15 28H349l-15-28z" fill="#201611"/>
  <path d="M380 1343h140l25 30-9 18H364l-9-18z" fill="url(#wood)"/>
  <path d="M389 1355h122" stroke="#d1a05e" stroke-width="5" opacity=".45"/>

  <!-- lamp handle -->
  <path d="M325 225c0-125 54-183 125-183s125 58 125 183" fill="none" stroke="#2a1b15" stroke-width="38" stroke-linecap="round"/>
  <path d="M327 225c0-117 52-166 123-166s123 49 123 166" fill="none" stroke="url(#brass)" stroke-width="24" stroke-linecap="round"/>
  <path d="M349 203c10-91 48-124 101-124" fill="none" stroke="#ffe4a0" stroke-width="6" stroke-linecap="round" opacity=".75"/>

  <!-- crown and shoulder -->
  <path d="M310 222h280l-34 82H344z" fill="#241811"/>
  <path d="M324 230h252l-30 62H354z" fill="url(#brass)"/>
  <path d="M364 286h172l23 33H341z" fill="#22160f"/>
  <path d="M372 291h156l16 22H356z" fill="#d7aa60"/>
  <path d="M304 314h292v46H304z" fill="#211710"/>
  <path d="M316 322h268v30H316z" fill="url(#brass)"/>

  <!-- body outer -->
  <path d="M292 355h316l-22 560H314z" fill="#1d1410"/>
  <path d="M311 372h278l-19 521H330z" fill="url(#brass)"/>
  <path d="M352 408h196l-8 439H360z" fill="#111b18"/>
  <path d="M366 422h168l-6 410H372z" fill="url(#glass)"/>
  <path d="M366 422h168l-6 410H372z" fill="url(#hammer)" opacity=".55"/>

  <!-- ribs -->
  <path d="M330 386l52 26-12 428-43 29M570 386l-52 26 10 428 45 29" fill="none" stroke="#d5aa62" stroke-width="16"/>
  <path d="M450 398v448M348 606h204" stroke="#38251a" stroke-width="22"/>
  <path d="M450 402v440M352 604h196" stroke="#e0b96b" stroke-width="9" opacity=".8"/>

  <!-- guardian ward -->
  <circle cx="450" cy="620" r="112" fill="url(#ward)" opacity=".92" filter="url(#soft)"/>
  <path d="M450 465l82 155-82 158-82-158z" fill="#dce79e" stroke="#e8c878" stroke-width="12"/>
  <path d="M450 493l57 127-57 128-57-128z" fill="#214c3c" stroke="#f0dc8e" stroke-width="8"/>
  <path d="M450 526l35 94-35 95-35-95z" fill="#eff4b3"/>
  <path d="M450 449v343M335 620h230" stroke="#e7c676" stroke-width="9" opacity=".9"/>
  <circle cx="450" cy="620" r="18" fill="#fff8ca" stroke="#6f8d5a" stroke-width="6"/>

  <!-- corner filigree -->
  <g fill="none" stroke="#d8ad65" stroke-width="10" opacity=".85">
    <path d="M333 470c45 0 46-47 46-77M567 470c-45 0-46-47-46-77"/>
    <path d="M333 762c45 0 46 47 46 77M567 762c-45 0-46 47-46 77"/>
  </g>
  <g fill="#7c5d37">
    <circle cx="345" cy="481" r="10"/><circle cx="555" cy="481" r="10"/>
    <circle cx="345" cy="750" r="10"/><circle cx="555" cy="750" r="10"/>
  </g>

  <!-- base -->
  <path d="M302 894h296l28 54-38 48H312l-38-48z" fill="#1c130f"/>
  <path d="M318 905h264l20 40-25 34H323l-25-34z" fill="url(#brass)"/>
  <path d="M350 930h200" stroke="#f0cf84" stroke-width="7" opacity=".72"/>
  <path d="M383 976h134l20 40-18 34H381l-18-34z" fill="#2b1d16"/>
  <path d="M395 984h110l15 29-11 22H391l-10-22z" fill="url(#wood)"/>

  <!-- tiny highlights -->
  <path d="M389 445v130M388 672v106M492 440v72" stroke="#d8f1bd" stroke-width="5" opacity=".28"/>
  <path d="M336 347h130" stroke="#fff0b1" stroke-width="5" opacity=".55"/>
</svg>`;

const rug = `
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="900" viewBox="0 0 1200 900">
  <defs>
    <linearGradient id="field" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#173a2f"/><stop offset=".48" stop-color="#24533f"/><stop offset="1" stop-color="#163328"/>
    </linearGradient>
    <linearGradient id="gold" x1="0" x2="1">
      <stop offset="0" stop-color="#705631"/><stop offset=".24" stop-color="#c2a263"/>
      <stop offset=".54" stop-color="#efd18a"/><stop offset=".78" stop-color="#a7844d"/><stop offset="1" stop-color="#614a2c"/>
    </linearGradient>
    <pattern id="weave" width="18" height="18" patternUnits="userSpaceOnUse">
      <path d="M0 3h18M0 12h18" stroke="#5a8d6c" stroke-width="2" opacity=".18"/>
      <path d="M4 0v18M13 0v18" stroke="#102b23" stroke-width="2" opacity=".22"/>
      <path d="M0 0l18 18M18 0L0 18" stroke="#e1c077" stroke-width="1" opacity=".045"/>
    </pattern>
    <filter id="shadow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="16"/>
    </filter>
    <clipPath id="rugclip"><path d="M300 190h600l175 545H125z"/></clipPath>
  </defs>
  <path d="M130 742h940" stroke="#0f0c09" stroke-width="52" opacity=".24" filter="url(#shadow)"/>
  <path d="M300 190h600l175 545H125z" fill="#0e1713"/>
  <path d="M315 208h570l156 502H159z" fill="url(#gold)"/>
  <path d="M345 235h510l132 445H213z" fill="#0f211b"/>
  <path d="M365 252h470l118 405H247z" fill="url(#field)"/>
  <path d="M365 252h470l118 405H247z" fill="url(#weave)"/>

  <!-- inner border -->
  <path d="M391 276h418l99 355H292z" fill="none" stroke="#d1b06b" stroke-width="14"/>
  <path d="M407 293h386l87 320H320z" fill="none" stroke="#6e5937" stroke-width="7"/>
  <path d="M424 309h352l76 286H348z" fill="none" stroke="#a88d59" stroke-width="4" stroke-dasharray="18 10"/>

  <!-- compass medallion -->
  <ellipse cx="600" cy="452" rx="174" ry="132" fill="#17342a" stroke="#b99c5e" stroke-width="10"/>
  <ellipse cx="600" cy="452" rx="151" ry="113" fill="none" stroke="#6e5937" stroke-width="5" stroke-dasharray="10 9"/>
  <g transform="translate(600 452)">
    <path d="M0-145L34-22 0 0-34-22z" fill="#e5c57d"/><path d="M0 145L34 22 0 0-34 22z" fill="#9b7c47"/>
    <path d="M-190 0L-30-25 0 0-30 25z" fill="#c2a15f"/><path d="M190 0L30-25 0 0 30 25z" fill="#765d37"/>
    <path d="M-125-97L-20-18 0 0-36-4z" fill="#9e804b"/><path d="M125 97L20 18 0 0 36 4z" fill="#d2af69"/>
    <path d="M125-97L20-18 0 0 36-4z" fill="#c7a560"/><path d="M-125 97L-20 18 0 0-36 4z" fill="#80643b"/>
    <circle r="29" fill="#0f2820" stroke="#e0c078" stroke-width="7"/>
    <circle r="9" fill="#f0d797"/>
  </g>

  <!-- corner diamonds and small star stitches -->
  <g fill="#c8a967" stroke="#6a5333" stroke-width="4">
    <path d="M388 346l28 22-28 22-28-22z"/><path d="M812 346l28 22-28 22-28-22z"/>
    <path d="M335 560l30 22-30 22-30-22z"/><path d="M865 560l30 22-30 22-30-22z"/>
  </g>
  <g stroke="#e2c780" stroke-width="4" opacity=".65">
    <path d="M470 330v28M456 344h28M730 330v28M716 344h28"/>
    <path d="M425 575v28M411 589h28M775 575v28M761 589h28"/>
  </g>

  <!-- fringe -->
  <g stroke="#b99558" stroke-width="8" stroke-linecap="round">
    <path d="M151 714l-18 38M186 714l-14 43M221 714l-10 46M256 714l-7 48M291 714l-4 50"/>
    <path d="M944 714l7 48M979 714l10 46M1014 714l14 43M1049 714l18 38"/>
  </g>
  <g stroke="#6b5332" stroke-width="4" opacity=".8">
    <path d="M143 716l-15 36M213 716l-8 43M987 716l9 43M1057 716l15 36"/>
  </g>
</svg>`;

async function render(svg, out, width, height) {
  await sharp(Buffer.from(svg)).resize(width, height, {fit:'fill'})
    .webp({quality:94, alphaQuality:100, smartSubsample:true})
    .toFile(path.join(outDir, out));
}

(async()=>{
  await render(lantern, 'warding_lantern_v2.webp', 900, 1500);
  await render(rug, 'emerald_wayfarer_rug_v2.webp', 1200, 900);
  console.log('generated Issue #6 polished assets');
})().catch(err=>{console.error(err);process.exitCode=1;});
