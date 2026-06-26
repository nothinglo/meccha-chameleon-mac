# 在 Mac 上免費玩 Windows 限定的 Steam 遊戲 🦎 / Play Windows-only Steam games on Mac for free

**🌏 語言 / Language：[繁體中文](#繁體中文) ・ [English](#english)**

以 **MECCHA CHAMELEON**（躲貓貓）為範例，但方法適用於大多數 Steam 上的 Windows 遊戲。
Uses **MECCHA CHAMELEON** as the worked example, but the method works for most Windows games on Steam.

---

<a name="繁體中文"></a>
# 繁體中文

在 **Apple Silicon Mac（M 系列）** 上，用**完全免費**的工具跑 Windows 限定的 Steam 遊戲——不用買 CrossOver、不用虛擬機，靠 [Sikarugir](https://github.com/Sikarugir-App)（Wine + 原生 Metal/DXMT）就能讓 **3D 完整渲染**。

## ⚠️ 先確認適用範圍（很重要）

| | 說明 |
|---|---|
| ✅ 適合 | 大多數單機 / 一般多人的 Windows Steam 遊戲（DirectX 11 / 12）|
| ❌ 不適合 | 有**反作弊**的遊戲（EAC、BattlEye 等基本上跑不了）|
| ⚠️ 注意 | 每款遊戲的相容性、效能、設定（尤其**啟動參數**）可能不同，需要個別微調 |

> 這不是保證每款都能跑的魔法，而是一套「值得一試」的通用方法。MECCHA CHAMELEON 是已驗證可行的範例。

## 環境需求
- Apple Silicon Mac（M1/M2/M3/M4/M5…）
- 較新的 macOS
- 數 GB 可用空間（每款遊戲另計）

## 步驟 1️⃣：一鍵安裝環境（Rosetta + Homebrew + Sikarugir）
打開「**終端機**（Terminal）」，貼上：
```bash
curl -fsSL https://raw.githubusercontent.com/nothinglo/meccha-chameleon-mac/main/setup.sh -o setup.sh
bash setup.sh
```
- 過程會要你**按 Return、輸入開機密碼**（安裝 Homebrew 用），都是正常現象。
- 腳本只安裝工具（Rosetta 2 / Homebrew / Sikarugir Creator），**不會碰你的個人檔案**，可重複執行。
- 不放心可以先打開 [`setup.sh`](setup.sh) 看內容。

> 已經有 Homebrew 的人，腳本會自動跳過、只補裝缺的部分。

## 步驟 2️⃣：建立遊戲 wrapper
打開「**Sikarugir Creator**」（在啟動台 / `~/Applications`）：
1. 按 **Download Template**
2. 按 **Change** 選引擎 → **務必選 `WS12WineSikarugir10.0`**（Wine 10）
3. 按 **Create** → 命名（例如遊戲名）

> ⚠️ **引擎一定要選 Wine 10**。舊版（如 GPTK 的 Wine 7.7）跑不動現在的 Steam 登入介面。

![建立 wrapper](screenshots/01-create.png)

## 步驟 3️⃣：啟用 DXMT（畫面關鍵！）
建立後會跳出 **Configure** 視窗 → 勾選 **「DirectX to Metal translation layer — (DXMT)」**

> ⚠️ **一定要用 DXMT，不要用 DXVK**。DXVK 走 MoltenVK，許多 UE 遊戲的 3D 主畫面會**全黑**（只剩選單）；DXMT 是原生 Metal，才能完整渲染。

![勾選 DXMT](screenshots/02-dxmt.png)

## 步驟 4️⃣：安裝 Steam
1. 到 [store.steampowered.com](https://store.steampowered.com/about/) 下載 `SteamSetup.exe`
2. 在 Configure 視窗按 **Install Software** → 選那個 `SteamSetup.exe` → 裝進 wrapper

## 步驟 5️⃣：登入 Steam、安裝遊戲
1. 把「**Windows app**」欄位設成 Steam.exe（或用 Browse 找到它）
2. 按 **Test Run** → Steam 開啟
3. **登入** → 在媒體庫**安裝你的遊戲**

![Steam 登入](screenshots/03-steam.png)

## 步驟 6️⃣：設定啟動參數（視遊戲而定）
有些遊戲的「啟動器」會擋你（例如跳出「需要 Visual C++」之類的錯誤）。解法是讓 Steam **直接啟動遊戲本體**，跳過啟動器：

遊戲上 **右鍵 → 內容（Properties）→ 啟動選項（Launch Options）**，填入指向該遊戲 **Shipping/主執行檔** 的路徑，例如 MECCHA CHAMELEON：
```
"C:\Program Files (x86)\Steam\steamapps\common\MECCHA CHAMELEON\Chameleon\Binaries\Win64\PenguinHotel-Win64-Shipping.exe" %command%
```
> 路徑依遊戲不同，請到 `steamapps\common\<遊戲>\...\Binaries\Win64\` 找到真正的 `*-Shipping.exe`。不是每款都需要這步——先直接玩，遇到啟動器擋人再設。

## 步驟 7️⃣：開玩 🎉
從 **Steam 按 Play** 啟動遊戲。
> ⚠️ **務必從 Steam 啟動**。直接跑 exe 會出現 `invalid or missing authentication token`（Steam 沒在跑、拿不到授權）。

![遊戲畫面](screenshots/04-ingame.png)

**以後要玩**：點兩下 wrapper 的 `.app`（在 `~/Applications/Sikarugir/`）→ Steam → Play。

## 🛠 疑難排解 FAQ
| 問題 | 解法 |
|---|---|
| 點 wrapper 沒反應 | 先到「活動監視器」關掉殘留的 `steam` / `wine` 程序再開 |
| 3D 主畫面全黑、只剩選單/HUD | 你用到 DXVK 了 → 改用 **DXMT** |
| `invalid / missing authentication token` | 一定要**從 Steam 按 Play** 啟動，不能直接跑 exe |
| 跳「需要 Visual C++ / 找不到元件」 | 用步驟 6 的**啟動參數**直接指向 Shipping exe |
| 遊戲內中文變 □□ | 進階：在 wrapper 裡做字型替換 |
| 反作弊遊戲打不開 | 目前無解（EAC/BattlEye 跑不了）|

---

<a name="english"></a>
# English

Run Windows-only Steam games on an **Apple Silicon Mac (M-series)** with **100% free** tools — no CrossOver, no virtual machine. Using [Sikarugir](https://github.com/Sikarugir-App) (Wine + native Metal / DXMT), you get **full 3D rendering**.

## ⚠️ Scope first (important)

| | Notes |
|---|---|
| ✅ Works for | Most single-player / casual-multiplayer Windows Steam games (DirectX 11 / 12) |
| ❌ Won't work | Games with **anti-cheat** (EAC, BattlEye, etc. generally won't run) |
| ⚠️ Note | Each game's compatibility, performance, and settings (especially **launch options**) can differ and may need tweaking |

> This isn't magic that runs every game — it's a solid "worth a try" method. MECCHA CHAMELEON is a verified working example.

## Requirements
- Apple Silicon Mac (M1/M2/M3/M4/M5…)
- A recent macOS
- A few GB free (plus space per game)

## Step 1️⃣: One-shot environment setup (Rosetta + Homebrew + Sikarugir)
Open **Terminal** and paste:
```bash
curl -fsSL https://raw.githubusercontent.com/nothinglo/meccha-chameleon-mac/main/setup.sh -o setup.sh
bash setup.sh
```
- It will ask you to press Return and enter your login password (for installing Homebrew) — that's normal.
- The script only installs tools (Rosetta 2 / Homebrew / Sikarugir Creator); it **does not touch your personal files** and is safe to re-run.
- Feel free to read [`setup.sh`](setup.sh) first.

> If you already have Homebrew, the script skips it and only installs what's missing.

## Step 2️⃣: Create the game wrapper
Open **Sikarugir Creator** (Launchpad / `~/Applications`):
1. Click **Download Template**
2. Click **Change** to pick an engine → **be sure to choose `WS12WineSikarugir10.0`** (Wine 10)
3. Click **Create** → name it (e.g. the game's name)

> ⚠️ **You must pick Wine 10.** Older engines (e.g. GPTK's Wine 7.7) can't run the current Steam login UI.

![Create wrapper](screenshots/01-create.png)

## Step 3️⃣: Enable DXMT (the key to graphics!)
After creating, a **Configure** window opens → tick
**"DirectX to Metal translation layer — (DXMT)"**

> ⚠️ **Use DXMT, NOT DXVK.** DXVK goes through MoltenVK and many Unreal Engine games render a **black** 3D scene (only the menu shows). DXMT is native Metal and renders correctly.

![Enable DXMT](screenshots/02-dxmt.png)

## Step 4️⃣: Install Steam
1. Download `SteamSetup.exe` from [store.steampowered.com](https://store.steampowered.com/about/)
2. In the Configure window click **Install Software** → choose that `SteamSetup.exe` → install Steam into the wrapper

## Step 5️⃣: Log in to Steam, install the game
1. Set the **Windows app** field to Steam.exe (or use Browse)
2. Click **Test Run** → Steam opens
3. **Log in** → install **your game** from the library

![Steam login](screenshots/03-steam.png)

## Step 6️⃣: Set launch options (game-dependent)
Some games have a launcher that blocks you (e.g. a "Visual C++ required" error). The fix is to make Steam **launch the game's main executable directly**, skipping the launcher:

Right-click the game → **Properties → Launch Options**, and point it at the game's **Shipping/main exe**, e.g. for MECCHA CHAMELEON:
```
"C:\Program Files (x86)\Steam\steamapps\common\MECCHA CHAMELEON\Chameleon\Binaries\Win64\PenguinHotel-Win64-Shipping.exe" %command%
```
> The path differs per game — look under `steamapps\common\<game>\...\Binaries\Win64\` for the real `*-Shipping.exe`. Not every game needs this — try playing first, set it only if a launcher blocks you.

## Step 7️⃣: Play 🎉
Launch the game with **Play in Steam**.
> ⚠️ **Always launch from Steam.** Running the exe directly gives `invalid or missing authentication token` (Steam isn't running, no auth).

![In game](screenshots/04-ingame.png)

**To play later:** double-click the wrapper `.app` (in `~/Applications/Sikarugir/`) → Steam → Play.

## 🛠 Troubleshooting FAQ
| Problem | Fix |
|---|---|
| Wrapper does nothing when opened | Quit leftover `steam` / `wine` processes in Activity Monitor, then reopen |
| 3D scene is black, only menu/HUD shows | You're on DXVK → switch to **DXMT** |
| `invalid / missing authentication token` | Launch from **Steam → Play**, not the exe directly |
| "Visual C++ required / missing component" | Use the **launch option** in Step 6 to point at the Shipping exe |
| In-game CJK text shows as □□ | Advanced: do font substitution inside the wrapper |
| Anti-cheat game won't launch | No fix (EAC/BattlEye don't work) |

---

## 致謝 / Credits
- [Sikarugir](https://github.com/Sikarugir-App) — Wineskin/Kegworks successor, provides the Wine + DXMT engine
- [DXMT](https://github.com/3Shain/dxmt) — DirectX → Metal translation layer
- Wine / Homebrew / Apple Game Porting Toolkit

> 教學整理自實際在 M 系列 Mac 上跑起 MECCHA CHAMELEON 的完整過程。歡迎用 Issue 回報你成功/失敗的遊戲，一起累積相容性清單！
> Based on actually getting MECCHA CHAMELEON running on an M-series Mac. Please open an Issue to report games that work/fail and help build a compatibility list!
