//
//  SOCManager.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 24/04/21.
//

import SwiftUI
import Combine

/// A manager class that presents a `SlideOverCard`overlay from anywhere in an app
internal class SOCManager<Content: View, Style: ShapeStyle>: ObservableObject {
    @ObservedObject var model: SOCModel
    
    var cardController: UIHostingController<SlideOverCard<Content, Style>>?
    
    var onDismiss: (() -> Void)?
    var content: () -> Content
    var window: UIWindow?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(model: SOCModel,
         onDismiss: (() -> Void)?,
         options: SOCOptions,
         style: SOCStyle<Style>,
         @ViewBuilder content: @escaping () -> Content) {
        self.onDismiss = onDismiss
        self.content = content
        
        self.model = model
        let rootCard = SlideOverCard(model: _model,
                                     options: options,
                                     style: style,
                                     content: content)
        
        cardController = UIHostingController(rootView: rootCard)
        cardController?.view.backgroundColor = .clear
        cardController?.modalPresentationStyle = .overFullScreen
        cardController?.modalTransitionStyle = .crossDissolve
    }
    
    /// Presents a `SlideOverCard`
    @available(iOSApplicationExtension, unavailable)
    func present() {
        
        guard !self.model.showCard else { return }

        if let cardController {
            var topViewController = window?.topViewController()

            if let topViewController {
                if topViewController.presentedViewController == nil {
                    topViewController.present(cardController, animated: false) {
                        self.model.showCard = true
                    }
                }
            } else {
                let windowScene = UIApplication.shared
                    .connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first(where: { $0.activationState == .foregroundActive })
                
                topViewController = windowScene?
                    .windows
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController
            }
        }
    }
    
    /// Dismisses a `SlideOverCard`
    @available(iOSApplicationExtension, unavailable)
    func dismiss() {
        onDismiss?()
        cardController?.dismiss(animated: true) {
            self.model.showCard = false
        }
    }
    
    func set(colorScheme: ColorScheme) {
        cardController?.overrideUserInterfaceStyle = colorScheme.uiKit
    }
    
    func set(window: UIWindow) {
        self.window = window
    }
}
