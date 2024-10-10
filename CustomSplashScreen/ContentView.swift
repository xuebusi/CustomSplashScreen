//
//  ContentView.swift
//  CustomSplashScreen
//
//  Created by shiyanjun on 2024/10/10.
//

import SwiftUI

/**
 2种App启动屏幕过渡动画效果：垂直翻页和水平3D翻转
 */
struct ContentView: View {
    @State private var showsSplashScreen: Bool = true
    var body: some View {
        ZStack {
            if showsSplashScreen {
                // 启动屏幕
                SplashScreen()
                    //.transition(CustomSplashTransition(isRoot: false))
                    .transition(CustomSplash3DTransition(isRoot: false))
            } else {
                // 主界面
                RootView()
                    //.transition(CustomSplashTransition(isRoot: true))
                    .transition(CustomSplash3DTransition(isRoot: true))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        /**
         在动画过渡时，会裁剪其边框，
         因此使用ignoreSafeArea修饰符可以避免这些问题，
         但使用此修饰符时，RootView视图的安全区域也会被忽略，
         但幸运的是，在使用TabView或NavigationStack时，
         我们根本不需要做任何事情，即使安全区域被忽略，
         但请记住，如果你的应用程序只包含一个计划视图或一个滚动视图，
         那么你可能需要在顶部和底部区域手动添加边距。
         */
        .ignoresSafeArea()
        .task {
            guard showsSplashScreen else { return }
            /**
             不要让跳转屏幕持续更长时间。我的建议是0.5到0.8秒最好。
             如果你持续更长时间，那么应用用户在使用App时体验会很不好。
             */
            try? await Task.sleep(for: .seconds(0.8))
            withAnimation(.smooth(duration: 0.55)) {
                showsSplashScreen = false
            }
        }
    }
    
    /**
     对于那些使用非标TabView/导航应用程序的用户，可以利用此功能来应用顶部和底部填充
     */
    var safeArea: UIEdgeInsets {
        if let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets {
            return safeArea
        }
        
        return .zero
    }
}

// 启动屏幕
struct SplashScreen: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.splashBackground)
            
            Image("Logo Icon")
        }
        .ignoresSafeArea()
    }
}

// 主界面
struct RootView: View {
    var body: some View {
        TabView {
            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            Text("Search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

// 垂直翻页动画过渡
struct CustomSplashTransition: Transition {
    var isRoot: Bool
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .offset(y: phase.isIdentity ? 0 : isRoot ? screenSize.height : -screenSize.height)
    }
    
    var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }
        
        return .zero
    }
}

// 水平3D翻转动画过渡
struct CustomSplash3DTransition: Transition {
    var isRoot: Bool
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .rotation3DEffect(
                .init(
                    degrees: phase.isIdentity ? 0 : isRoot ? 70 : -70
                ),
                axis: (
                    x: 0,
                    y: 1,
                    z: 0
                ),
                anchor: isRoot ? .leading : .trailing
            )
            .offset(x: phase.isIdentity ? 0 : isRoot ? screenSize.width : -screenSize.width)
    }
    
    var screenSize: CGSize {
        if let screenSize = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return screenSize
        }
        
        return .zero
    }
}

#Preview {
    ContentView()
}
