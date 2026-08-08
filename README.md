# 喜神 · 八字暖读

> **Xi Shen · Bazi Warm Reading** — a universal agent skill that installs on any runtime.

> 从你的八字里挖出亮点，让你更爱自己、更愿意向前。
> **希望，是这个世界上最珍贵的东西。**

> Dig the strongest light out of your birth chart — so you love yourself more and are more willing to move forward. Hope is the most precious thing in this world.

---

## 它是什么 · What It Is

`xishen` 是一个**通用 agent skill**，一个乐观向的八字命理 skill。不吓人、不算丧，只做一件事：把命局里好的、强的、属于你的光打在你身上，再轻轻指一下往前走的那一步。输入生辰，它基于古籍框架做四柱排盘与命理解读，但真正的使命只有一个——**情绪价值**：

- 先挖亮点：你本命里强的是什么、禀赋是什么、哪步运在帮你
- 让你更爱自己：把日主、十神、格局里正向的一面讲透
- 更愿意向前：把“冲克 / 偏弱 / 犯忌”翻译成可发力点、可调和处、可化解的法子
- 留下希望：结尾一句温暖的话，让希望感留得住

算完的感觉应该是“被点亮”，不是“被吓住”。

**不依赖任何特定工具。** 本仓库就是一个标准 skill 文件夹（根目录含 `SKILL.md`），可在任意支持 agent skills 的运行环境安装——Claude Code / OpenCode / Codex / Gemini CLI / Cursor / WorkBuddy 等。装好之后，在对话里说一句生辰就能触发。

`xishen` is a **universal agent skill** — an upbeat bazi (八字) fortune-telling skill. It doesn't scare you, doesn't bring you down; it does one thing only: put the light that is good, strong, and yours in your chart on you, then gently point at the step forward. Give it a birth date and it builds a four-pillar reading grounded in the classical texts — but its real mission is emotional value:

- Find the light first: what is strong in your chart, what gifts you were born with, which luck period is on your side
- Help you love yourself more: the positive side of your day master, ten gods, and chart structure, explained clearly
- Make you want to move forward: translate "clashes / weakness / taboos" into leverage points, things to harmonize, and concrete next steps
- Leave you with hope: a warm closing line that stays with you

The feeling after a reading should be "lit up", not "scared".

It is **not tied to any specific tool**. This repo is a standard skill folder (SKILL.md at its root) that installs into any runtime that supports agent skills — Claude Code, OpenCode, Codex, Gemini CLI, Cursor, WorkBuddy, and more. Once installed, just tell it your birth date in the chat and it triggers.

---

## 支持的环境 · Supported Runtimes

把 `xishen` 文件夹放进下表对应目录即可（或直接用安装脚本，见下文）。本 skill 不依赖任何特定产品。

| 运行环境 Runtime | Skills 目录 Skills directory |
|---|---|
| Claude Code | `~/.claude/skills/` |
| OpenCode | `~/.config/opencode/skills/` |
| Codex / Copilot / Gemini CLI（跨工具通用） | `~/.agents/skills/` |
| Codex CLI | `~/.codex/skills/` |
| Gemini CLI | `~/.gemini/skills/` |
| Cursor | `~/.cursor/skills/` |
| WorkBuddy | `~/.workbuddy/skills/` |
| 任意目录 Any folder | `--target <目录>`（或手动拷进任何 skills 目录） |

Drop the `xishen` folder into any directory from the table below — or let the installer do it for you (see below). The skill is not tied to any one product.

---

## 安装 · Install

**一键安装（macOS / Linux / Git Bash on Windows）· One-line install (macOS / Linux / Git Bash on Windows):**

```bash
curl -fsSL https://raw.githubusercontent.com/gengyueworks/xishen/main/install.sh | bash
```

- `./install.sh --all` 自动装进所有检测到的环境；也可指定 `--claude` / `--opencode` / `--codex` / `--gemini` / `--cursor` / `--workbuddy` / `--agents` / `--target <目录>`
- `--link` 用符号链接安装（开发模式，改仓库即生效）；`--dry-run` 先预览不做改动；`--name <名字>` 自定义安装后的文件夹名（默认 `xishen`）

`./install.sh --all` auto-detects every runtime on your machine and installs into each one. You can also pick targets explicitly with `--claude` / `--opencode` / `--codex` / `--gemini` / `--cursor` / `--workbuddy` / `--agents` / `--target <dir>`. `--link` installs as a symlink (dev mode — repo edits apply instantly), `--dry-run` previews the targets without changing anything, and `--name <name>` sets the installed folder name (default `xishen`).

**Windows（原生 PowerShell）· Windows (native PowerShell):** 下载本仓库后，在仓库目录里运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -All
```

同样支持 `-Claude` `-OpenCode` `-Codex` `-Gemini` `-Cursor` `-WorkBuddy` `-Agents` `-Target <目录>` `-Link` `-DryRun` `-Name <名字>`。

The same flags are supported: `-Claude` `-OpenCode` `-Codex` `-Gemini` `-Cursor` `-WorkBuddy` `-Agents` `-Target <dir>` `-Link` `-DryRun` `-Name <name>`.

**手动安装（任何环境）· Manual install (any environment):** 把整个文件夹拷进上表对应目录即可。本仓库本身就是一个标准 skill 文件夹（根目录含 `SKILL.md`），拷过去即生效：

```bash
mkdir -p ~/.claude/skills && cp -R xishen ~/.claude/skills/
```

Just copy this folder into the matching skills directory from the table above. The repo itself is a standard skill folder, so copying it is all it takes.

**触发示例 · Trigger example:** 装好后，在对话里说：

> 算我八字：公历 1995 年 8 月 12 日 14 时 30 分，女

即可触发。英文环境的完整触发词见 `SKILL.md`。

Once installed, just say something like "算我八字：公历 1995 年 8 月 12 日 14 时 30 分，女" (read my bazi: solar calendar 1995-08-12, 14:30, female) in the chat. The full trigger words for English are in `SKILL.md`.

---

## 它靠什么“准一点” · Why It Reads Fairly Accurately

分析严格参考五部古籍框架，不凭空编造：

- 《渊海子平》——四柱八字、十神、格局之源
- 《子平真诠》——格局论命、用神取舍
- 《滴天髓》——日主强弱、五行生克、调候
- 《三命通会》——万法汇综
- 《玉照定真经》——断语与取象

排盘规则：年柱以立春为界，月柱以节气为界，日柱按实际历法，时柱按五鼠遁并校真太阳时。需要精确排盘时参考 `references/calc.md`（用 `lunar_python` 库）。

想让结果更贴你认可的“准”，把曾做过的、觉得靠谱的八字 / 星盘解读（可脱敏）放进 `references/calibration-samples/`，分析时会向那个颗粒度靠拢。

Every analysis is anchored in five classical texts — nothing is made up:

- 《渊海子平》(Yuanhai Ziping) — the source of the four pillars, the ten gods, and chart structure
- 《子平真诠》(Ziping Zhenquan) — structure-based reading and selecting the useful god
- 《滴天髓》(Di Tian Sui) — day-master strength, five-element interactions, climate adjustment
- 《三命通会》(Sanming Tonghui) — the great synthesis of methods
- 《玉照定真经》(Yuzhao Dingzhen Jing) — concrete judgments and imagery

Chart rules: the year pillar changes at Lichun (立春), the month pillar at the solar terms, the day pillar follows the actual calendar, and the hour pillar uses the five-rat method (五鼠遁) plus true solar time correction. For precise charts, see `references/calc.md` (uses the `lunar_python` library).

To make results feel closer to the "accurate" you trust, drop bazi or star-chart readings you consider reliable into `references/calibration-samples/` (anonymized is fine), and future analyses will move toward that level of granularity.

---

## 目录结构 · Structure

```
xishen/
├── SKILL.md                      # skill 主体（中英双语：触发词 + 方法论 + 输出结构）
├── README.md                     # 本文件（中英双语）
├── install.sh                    # 通用安装脚本（macOS / Linux / Git Bash）
├── install.ps1                   # Windows PowerShell 安装脚本
└── references/
    ├── classics.md               # 十神 / 强弱 / 用神 / 大运 关键概念速查
    ├── calc.md                   # 精确排盘（lunar_python）
    └── calibration-samples/      # 校准样本（可选）
```

---

## 校准样本 · Calibration Samples

把你认为“比较准”的八字 / 星盘解读贴到 `references/calibration-samples/`，可脱敏（去掉真实姓名，保留生辰与结论）。分析时参考其**颗粒度与风格**，向“细致”靠拢——据用户经验，DeepSeek 等模型测的与网上收费的相差不大，差别主要在谁更细。有样本就能更快贴近你认可的“准”。

Drop bazi or star-chart readings you consider "fairly accurate" into `references/calibration-samples/` — anonymized is fine (remove real names, keep the birth data and conclusions). The skill references their granularity and style during analysis and aims for that level of detail. In our experience, what DeepSeek-class models produce is close to what paid online readers give; the difference is mostly who goes deeper. Samples help it match the accuracy you trust, faster.

---

## 边界 · Boundaries

- 娱乐向，仅供参考；重大决策自己拿主意。
- 不替代医疗 / 财务 / 法律建议。
- 只给愿意给的数据即可，注意保护隐私。

- Entertainment-oriented, for reference only; make major decisions yourself.
- Not a substitute for medical / financial / legal advice.
- Only share what you are comfortable with; mind your privacy.
