# GMInject — 上传 GitHub 一次编译出 dylib + deb

## 最省事流程（就两步）

**第 1 步：上传**
- 已装 Git 的话：右键 `push-to-github.ps1` → 「使用 PowerShell 运行」，按提示填你的空仓库地址
- 或手动（在 `upload-github-dylib` 文件夹里）：
  ```bash
  git init
  git add -A
  git commit -m "GMInject dylib"
  git branch -M main
  git remote add origin https://github.com/<你>/<新空仓库>.git
  git push -u origin main
  ```
- 仓库设 **Public**

**第 2 步：编译**
- GitHub → Actions → `build-dylib` → **Run workflow** → runner 选 `macos-13` → Run
- 1–2 分钟后在 Artifacts 下载：
  - `GMInject.dylib`（必定产出）
  - `GMInject.deb`（附带，iOS 16 rootless，deb 打包失败不影响 dylib）

## 文件说明
| 文件 | 作用 |
|---|---|
| `GMInject.m` | dylib 源码（IL2CPP 反射注入，配置驱动） |
| `gm_offsets.h` | 占位头（反射模式用不到真实偏移） |
| `build.sh` | 编译脚本（arm64+arm64e，ad-hoc 签名） |
| `Makefile` | 本地构建入口 |
| `.github/workflows/build-dylib.yml` | **编译 + 打 deb 一体化（隐藏目录，别漏传）** |
| `GMConfig.json` | 只加检阅车模型 x99（测试） |
| `GMConfig_数值验证.json` | 数值全加，先验证注入链路用 |
| `GMInject.plist` | 越狱注入 filter |
| `push-to-github.ps1` | 一键上传脚本 |

## 卡在 "Starting job" 怎么办
这是 GitHub 的 macOS 构建机**排队**，不是配置问题：
- 取消当前 run → 重新 Run workflow → **换 runner 标签**（macos-14 / macos-15 / macos-latest）
- `Settings → Billing` 查 Actions 分钟数是否耗尽
- 错峰跑（夜里/周末更容易分到机器）
- 实在等不到就借台 Mac，`bash build.sh` 1 分钟出 dylib，不用 GitHub

## 拿到产物后
1. **先验证链路**：`GMConfig_数值验证.json` 改名 `GMConfig.json` 放进 app 沙盒 `Documents/`，冷启动
   - 日志 `Documents/GMInject.log` 出现 `AddCoin -> OK`、游戏里蓝钻变 9.99 亿 = 链路通
2. **再刷检阅车**：换回 `GMConfig.json`，冷启动，`[0] AddItem -> OK` 后背包多检阅车模型
3. 注入方式：
   - 越狱：`GMInject.dylib` + `GMInject.plist` 放 `/Library/MobileSubstrate/DynamicLibraries/`（iOS 16 rootless 自动映射 `/var/jb/...`）
   - TrollStore：用 `inject_ipa.py` 给游戏 Mach-O 加 `@executable_path/Frameworks/GMInject.dylib`
