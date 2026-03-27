# Metro Asset Audit

## Scope

- Workspace: `D:\road_creator`
- Asset roots checked:
  - `assets/metro_guide/`
  - `assets/metro_guide/guangzhou/`
  - `assets/metro_guide/mtr/`
  - `assets/metro_guide/jr/`
- Model file checked:
  - `lib/models/metro_models.dart`

## Summary

### Shanghai

- Asset set present:
  - `line@01.svg` to `line@31.svg`
  - `clss@01.svg` to `clss@31.svg`
  - `cls@01.svg` to `cls@37.svg`
- Model status:
  - `MetroLineInfo.shanghaiLines` now covers `1-31`
  - Local line colors were aligned to the actual SVG fills
- Conclusion:
  - Shanghai is the most complete built-in city set in the project right now

### Guangzhou

- Asset set present:
  - `gz01.svg` to `gz09.svg`
  - `gz13.svg`
  - `gz14.svg`
  - `gzGF.svg`
  - `gzAPM.svg`
- Model status:
  - Numbered lines with confirmed local assets were kept
  - Unsupported numbered placeholders `18 / 21 / 22` were removed from the model for now
  - Current colors were aligned to the local SVG fills
- Known gap:
  - `gzGF.svg` and `gzAPM.svg` are present as assets, but the current `MetroLineInfo` model is still number-oriented and cannot represent those two special lines cleanly
- Conclusion:
  - Guangzhou is city-specific, but not fully modeled yet

### MTR

- Asset set present:
  - `mtr1.svg` to `mtr11.svg`
- Model status:
  - Local colors were aligned to the asset fills
  - `mtr11.svg` was wired into the model as `High Speed Rail`
- Known gap:
  - The current local filenames do not encode the official line name directly, so filename-to-line-name confidence is lower than Shanghai
- Conclusion:
  - MTR is not a Shanghai reuse set, but it still needs a stronger source manifest

### JR

- Asset set present:
  - `jr01.svg` to `jr08.svg`
- Asset style:
  - White sign body
  - JR-style top and bottom color stripes
  - Left JR badge
  - Japanese line name + English line name
- Model status:
  - Added as a new selectable city set `JR East`
  - Added starter lines:
    - Yamanote
    - Chuo Rapid
    - Sobu
    - Keihin-Tohoku
    - Saikyo
    - Yokosuka
    - Keiyo
    - Nambu
- Conclusion:
  - This is a new local `JR-style` starter library, not an official full JR asset dump

## Local Color Check

### Shanghai sampled fills

- `line@01.svg` -> `#C23A30`
- `line@02.svg` -> `#C23A30`
- `line@03.svg` -> `#006098`
- `line@04.svg` -> `#E60033`
- `line@05.svg` -> `#008E9C`
- `line@31.svg` -> `#004BA0`

### Guangzhou fills

- `gz01.svg` -> `#F3D03E`
- `gz02.svg` -> `#00629B`
- `gz03.svg` -> `#ECA154`
- `gz04.svg` -> `#00843D`
- `gz05.svg` -> `#C5003E`
- `gz06.svg` -> `#80225F`
- `gz07.svg` -> `#97D700`
- `gz08.svg` -> `#008C95`
- `gz09.svg` -> `#71CC98`
- `gz13.svg` -> `#8E8C13`
- `gz14.svg` -> `#81312F`
- `gzGF.svg` -> `#C4D600`
- `gzAPM.svg` -> `#00B5E2`

### MTR fills

- `mtr1.svg` -> `#007078`
- `mtr2.svg` -> `#EFA540`
- `mtr3.svg` -> `#80CC28`
- `mtr4.svg` -> `#7D5BBD`
- `mtr5.svg` -> `#F27E23`
- `mtr6.svg` -> `#1E6EB2`
- `mtr7.svg` -> `#EE2C74`
- `mtr8.svg` -> `#ED7B23`
- `mtr9.svg` -> `#A74629`
- `mtr10.svg` -> `#4CB05E`
- `mtr11.svg` -> `#961A1E`

### JR fills

- `jr01.svg` -> `#7CC242`
- `jr02.svg` -> `#F15A22`
- `jr03.svg` -> `#FFD400`
- `jr04.svg` -> `#00A7E3`
- `jr05.svg` -> `#00A040`
- `jr06.svg` -> `#1F2F6B`
- `jr07.svg` -> `#D40078`
- `jr08.svg` -> `#FFC20E`

## Next Actions

- Extend the metro line metadata model so Guangzhou special lines such as `GF` and `APM` can be represented as first-class entries.
- Add missing Guangzhou local SVG if lines `18 / 21 / 22` are intended to be supported later.
- Verify the MTR filename-to-line-name mapping against the original source package before treating it as final.
- Expand the JR starter library if more regional or rapid-service variants are needed.
