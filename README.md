# MC · 启动器

未越狱 iOS 上、零 JIT / 零 WebView / 全 AOT 的行为规范兼容客户端。Swift · ObjC。

公开仓只放壳：启动器界面、导入口、原创蓝紫浅变色视觉。引擎源码与 CI 在私有仓；`block/*.png` 等资源由用户本机导入，不进任何仓库。

## 目录

```
repo-root/
├─ .gitignore
├─ README.md
├─ Palette.swift          蓝紫低饱和渐变配色
├─ AssetImporter.swift    Data 原样读，不重编码
├─ LauncherView.swift     按宽高比自动切换竖屏 / 横屏
├─ AppIcon.png            1024 蓝紫渐变 + 衬线 R
└─ LauncherPreview.png    横屏界面预览
```

All files sit flat at repo root. No subdirectories needed: add the three
.swift files and the two .png files to the Xcode target directly, or use
`sources: [.]` in project.yml.

## 视觉

蓝紫低饱和「浅变色」：底色近白，横幅与主按钮从蓝过渡到紫。图标为蓝紫渐变底 + Playfair Display 衬线大写 R，界面横幅沿用同一 R 作低透明水印。布局参照桌面启动器：横屏为「左侧栏（实例 / 工具 / 账户）+ 右侧主区（状态条 / 横幅 / 信息卡 / 启动按钮）」，竖屏保留分组网格与底部固定栏，由 `GeometryReader` 按宽高比自动切换。

## 构建

- 引擎在私有仓用 macOS runner（XcodeGen + `xcodebuild`）导出 IPA，CI 不 checkout 资源目录
- 导出后本地签一次
- 验收使用未越狱机
- 文件 App 把本机 16×16 PNG 目录拖入沙盒 → 导入口读入 → 第一帧草方块
