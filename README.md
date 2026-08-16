# ShiftFocusRemake

 Shift+左键 即可将鼠标指向的单位设为焦点，并可选同时打上团队标记。

Set your focus on mouseover units with **Shift + Left Click**, optionally applying a raid marker at the same time. 

> 本插件 Fork 自 [ShiftFocus](https://www.curseforge.com/wow/addons/shiftfocus/)（作者：誓小言），因原插件需要适配新版本、修复 Bug 及新增功能而制作此 Remake 版本。
>
> This addon is forked from [ShiftFocus](https://www.curseforge.com/wow/addons/shiftfocus/) (by 誓小言). This Remake exists to update it for current game versions, fix bugs, and add new features.

> **声明**：本插件仅用于满足作者个人自用需求，功能与更新节奏以自身需求为准。他人可自行取用，但不提供任何保证或支持，使用风险与责任自负。
>
> **Disclaimer**: This addon is built solely for the author's personal use; features and updates follow the author's own needs. Anyone may use it, but it comes with no warranty or support — use at your own risk.

## 功能 Features

- 鼠标指向任意单位框体或姓名版，按组合键即可设置焦点，无需选中目标
- Hover over any unit frame or nameplate and press your hotkey to set focus — no targeting needed
- 支持暴雪原生框体、姓名版，以及 UUF、DandersFrames、Enhance Qol、EllesmereUI 等主流单位框体插件
- Works with Blizzard default frames and nameplates, plus popular unit frame addons: UUF, DandersFrames, Enhance Qol, EllesmereUI
- 设置焦点的同时自动施加团队标记（可选），仅在世界/团本以外的5人副本生效；支持"不覆盖已有标记"模式（`/tm ~`）
- Optionally apply a raid marker while focusing, only active in 5-player dungeons (not world/raids); includes a "don't overwrite existing markers" mode (`/tm ~`)
- 鼠标指向空白处按下组合键时清除焦点（恒定生效，无需设置）
- Clear your focus when pressing the hotkey with no unit under the cursor (always on, no setup needed)
- 进入5人副本后，若已启用标记，自动在小队通告："我焦点{符号}并打断"（默认启用，仅5人本生效）；在设置中启用标记或切换标记时也会立即通告
- When entering a 5-player dungeon with marking enabled, automatically announce "I'll focus {marker} and interrupt" in party chat (enabled by default, dungeons only); also announces immediately when enabling marking or changing the marker in settings
- 组合键完全可自定义：修饰键（Shift / Alt / Ctrl）× 鼠标按键（左 / 右 / 中 / 侧4 / 侧5）
- Fully customizable hotkey: modifier (Shift / Alt / Ctrl) × mouse button (left / right / middle / button 4 / button 5)

> **注意：本插件不会在小队/团队框架上注册焦点动作**，因为 12.x 起暴雪自带的“点击施法”系统会与小队/团队框架上的自定义鼠标绑定冲突。若需要在队友框架上快速设置焦点，请使用暴雪默认点击施法或相关单位框体插件的自带功能。
>
> **Note: This addon does not register focus actions on party/raid frames**, because the built-in Click-Cast system since 12.x conflicts with custom mouse bindings on party/raid frames. Use Blizzard's default click-cast or your unit frame addon's own feature to set focus on party/raid frames.

## 游戏内使用 In-Game Usage

- 默认操作：**Shift + 左键** 点击任意单位框体或姓名版
- Default: **Shift + Left Click** on any unit frame or nameplate
- 设置面板:`ESC` → 选项 → 插件 → ShiftFocusRemake
- Options: `ESC` → Game Options → AddOns → ShiftFocusRemake
