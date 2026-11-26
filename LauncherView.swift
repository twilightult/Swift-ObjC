import SwiftUI
import UniformTypeIdentifiers

/// 按宽高比自动切换竖屏 / 横屏布局。
struct LauncherView: View {
    @State private var showingImporter = false
    @State private var readyCount = 0

    var body: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                landscape
            } else {
                portrait
            }
        }
        .background(Palette.background.ignoresSafeArea())
    }

    // MARK: - 共用组件

    private var statusStrip: some View {
        HStack(spacing: 10) {
            Circle().fill(Color(hex: 0x7CC4A0)).frame(width: 9, height: 9)
            Text("1.20.1  ·  已就绪").font(.system(size: 14)).foregroundColor(Palette.ink)
            Spacer()
            Text("详情 ›").font(.system(size: 13)).foregroundColor(Palette.sub)
            glyph("gearshape")
        }
        .padding(.horizontal, 14).frame(height: 40)
        .background(Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Palette.line, lineWidth: 1.5))
    }

    private func glyph(_ name: String) -> some View {
        Circle().fill(Palette.surface).frame(width: 30, height: 30)
            .overlay(Circle().stroke(Palette.line, lineWidth: 1.5))
            .overlay(Image(systemName: name).font(.system(size: 13)).foregroundColor(Palette.sub))
    }

    private var brand: some View {
        HStack(spacing: 10) {
            Image("AppIcon").resizable().frame(width: 46, height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text("MC").font(.system(size: 25, weight: .heavy, design: .rounded))
                    .foregroundColor(Palette.ink)
                Text("SWIFT · OBJC").font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(Palette.sub)
            }
        }
    }

    /// 主视觉横幅：蓝紫渐变 + 大 R 水印 + 版本信息
    private func banner(height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Palette.banner
            GeometryReader { g in
                Text("R")
                    .font(.system(size: min(g.size.height, 300) * 0.95, weight: .bold, design: .serif))
                    .foregroundColor(.white.opacity(0.34))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 40)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("当前实例").font(.system(size: 14)).foregroundColor(Palette.sub)
                Text("超平坦世界").font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Palette.ink)
                Text("Minecraft 1.20.1  ·  Java 行为规范")
                    .font(.system(size: 14)).foregroundColor(Palette.ink.opacity(0.65))
                Spacer()
                Divider().background(.white).frame(width: 280)
                HStack(spacing: 20) {
                    Text("区块 1"); Text("Metal"); Text("AOT")
                }
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(Palette.ink.opacity(0.6))
            }
            .padding(24)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func infoCard(_ title: String, _ a: String, _ b: String, _ c: String, _ tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 9).fill(tint).frame(width: 34, height: 34)
            Text(title).font(.system(size: 17, weight: .semibold)).foregroundColor(Palette.ink)
                .padding(.top, 14)
            Divider().background(Palette.line).padding(.vertical, 12)
            Text(a).font(.system(size: 16, weight: .medium)).foregroundColor(Palette.ink)
            Text(b).font(.system(size: 12)).foregroundColor(Palette.sub).padding(.top, 6)
            Text(c).font(.system(size: 11, design: .monospaced)).foregroundColor(Palette.sub).padding(.top, 4)
            Spacer()
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Palette.line, lineWidth: 1.5))
    }

    private func launchButton(width: CGFloat? = nil) -> some View {
        Button { } label: {
            Text("启动游戏  →").font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: width ?? .infinity, minHeight: 50)
                .background(Palette.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var footStatus: some View {
        HStack {
            Text("Minecraft 1.20.1").font(.system(size: 11, design: .monospaced)).foregroundColor(Palette.sub)
            Spacer()
            Text("总时长 0s").font(.system(size: 11)).foregroundColor(Palette.sub)
        }
    }

    private func instanceRow(_ title: String, _ sub: String, _ tint: Color, _ selected: Bool) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 9).fill(tint).frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(Palette.ink)
                Text(sub).font(.system(size: 11)).foregroundColor(Palette.sub)
            }
            Spacer()
        }
        .padding(10)
        .background(selected ? Color(hex: 0xEEECFD) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) {
            if selected { RoundedRectangle(cornerRadius: 2).fill(Palette.accentTop).frame(width: 4, height: 34) }
        }
    }

    // MARK: - 横屏

    private var landscape: some View {
        HStack(spacing: 0) {
            // 左栏
            VStack(alignment: .leading, spacing: 0) {
                brand.padding(.top, 20)
                HStack {
                    Text("实例").font(.system(size: 17, weight: .semibold)).foregroundColor(Palette.ink)
                    Spacer()
                    Text("3 个").font(.system(size: 12)).foregroundColor(Palette.sub)
                }.padding(.top, 28).padding(.bottom, 10)
                instanceRow("超平坦", "1.20.1 · 已就绪", Palette.cardA, true)
                instanceRow("调试世界", "空 · 未创建", Palette.cardB, false)
                Button { showingImporter = true } label: {
                    instanceRow("导入目录", "文件 App", Palette.cardC, false)
                }.buttonStyle(.plain)

                Text("工具").font(.system(size: 17, weight: .semibold)).foregroundColor(Palette.ink)
                    .padding(.top, 26).padding(.bottom, 10)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                    ForEach(["资源", "激活", "日志", "设置"], id: \.self) { t in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 7).fill(Color(hex: 0xE9ECFC)).frame(width: 26, height: 26)
                            Text(t).font(.system(size: 13)).foregroundColor(Palette.ink)
                            Spacer()
                        }.padding(10)
                        .background(Palette.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 11))
                        .overlay(RoundedRectangle(cornerRadius: 11).stroke(Palette.line, lineWidth: 1.5))
                    }
                }
                Spacer()
                Divider().background(Palette.line)
                HStack(spacing: 10) {
                    Circle().fill(Palette.cardA).frame(width: 30, height: 30)
                        .overlay(Text("A").font(.system(size: 12, weight: .semibold)).foregroundColor(Palette.ink))
                    Text("本地账户").font(.system(size: 13)).foregroundColor(Palette.sub)
                }.padding(.vertical, 14)
            }
            .padding(.horizontal, 18)
            .frame(width: 300)
            .background(Color(hex: 0xFBFCFF))

            Rectangle().fill(Palette.line).frame(width: 1)

            // 右主区
            VStack(alignment: .leading, spacing: 0) {
                statusStrip.padding(.top, 18)
                banner(height: 240).padding(.top, 16)
                HStack(spacing: 14) {
                    infoCard("最近", "超平坦世界", "上次启动  —", "1.20.1", Palette.cardA)
                    infoCard("资源", "929 张 PNG", "16×16 原生", "文件 App 导入", Palette.cardB)
                    infoCard("激活", "当前版本", "1.20.1", "票仅内存", Palette.cardC)
                }
                .frame(height: 210).padding(.top, 18)
                Spacer()
                Divider().background(Palette.line)
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Minecraft 1.20.1").font(.system(size: 11, design: .monospaced)).foregroundColor(Palette.sub)
                        Text("总时长 0s").font(.system(size: 11)).foregroundColor(Palette.sub)
                    }
                    Spacer()
                    launchButton(width: 260)
                }.padding(.vertical, 14)
            }
            .padding(.horizontal, 26)
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.folder],
                      allowsMultipleSelection: false) { result in
            if case .success(let urls) = result, let dir = urls.first {
                readyCount = (try? AssetImporter.pngs(in: dir).count) ?? 0
            }
        }
    }

    // MARK: - 竖屏（保留）

    private var portrait: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack { brand; Spacer(); glyph("gearshape") }.padding(.top, 12)
                    statusStrip.padding(.top, 14)
                    banner(height: 210).padding(.top, 14)
                    Text("实例").font(.system(size: 17, weight: .semibold)).foregroundColor(Palette.ink)
                        .padding(.top, 20).padding(.bottom, 10)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach([("超平坦","1.20.1 · 已就绪",Palette.cardA),
                                 ("调试世界","空 · 未创建",Palette.cardB),
                                 ("导入目录","文件 App",Palette.cardC)], id: \.0) { t, s, c in
                            Button { showingImporter = true } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    RoundedRectangle(cornerRadius: 9).fill(c).frame(width: 34, height: 34)
                                    Text(t).font(.system(size: 13, weight: .medium)).foregroundColor(Palette.ink)
                                    Text(s).font(.system(size: 10)).foregroundColor(Palette.sub)
                                }.padding(11).frame(maxWidth: .infinity, alignment: .leading)
                                .background(Palette.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                                .overlay(RoundedRectangle(cornerRadius: 13).stroke(Palette.line, lineWidth: 1.5))
                            }.buttonStyle(.plain)
                        }
                    }
                    Text("工具").font(.system(size: 17, weight: .semibold)).foregroundColor(Palette.ink)
                        .padding(.top, 20).padding(.bottom, 10)
                    HStack(spacing: 10) {
                        ForEach(["资源", "激活", "日志", "设置"], id: \.self) { t in
                            VStack(alignment: .leading, spacing: 7) {
                                RoundedRectangle(cornerRadius: 7).fill(Color(hex: 0xE9ECFC)).frame(width: 26, height: 26)
                                Text(t).font(.system(size: 12)).foregroundColor(Palette.ink)
                            }.padding(9).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Palette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 11))
                            .overlay(RoundedRectangle(cornerRadius: 11).stroke(Palette.line, lineWidth: 1.5))
                        }
                    }
                    Divider().background(Palette.line).padding(.top, 20)
                    Text("最近").font(.system(size: 12)).foregroundColor(Palette.sub).padding(.top, 8)
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("超平坦世界").font(.system(size: 14)).foregroundColor(Palette.ink)
                            Text("上次启动  —").font(.system(size: 11)).foregroundColor(Palette.sub)
                        }
                        Spacer()
                        Text("1.20.1").font(.system(size: 11, design: .monospaced)).foregroundColor(Palette.sub)
                    }
                    Spacer().frame(height: 220)
                }.padding(.horizontal, 18)
            }
            VStack(spacing: 10) {
                HStack {
                    ForEach(["＋ 新建", "资源", "设置", "账户"], id: \.self) { t in
                        Text(t).font(.system(size: 12)).foregroundColor(Palette.sub)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                launchButton()
                Divider().background(Palette.line)
                footStatus
            }
            .padding(.horizontal, 18).padding(.top, 10).padding(.bottom, 8)
            .background(Color(hex: 0xFAFCFF))
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.folder],
                      allowsMultipleSelection: false) { result in
            if case .success(let urls) = result, let dir = urls.first {
                readyCount = (try? AssetImporter.pngs(in: dir).count) ?? 0
            }
        }
    }
}

struct LauncherView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LauncherView().previewDisplayName("Portrait")
            LauncherView()
                .frame(width: 844, height: 390)
                .previewDisplayName("Landscape")
        }
    }
}
