//
//  ModalController.swift
//  SetsViews
//
//  Created by Myron on 2017/6/1.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Extension SubModal Function

extension ModalView {
    
    /**
     Create a ModalView_TableView
     */
    class func table(_ text: String) -> ModalView_TableView {
        let table = ModalView_TableView()
        table.title_label.text = text
        return table
    }
    
    /**
     Create a ModalView_Slider
     */
    class func slider(_ text: String) -> ModalView_Slider {
        let table = ModalView_Slider()
        table.title_label.text = text
        return table
    }
    
}

// MARK: - Modal View

/**
 A Modal View imitate the alter controller.
 */
class ModalView: UIView {

    // MARK: - Init
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        deploy()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func deploy() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientation),
            name: .UIApplicationDidChangeStatusBarOrientation,
            object: nil
        )
        
        backgroundColor = UIColor.black.withAlphaComponent(0.1)
        addSubview(back_view)
        
        // Label
        back_view.addSubview(title_label)
        back_view.layer.shadowOpacity = 1
        back_view.layer.shadowOffset = CGSize(width: 0, height: 0)
        back_view.layer.shadowRadius = 1
        
        // Center
        back_view.addSubview(content_view)
        
        // cancel and sure
        back_view.addSubview(cancel_button)
        cancel_button.addTarget(
            self,
            action: #selector(cancel_action(_:)),
            for: .touchUpInside
        )
        back_view.addSubview(sure_button)
        sure_button.addTarget(
            self,
            action: #selector(sure_action(_:)),
            for: .touchUpInside
        )
        
        // lines
        back_view.addSubview(line_view_1)
        back_view.addSubview(line_view_2)
        
    }
    
    // MARK: Orientation
    
    @objc func orientation() {
        DispatchQueue.main.async { [weak self] in
            if let view = self?.superview {
                UIView.animate(withDuration: 0.25, animations: {
                    self?.frame = view.bounds
                    self?.update_subViews_size()
                })
            }
        }
    }
    
    // MARK: - Values
    
    var size_content_height: CGFloat = 0
    var size_width: CGFloat = 270
    
    var value: Any?
    var action: ((ModalView, Any?) -> Void)?
    
    // MARK: - SubViews
    
    var back_view: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 14
        return view
    }()
    
    var title_label: UILabel = {
        let label = UILabel()
        label.text = "Test Title"
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 4)
        label.textAlignment = .center
        return label
    }()
    
    var content_view: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        return view
    }()
    
    var cancel_button: UIButton = {
        let button = UIButton()
        button.setTitle(
            NSLocalizedString("Cancel", comment: "Cancel"),
            for: .normal
        )
        button.setTitleColor(
            UIColor(red: 71.0/255.0, green: 156.0/255.0, blue: 1, alpha: 1),
            for: .normal
        )
        return button
    }()
    
    var sure_button: UIButton = {
        let button = UIButton()
        button.setTitle(
            NSLocalizedString("Sure", comment: "Sure"),
            for: .normal
        )
        button.setTitleColor(
            UIColor(red: 71.0/255.0, green: 156.0/255.0, blue: 1, alpha: 1),
            for: .normal
        )
        return button
    }()
    
    var line_view_1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }()
    var line_view_2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return view
    }()
    
    // MARK: - Action
    
    func display(inView view: UIView) {
        if let scroll = view as? UIScrollView {
            scroll.isScrollEnabled = false
        }
        self.frame = view.bounds
        self.back_view.frame = CGRect(
            x: view.bounds.width / 2,
            y: view.bounds.height / 2,
            width: 0, height: 0
        )
        for sub in self.back_view.subviews {
            sub.alpha = 0
        }
        view.addSubview(self)
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.update_subViews_size()
        }, completion: { _ in })
        UIView.animate(withDuration: 0.25, delay: 0.1, options: UIViewAnimationOptions.curveLinear, animations: {
            for sub in self.back_view.subviews {
                sub.alpha = 1
            }
        }, completion: { _ in })
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { _ in
            if let view = self.superview {
                if let scroll = view as? UIScrollView {
                    scroll.isScrollEnabled = true
                }
            }
            self.removeFromSuperview()
        })
    }
    
    @objc func cancel_action(_ sender: UIButton) {
        dismiss()
    }
    
    @objc func sure_action(_ sender: UIButton) {
        self.action?(self, value)
        self.action = nil
        dismiss()
    }
    
    // MARK: - Size
    
    func update_subViews_size() {
        // Back View
        back_view.bounds = CGRect(
            x: 0,
            y: 0,
            width: size_width,
            height: size_content_height + 120
        )
        back_view.center = CGPoint(
            x: bounds.width / 2,
            y: bounds.height / 2
        )
        
        // Title Label
        title_label.frame = CGRect(
            x: 0, y: 20,
            width: back_view.bounds.width,
            height: 30
        )
        
        // Cancel and Sure
        cancel_button.frame = CGRect(
            x: 0,
            y: back_view.bounds.height - 50,
            width: back_view.bounds.width / 2,
            height: 50
        )
        sure_button.frame = CGRect(
            x: back_view.bounds.width / 2,
            y: back_view.bounds.height - 50,
            width: back_view.bounds.width / 2,
            height: 50
        )
        
        // Lines
        line_view_1.frame = CGRect(
            x: 0,
            y: back_view.bounds.height - 50,
            width: back_view.bounds.width,
            height: 1
        )
        line_view_2.frame = CGRect(
            x: back_view.bounds.width / 2,
            y: back_view.bounds.height - 50,
            width: 1,
            height: 50
        )
    }
    
}

// MARK: - Table View Modal View

/**
 A ModalView add tableview
 */
class ModalView_TableView: ModalView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Table Views
    
    var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "ModalView_TableView_Cell"
        )
        return table
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ModalView_TableView_Cell",
            for: indexPath
        )
        if let _ = cell.viewWithTag(10) as? UILabel { } else {
            let title = UILabel(frame: CGRect.zero)
            title.textAlignment = .center
            title.tag = 10
            cell.addSubview(title)
            cell.selectionStyle = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let title = cell.viewWithTag(10) as? UILabel {
            title.frame = cell.bounds
            title.text = datas[indexPath.row]
        }
        if indexPath.row == index {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            index = indexPath.row
        }
    }
    
    // MARK: Values
    
    var datas: [String] = ["AA", "BB", "CC", "DD"] {
        didSet {
            if datas.count < 5 {
                size_content_height = CGFloat(datas.count) * 44 + 20
            }
            else {
                size_content_height = 174
            }
        }
    }
    
    var index: Int = 0
    
    // MARK: Override
    
    override func deploy() {
        super.deploy()
        back_view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        size_content_height = 200
    }
    
    override func update_subViews_size() {
        super.update_subViews_size()
        content_view.frame = CGRect(
            x: 10,
            y: 60,
            width: back_view.bounds.width - 20,
            height: back_view.bounds.height - 120
        )
        tableView.frame = CGRect(
            x: 20,
            y: 70,
            width: back_view.bounds.width - 40,
            height: back_view.bounds.height - 140
        )
    }
    
    override func sure_action(_ sender: UIButton) {
        self.value = index
        super.sure_action(sender)
    }
    
    // MARK: Action
    
    @discardableResult
    func datas(_ value: [String]) -> ModalView_TableView {
        self.datas = value
        return self
    }
    
    @discardableResult
    func index(_ value: Int) -> ModalView_TableView {
        self.index = value
        return self
    }
    
    @discardableResult
    func value(_ value: Any?) -> ModalView_TableView {
        self.value = value
        return self
    }
    
    @discardableResult
    func action(_ value: ((ModalView, Any?) -> Void)?) -> ModalView_TableView {
        self.action = value
        return self
    }
    
}

// MARK: - ModalView_Slider

/**
 A ModalView add Slider Views
 */
class ModalView_Slider: ModalView {
    
    // MARK: - Slider Views
    
    var slider: UISlider = {
        let view = UISlider()
        return view
    }()
    var value_label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    
    @objc func slider_action(_ sender: UISlider) {
        let count = Float(datas.count - 1)
        index = Int((sender.value + (1 / count / 2)) * count)
    }
    
    // MARK: Values
    
    var datas: [String] = []
    var index: Int = 0 {
        didSet {
            if index >= 0 && index < datas.count {
                value_label.text = datas[index]
            }
            else {
                value_label.text = "--"
            }
            if !slider.isTouchInside {
                let count = Float(datas.count - 1)
                let space = 1 / count
                slider.value = space * Float(index) + space / 2
            }
        }
    }
    
    // MARK: - Override
    
    override func deploy() {
        super.deploy()
        back_view.addSubview(value_label)
        back_view.addSubview(slider)
        slider.addTarget(
            self,
            action: #selector(slider_action(_:)),
            for: UIControlEvents.valueChanged
        )
        size_content_height = 90
    }
    
    override func update_subViews_size() {
        super.update_subViews_size()
        content_view.frame = CGRect(
            x: 10,
            y: 60,
            width: back_view.bounds.width - 20,
            height: back_view.bounds.height - 120
        )
        value_label.frame = CGRect(
            x: 20,
            y: 70,
            width: back_view.bounds.width - 40,
            height: 30
        )
        slider.frame = CGRect(
            x: 20,
            y: 100,
            width: back_view.bounds.width - 40,
            height: 60
        )
    }
    
    override func sure_action(_ sender: UIButton) {
        self.value = index
        super.sure_action(sender)
    }
    
    // MARK: Action
    
    @discardableResult
    func datas(_ value: [String]) -> ModalView_Slider {
        self.datas = value
        return self
    }
    
    @discardableResult
    func index(_ value: Int) -> ModalView_Slider {
        self.index = value
        return self
    }
    
    @discardableResult
    func value(_ value: Any?) -> ModalView_Slider {
        self.value = value
        return self
    }
    
    @discardableResult
    func action(_ value: ((ModalView, Any?) -> Void)?) -> ModalView_Slider {
        self.action = value
        return self
    }
    
}
