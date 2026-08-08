# 精确排盘（让"准一点"落地）

四柱里最容易算错的是**月柱（按节气）**和**日柱（按实际历法）**。手算容易偏差，建议用库精确计算。

## 用 lunar_python（sxtwl）精确拿四柱
```python
# pip install lunar_python
from lunar_python import Lunar
# 阳历生日：年, 月, 日, 时(0-23), 分
lunar = Lunar.fromYmdHms(1990, 5, 20, 14, 30)
bazi = lunar.getEightChar()
print("年柱", bazi.getYear())   # 如 庚午
print("月柱", bazi.getMonth())  # 如 辛巳
print("日柱", bazi.getDay())    # 如 乙酉
print("时柱", bazi.getTime())   # 如 癸未
print("生肖", lunar.getYearShengXiao())
# 大运
print("大运", bazi.getDaYun())
```
- 注意：`getEightChar()` 默认按节气排月柱，符合子平法。
- 真太阳时：若用户提供出生地，可先做时差校正再传时辰。

## 没有库时
- 年柱：查立春日期表
- 月柱：查十二节交接表
- 日柱：用蔡勒类公式或万年历核对
- 时柱：五鼠遁 "甲己还加甲，乙庚丙作初，丙辛从戊起，丁壬庚子居，戊癸何方发，壬子是真途"
- 排盘后一定先给用户核对，再解读。
