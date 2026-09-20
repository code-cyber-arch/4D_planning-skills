---
name: timeline-jsx
description: Build or update an After Effects ExtendScript (.jsx) construction timeline strip, activity tracker, cash flow chart, or key dates ticker driven by programme XML and camera anchor points. Use whenever Abdu asks for a construction timeline, timeline strip, or an update/revision to an existing one.
---

# Construction timeline (.jsx / After Effects) builder

This skill is a self-contained production engine for 4D construction animation overlays: timeline strips, activity trackers, cash flow charts, and key dates tickers that animate in sync with 4D BIM flythroughs. "jsx" here always means Adobe ExtendScript (.jsx), the After Effects scripting format, not React JSX. The structure below is the standard — follow it exactly for every build, regardless of project name or client. Only the data changes each time: the programme dates, the milestones, the camera anchors, and the colour theme.

## Consistency is the default

Given the same inputs, this skill should produce the same structural output every time — same layout math, same helper functions, same build order, same milestone choreography, same conventions. Don't introduce variation (a different colour-derivation method, a different layout tweak, different wording style) between separate builds on your own initiative. Only deviate when: the user explicitly asks for a change this time, or a project's own constraints force it (e.g. month density forcing a smaller `monthSize`, or a genuinely different deliverable like a cash flow chart instead of a timeline strip). Any deviation gets written into that build's companion .md as an explicit note, so it's never silently mistaken for the new default elsewhere.

The same rule applies per client, more strongly: if a client has already had a timeline strip built for one project, every subsequent project for that same client should look visually identical in theme and layout convention — same colour palette, same derivation source, same font, same label style — unless the client's brand has genuinely changed or the user asks for a refresh. Before deriving anything new, always check whether this client is already catalogued (Step 4) or has recorded preferences ("Per-client preferences" below).

## New build vs. updating an existing timeline

Decide which situation applies before doing anything:

- **New build**: no existing .jsx for this deliverable, and the user hasn't referenced one. Follow Steps 1-9 in full.
- **Update**: the user wants a previously built timeline revised — typically because the programme changed (a new/revised XML) and/or the animation timing changed (a new duration, or a new ribbon screenshot with different anchors).

For an update, don't hand-patch the previous .jsx. It's a fully generated, data-driven script (config + anchors + milestones in, layout code out) — patching it piecemeal risks drifting from the standard structure and reintroducing issues the generated version already avoids. Instead, regenerate it from the updated inputs while preserving identity:

1. If the previous .jsx is available, read it first to recover its identity: `PROJECTCODE`, comp name, brand theme/colour values, and any deviations already noted in its header comment or companion .md. Reuse all of that unchanged unless told otherwise — an update should look identical to the original build except where the programme or timing actually changed.
2. Ask once whether anything was hand-edited directly in After Effects since the last build that isn't reflected in the script itself (this has happened before — a display bug fixed by hand in AE rather than by rerunning the script). If so, get that context before regenerating, and either fold the fix into the regenerated logic or flag clearly in the companion .md that the hand fix will need to be reapplied after the new script runs.
3. Re-run Steps 1-9 in full against the new programme XML and/or new ribbon screenshot, producing a complete, freshly generated script that carries the identity recovered in step 1. Treat this exactly like a new build in every other respect — same layout, same helpers, same conventions, same colour theme.
4. Diff the old milestone list against the new one and call out in the companion .md anything added, removed, or re-dated. Don't silently drop a milestone just because a programme revision removed it — confirm that's intended first, the same caution the Synchro reconciliation rules below already apply to deleted activities.
5. Save the regenerated script as a new version rather than silently overwriting the previous file, unless told to replace it outright — e.g. append a version marker or the revision date to the filename — so the prior build stays available for comparison.

## Step 1: Required inputs (every build)

Every build needs three inputs:

1. **The programme XML** (MS Project or Primavera P6) — source for the bar span, the month grid, and the milestone list.
2. **A screenshot of the Synchro timeline summary from the Animation ribbon** — source for the camera anchor points. This screenshot shows the camera's keyframe markers along the flythrough, each annotated with a video timecode and the calendar date the camera is showing at that point.
3. **The colour theme**, given as either: (a) a brand name plus the brand's website, so the theme can be researched, or (b) an attached branding image (logo, brand guide page, colour swatch) to extract the palette from directly — unless the client is already catalogued (Step 4), in which case reuse the catalogued theme and this input isn't needed again.

Read the ribbon screenshot visually and transcribe every marker into an `ANCHORS` array of `{v: videoSeconds, d: date}` pairs, in chronological order, preserving whatever decimal precision the ribbon shows (e.g. `87.37`, not rounded to `87.4`). Do not invent or smooth intermediate points that aren't on the ribbon.

The number of markers on the ribbon determines whether the result is linear or non-linear — it isn't a separate input mode, just how many anchors the piecewise engine (Step 6) ends up interpolating between:

- **Two markers only** (a start and an end point) → constant-rate mapping, effectively linear. Example: `{v:0.09, d:5 Nov 2026}` and `{v:92.16, d:11 Aug 2029}` define a constant-rate mapping across the whole span.
- **Three or more markers** → piecewise, non-linear mapping — segments between markers can cover very different real-world durations for the same video-seconds span. For instance, one segment might be an 8-second span covering just 2 real days, while the next 87-second segment covers over 2 years — whatever unevenness the ribbon actually shows is expected and correct; never smooth it out.

`CFG.duration` is simply the largest `v` value across all anchors. If any of the three inputs is missing (and the client isn't already catalogued), ask for it before building — don't guess anchor points, invent milestone dates, or default to an uncatalogued colour theme.

## Step 2: Extract programme data from the XML

- **Bar span** (`PROG_START` / `PROG_END`): round out to full calendar months bracketing the earliest and latest relevant on-site dates (e.g. site possession → practical completion). This is independent of the camera anchor dates — `PROG_START`/`PROG_END` should land on the 1st/last-of-month even when the nearest anchor or milestone falls mid-month.
- **Milestones**: key dated activities/milestones in scope for this deliverable, each as `{n: name, d: date}`, sorted chronologically. Keep names concise (they render in a pill roughly 300px wide by default — width auto-grows for longer names: `Math.max(300, name.length * 12.5 + 44)`).
- If the deliverable covers only part of a larger programme (e.g. one building or package out of a masterplan with several packages), scope the milestones and bar span to that package only, even when multiple deliverables are being cut from the same source XML.

## Step 3: Comp spec & layout constants

Default comp: `1920×200px`, 25fps, duration = the last (largest `v`) anchor value. Layout is entirely derived from a `CFG` object — do not hardcode pixel positions elsewhere in the script:

```javascript
var CFG = {
    compW: 1920, compH: 200, fps: 25, duration: <last anchor v>,
    labelW: 104, padR: 20, bottomPad: 6,
    yearH: 30, monthH: 24, barH: 30,
    phaseLblAbove: 90, dateLblAbove: 60,
    labelHold: 6.0, labelFade: 0.5,
    yearSize: 22, monthSize: <13-15, tighter as month count grows>,
    phaseLblSize: 24, dateLblSize: 18, sideSize: 15, DR: 9
};
var BLOCK_H   = CFG.yearH + CFG.monthH + CFG.barH;
var YEAR_TOP  = CFG.compH - CFG.bottomPad - BLOCK_H;
var MONTH_TOP = YEAR_TOP + CFG.yearH;
var BAR_TOP   = MONTH_TOP + CFG.monthH;
var BAR_BOT   = BAR_TOP + CFG.barH;
var BAR_CY    = BAR_TOP + CFG.barH / 2;
var TL_X = CFG.labelW + 8;
var TL_W = CFG.compW - TL_X - CFG.padR;
var TL_R = TL_X + TL_W;
var PH_Y = YEAR_TOP - CFG.phaseLblAbove;
var DT_Y = YEAR_TOP - CFG.dateLblAbove;
```

`monthSize` scales down as the month grid gets denser: around 15 for roughly 30-35 months, tightening to around 13 once the span exceeds ~45 months. Use judgement for other spans, or the interactive HTML preview (Step 9) will make any crowding obvious immediately. Once a client has an approved `monthSize` convention for a given density range, reuse it (see "Per-client preferences").

## Step 4: Determine the colour palette

First check whether the client is already catalogued below. If so, reuse that theme exactly — do not re-research or re-derive it, and do not ask the user for a colour theme input again for that client.

| Client | Background | Accent | Source |
|---|---|---|---|
| (catalogue each client's approved theme here once derived) | | | (researched from website / extracted from image / told directly) |

If the client isn't catalogued yet, derive the accent colour one of two ways depending on what's provided:

**(a) Brand name + website.** This is research, so do it before touching any script or template: search for the brand's style guide, media/press kit, or brand assets page; fall back to the website's own CSS/header/logo if no style guide is published. Look specifically for the primary/signature brand colour as a hex or RGB value — that becomes `org`. If no explicit value is published, extract it from the logo (fetch the logo image, sample its dominant non-neutral colour). Report where the colour came from (style guide page, or "sampled from the logo").

**(b) Attached branding image.** Extract the dominant accent colour directly from the image — use a short script (e.g. Python + Pillow: load the image, quantize/cluster pixels, exclude near-white/near-black/near-grey pixels, take the most common remaining cluster) rather than eyeballing, since the rest of the palette is generated from this one hex value and needs to be precise.

Once the accent hex is set, derive the full `COL` object from it with this formula: `org` = the accent itself; `orgHi` = a lighter tint of the accent (used for the bar highlight strip); `orgDim` = a darker shade of the accent (used for leader lines); `yearTxt` = the accent colour; plus a dark neutral set — `bg`, `panelDark`, `yearBg`, `monthBg`, `barTrack`, `borderDim`, `borderMid`, `pillBg`, `pillBrd`, `white`, `offwhite`, `monthTxt`, `sideTxt` — built from a charcoal/near-black family, each a touch lighter than the last (background darkest, panel/track slightly darker still, borders and pills slightly lighter, text near-white). Background stays dark unless the researched brand guide explicitly specifies a light theme — flag that before deviating, since the standard look is a dark base with a single bright accent.

Once a new client's palette is approved (the user signs off on the preview or the first build), catalogue it in the table above immediately — see "Keeping this skill current" below for how.

## Per-client preferences (catalogue as they're learned)

Beyond colour, a client may accumulate other approved conventions over repeat builds — a specific `monthSize`/density choice, a milestone-naming style (e.g. abbreviations vs full names), a layout tweak, a particular deliverable variant they always want alongside the timeline strip. Track these here as they're confirmed:

| Client | Preference | Confirmed on |
|---|---|---|
| (catalogue each client's approved conventions here once learned) | | |

Check this table before starting any build or update for a returning client, and apply what's listed without re-asking.

## Step 5: Helper functions (use verbatim)

```javascript
function addSolid(comp, name, col, w, h, tlX, tlY) {
    var s = comp.layers.addSolid(col, name, Math.max(1, Math.round(w)), Math.max(1, Math.round(h)), 1);
    s.position.setValue([tlX + w / 2, tlY + h / 2]);
    return s;
}
function addText(comp, txt, x, y, size, col, align, bold) {
    var tl = comp.layers.addText(txt);
    var src = tl.sourceText;
    var td = src.value;
    td.resetCharStyle();
    td.fontSize = size;
    td.fillColor = col;
    td.applyFill = true;
    td.applyStroke = false;
    try { td.font = 'MyriadPro-BoldCond'; } catch (e) {
        try { td.font = 'ArialNarrow-Bold'; } catch (e2) {}
    }
    if (align === 'center') td.justification = ParagraphJustification.CENTER_JUSTIFY;
    if (align === 'right')  td.justification = ParagraphJustification.RIGHT_JUSTIFY;
    src.setValue(td);
    tl.position.setValue([x, y]);
    return tl;
}
function fadeIn(L, t0, t1) {
    L.opacity.setValue(0);
    L.opacity.setValueAtTime(Math.max(0, t0 - 0.04), 0);
    L.opacity.setValueAtTime(t1, 100);
}
function fadeInOut(L, tIn, hold, fadeD) {
    L.opacity.setValue(0);
    L.opacity.setValueAtTime(Math.max(0, tIn - 0.3), 0);
    L.opacity.setValueAtTime(tIn, 100);
    L.opacity.setValueAtTime(tIn + hold, 100);
    L.opacity.setValueAtTime(tIn + hold + fadeD, 0);
    L.outPoint = tIn + hold + fadeD + 0.1;
}
```

## Step 6: Piecewise interpolation engine

The same engine handles both 2-anchor and N-anchor cases — there is no branching by mode:

```javascript
function pct(d)  { return Math.max(0, Math.min(1, (d.getTime() - PROG_START.getTime()) / TOTAL_MS)); }
function xPos(d) { return TL_X + pct(d) * TL_W; }

function vidForDate(d) {
    var t = d.getTime();
    if (t <= ANCHORS[0].d.getTime()) return ANCHORS[0].v;
    var last = ANCHORS.length - 1;
    if (t >= ANCHORS[last].d.getTime()) return ANCHORS[last].v;
    for (var a = 0; a < last; a++) {
        var t0 = ANCHORS[a].d.getTime(), t1 = ANCHORS[a + 1].d.getTime();
        if (t >= t0 && t <= t1) {
            var f = (t - t0) / (t1 - t0);
            return ANCHORS[a].v + f * (ANCHORS[a + 1].v - ANCHORS[a].v);
        }
    }
    return ANCHORS[last].v;
}
```

The fill/highlight bar expression is built as a string from the same anchor data (video-seconds array `v[]` and date-fraction array `f[]`), so the expression runs natively in AE without depending on external functions:

```javascript
var _vArr = [], _fArr = [];
for (var _ai = 0; _ai < ANCHORS.length; _ai++) {
    _vArr.push(ANCHORS[_ai].v);
    _fArr.push(pct(ANCHORS[_ai].d));
}
function _arrStr(arr) {
    var out = '[', k;
    for (k = 0; k < arr.length; k++) { out += (k ? ',' : '') + arr[k]; }
    return out + ']';
}
// Piecewise-interpolate current video time through vSec[] -> date-fraction
// the camera is showing -> bar scaleX = frac*100. Forward-only, clamped.
var fillExpr =
    'v = ' + _arrStr(_vArr) + ';\r' +
    'f = ' + _arrStr(_fArr) + ';\r' +
    't = time;\r' +
    'if (t <= v[0]) { frac = f[0]; }\r' +
    'else if (t >= v[v.length-1]) { frac = f[f.length-1]; }\r' +
    'else {\r' +
    '  frac = f[0];\r' +
    '  for (i = 0; i < v.length-1; i++) {\r' +
    '    if (t >= v[i] && t <= v[i+1]) {\r' +
    '      g = (t - v[i]) / (v[i+1] - v[i]);\r' +
    '      frac = f[i] + g * (f[i+1] - f[i]);\r' +
    '      break;\r' +
    '    }\r' +
    '  }\r' +
    '}\r' +
    '[Math.max(0, Math.min(1, frac)) * 100, 100, 100];';
```

## Step 7: Build sequence

Follow this order exactly every time (this is also what "regenerate" means for an update — rerun the same sequence with the updated data):

1. `app.beginUndoGroup('Build <PROJECTCODE> <Brand> 4D Strip')`
2. `addComp('4D_Strip_<PROJECTCODE>_<BRAND>', ...)`, `comp.bgColor = [0,0,0]`
3. Background block (`BG_BarArea`), top accent line (`TopOrangeLine` or equivalent name)
4. Side label panel (`SideBG`, `SideDivider`, `PROJECT\nTIMELINE` text)
5. Year row background, month row background, all border lines
6. Month grid loop: year/month dividers, year labels (left-aligned off the divider, not centred — they don't fit centred at high month density), month labels (skip label if cell `bw <= 16`)
7. `BarTrack` background
8. Build `_vArr`/`_fArr` from `ANCHORS`, construct `fillExpr` (Step 6), create `Progress Bar` solid (anchor point at left edge `[0, barH/2]`, `scale.expression = fillExpr`) and `BarHighlight` (3px, ~28% opacity, same expression)
9. `PC Line` (practical-completion marker at the right edge)
10. Milestone loop (Step 8 below)
11. Controller null: `name = '[ TIMELINE CONTROLLER ]'`, `label = 2`
12. `app.endUndoGroup()`, then an `alert()` summarising: comp name/spec, anchor timing table, bar span, placement instructions, full milestone/date list

## Step 8: Milestone choreography (per milestone, in the loop)

For each milestone at `mx = xPos(ms.d)`, `mt = vidForDate(ms.d)`:
- `Tick_i`: 2px vertical line through the full block height, fades in over the 0.3s before `mt` (`fadeIn`)
- `Diamond_i`: 18x18 solid rotated 45° centred on the bar, same fade-in
- `Dot_i`: 5x5 white solid centred on the bar, same fade-in
- `Flash_i`: 80px-wide white solid pulse at the bar, hand-keyframed opacity (0 → 82% → 0 → 48% → 0 → 22% → 0 over ~1s from `mt`) — not `fadeIn`/`fadeInOut`, this one is bespoke
- `Leader_i`: 1px vertical line from the phase-label row down to the year row, using `fadeInOut(mt, labelHold, labelFade)`
- `PhasePill_i` + `PhaseBrd_i` + `PhaseLabel_i`: pill background, top accent border, and milestone name text, all `fadeInOut`
- `DatePill_i` + `DateBrd_i` + `DateLabel_i`: pill background, border, and formatted date (`D MMM YYYY`), all `fadeInOut`
- Pills are horizontally clamped so they never run off either edge: `lx = clamp(mx, TL_X + halfMax + 4, TL_R - halfMax - 4)`

## Step 9: Interactive preview before the final build

For a first-time build for a new client (new brand theme, unfamiliar month density, or anchors being transcribed from a ribbon screenshot for the first time), build an HTML interactive preview with a timeline slider so the sizes, colours, positions, and milestone data can be checked before the .jsx is finalised — expect a few rounds of visual correction. This gate can be skipped for a repeat build, or a straightforward update, for an already-catalogued client that clearly matches their approved theme and layout.

## ExtendScript / After Effects conventions — non-negotiable

- ES3-compliant ExtendScript only: `var` declarations only, `for` loops (never `.forEach()`), no arrow functions, no template literals, no other ES6 syntax, no shape layers. Layer creation uses only `addSolid()`/`addText()`.
- Keyframe interpolation via numeric constants `6612` (linear) / `6613` (ease out) where explicit interpolation types are needed — never the `KeyframeInterpolationType` enum. Avoid `setTemporalEaseAtKey()`. Driving everything through `setValueAtTime` and expressions (as in Steps 5-6) sidesteps this entirely — prefer that pattern.
- No ADBE Vector Stroke Dash API — draw dashes manually via loop functions.
- Font stack: MyriadPro-BoldCond primary, ArialNarrow-Bold fallback, via try/catch (see `addText` above).
- Naming convention: `[PROJECTCODE]_[Deliverable]_BUILD.jsx`, comp named `4D_Strip_[PROJECTCODE]_[BRAND]`.
- Anchor point discipline: left-edge fills use `[0, h/2]` (or `[-slotW/2, 0]` for slot-based layouts), never right-edge; centred shapes (diamonds, dots) anchor at their own centre.
- Forward-only progress fills: bar/highlight `scale.expression` is clamped 0-100, monotonic with time given monotonic anchor dates — the camera never jumps backward in these videos.
- Cash flow and similar bar charts (different deliverable, same engine): scale bars to their own individual values, never cumulative — draw the cumulative total as a separate line.

## Placement in the main comp

Always include in the header comment and the closing alert: drag the strip into the 1920×1080 main comp, set layer Y so the bottom edge sits at 1080 (Y = 980 in AE's centre-anchor default), the top ~110px is transparent so labels float over footage, and enable "Collapse Transformations" on the layer.

## Synchro 4D XML rules (only when the project also syncs to Synchro)

- Synchro matches resources by full WBS path code, not just Activity ID. Never let a fix shift an existing WBS path — it orphans 3D resource links.
- Treat the original Synchro XML file as the strict base; append new content, matching nodes by activity content rather than name.
- When reconciling a revised programme, retain activities deleted in the new version with their original dates, to preserve resource links.
- If the source XML carries no matching Activity IDs across systems, reconcile on WBS path plus activity name instead.

## Companion documentation

For every build or update, produce a companion .md file alongside the script documenting: the source XML and date range, the anchor points transcribed from the ribbon screenshot, the extracted milestone list, how the colour theme was sourced or which catalogued entry was reused, any deviation from the standard defaults and why, and the exact execution steps ("File > Scripts > Run Script File" in AE, plus the placement steps above). For an update specifically, also document what changed from the previous version (anchors, milestones, duration, bar span) and any hand-edits from the prior build that need reapplying. This is a standing requirement for all multi-step build work.

## Keeping this skill current (self-updating)

This skill is meant to accumulate real production knowledge over time, the same way a human colleague would remember a client's brand and preferences after working with them once. Concretely, after finishing a build or update:

- If a new client's colour theme was just derived and approved (the user accepted the preview or the final build without asking for a colour change), add that client's row to the colour table in Step 4 with its background, accent, and source.
- If the user corrected or specified something during this build that should hold for every future build — for this client specifically, or as a new general default — add it to "Per-client preferences" (client-specific) or update the relevant step above (general default), rather than only applying it to the current script.
- Do this proactively, without waiting to be asked: propose the updated skill file right after the build is done, in the same turn, and tell the user in one line that a skill update is ready for them to review and save. Skill files can only be changed through that review-and-save step — there's no way to silently edit this skill's own content, so the proposal is what makes the learning stick for next time.
- Only catalogue durable, reusable facts this way (a confirmed brand colour, a standing client preference) — not one-off exceptions for a single deliverable, which belong in that build's companion .md instead.
