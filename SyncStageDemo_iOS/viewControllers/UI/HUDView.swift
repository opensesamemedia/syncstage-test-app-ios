//
//  HUDView.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 08/11/2022.
//

import UIKit

class HUDView: UIView {
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    private let view = UIView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        activityIndicatorView.color = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        if activityIndicatorView.superview == nil {
            addSubview(view)
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: 100).isActive = true
            view.heightAnchor.constraint(equalToConstant: 100).isActive = true
            view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            view.layer.cornerRadius = 10
            
            view.addSubview(activityIndicatorView)
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            activityIndicatorView.startAnimating()
        }
    }

    func hide() {
        self.removeFromSuperview()
    }

    static func show(view: UIView) -> HUDView {
        let hudView = HUDView()
        // view.addSubview(hudView)
        
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            window.addSubview(hudView)
            let screenSize = UIScreen.main.bounds.size
            hudView.translatesAutoresizingMaskIntoConstraints = false
            hudView.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
            hudView.heightAnchor.constraint(equalToConstant: screenSize.height).isActive = true
            hudView.centerXAnchor.constraint(equalTo: window.centerXAnchor).isActive = true
            hudView.centerYAnchor.constraint(equalTo: window.centerYAnchor).isActive = true
        }
        return hudView
    }
}
