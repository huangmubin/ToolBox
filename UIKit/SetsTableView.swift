//
//  SetsTableView.swift
//  SetsViews
//
//  Created by Myron on 2017/6/1.
//  Copyright © 2017年 Myron. All rights reserved.
//

import UIKit

// MARK: - Sets Table View Delegate

@objc protocol SetsTableViewDelegate {
    
    @objc optional func setsTableView(tableView: SetsTableView, cell: SetsTableViewCell, loadAtIndex index: IndexPath, item: SetsTableViewItem)
    
    @objc optional func setsTableView(cell: SetsTableViewCell, actionAtIndex index: IndexPath, value: Any)
    
    @objc optional func setsTableView(tableView: SetsTableView, selectAtIndex index: IndexPath, item: SetsTableViewItem)
}

// MARK: - Sets Table View Model

@objc protocol SetsTableViewItem {
    var identifier: String { get set }
    var height_row: CGFloat { get set }
    var title: String { get set }
}

@objc protocol SetsTableViewItem_Image {
    var image: UIImage? { get set }
}

protocol SetsTableViewItem_Switch: SetsTableViewItem, SetsTableViewItem_Image {
    var switch_value: Bool? { get set }
}

protocol SetsTableViewItem_List: SetsTableViewItem, SetsTableViewItem_Image {
    var select_value: String? { get set }
    var select_lists: [String] { get set }
    var detail_image: UIImage? { get set }
}

// MARK: - Sets Table View Cell

class SetsTableViewCell: UITableViewCell {
    
    // MARK: Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    func deploy() { }
    
    // MARK: Datas
    
    weak var item: SetsTableViewItem?
    weak var delegate: SetsTableViewDelegate?
    weak var tableview: SetsTableView?
    
    var index: IndexPath?
    
    func update(item: SetsTableViewItem, index: IndexPath) {
        self.item = item
        self.index = index
    }
    
}

// MARK: Switch

class SetsTableViewCell_Switch: SetsTableViewCell {
    
    var item_image: UIImageView = UIImageView()
    var item_title: UILabel = UILabel()
    var item_switch: UISwitch = UISwitch()
    
    func switch_action(_ sender: UISwitch) {
        delegate?.setsTableView?(
            cell: self,
            actionAtIndex: index!,
            value: item_switch.isOn
        )
    }
    
    override func deploy() {
        super.deploy()
        let _ = {
            addSubview(item_image)
            item_image.translatesAutoresizingMaskIntoConstraints = false
            let top = NSLayoutConstraint(
                item: item_image,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 8
            )
            let bottom = NSLayoutConstraint(
                item: item_image,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: -8
            )
            let leading = NSLayoutConstraint(
                item: item_image,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 8
            )
            let equal = NSLayoutConstraint(
                item: item_image,
                attribute: .width,
                relatedBy: .equal,
                toItem: item_image,
                attribute: .height,
                multiplier: 1,
                constant: 0
            )
            addConstraints([top, bottom, leading])
            item_image.addConstraint(equal)
        }()
        
        let _ = {
            addSubview(item_title)
            item_title.translatesAutoresizingMaskIntoConstraints = false
            let center = NSLayoutConstraint(
                item: item_title,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
            let leading = NSLayoutConstraint(
                item: item_title,
                attribute: .leading,
                relatedBy: .equal,
                toItem: item_image,
                attribute: .trailing,
                multiplier: 1,
                constant: 8
            )
            addConstraints([center, leading])
        }()
        
        let _ = {
            addSubview(item_switch)
            item_switch.addTarget(
                self,
                action: #selector(switch_action),
                for: UIControlEvents.valueChanged
            )
            item_switch.translatesAutoresizingMaskIntoConstraints = false
            let center = NSLayoutConstraint(
                item: item_switch,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
            let trailing = NSLayoutConstraint(
                item: item_switch,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: -8
            )
            addConstraints([center, trailing])
        }()
    }
    
    override func update(item: SetsTableViewItem, index: IndexPath) {
        super.update(item: item, index: index)
        item_title.text = item.title
        if let switch_item = item as? SetsTableViewItem_Switch {
            item_image.image = switch_item.image
            if let value = switch_item.switch_value {
                item_switch.isEnabled = true
                item_switch.isOn = value
            }
            else {
                item_switch.isEnabled = false
                item_switch.isOn = false
            }
        }
    }
}

// MARK: List

class SetsTableViewCell_List: SetsTableViewCell {
    
    var item_image: UIImageView = UIImageView()
    var item_title: UILabel = UILabel()
    var item_value: UILabel = UILabel()
    var item_detail_image: UIImageView = UIImageView()
    
    override func deploy() {
        super.deploy()
        let _ = {
            addSubview(item_image)
            item_image.translatesAutoresizingMaskIntoConstraints = false
            let top = NSLayoutConstraint(
                item: item_image,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 8
            )
            let bottom = NSLayoutConstraint(
                item: item_image,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: -8
            )
            let leading = NSLayoutConstraint(
                item: item_image,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 8
            )
            let equal = NSLayoutConstraint(
                item: item_image,
                attribute: .width,
                relatedBy: .equal,
                toItem: item_image,
                attribute: .height,
                multiplier: 1,
                constant: 0
            )
            addConstraints([top, bottom, leading])
            item_image.addConstraint(equal)
        }()
        
        let _ = {
            addSubview(item_title)
            item_title.translatesAutoresizingMaskIntoConstraints = false
            let center = NSLayoutConstraint(
                item: item_title,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
            let leading = NSLayoutConstraint(
                item: item_title,
                attribute: .leading,
                relatedBy: .equal,
                toItem: item_image,
                attribute: .trailing,
                multiplier: 1,
                constant: 8
            )
            addConstraints([center, leading])
        }()
        
        let _ = {
            addSubview(item_detail_image)
            item_detail_image.translatesAutoresizingMaskIntoConstraints = false
            let center = NSLayoutConstraint(
                item: item_detail_image,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
            let trailing = NSLayoutConstraint(
                item: item_detail_image,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: -8
            )
            let width = NSLayoutConstraint(
                item: item_detail_image,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 30
            )
            let height = NSLayoutConstraint(
                item: item_detail_image,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 30
            )
            item_detail_image.addConstraints([width, height])
            addConstraints([center, trailing])
        }()
        
        let _ = {
            addSubview(item_value)
            item_value.translatesAutoresizingMaskIntoConstraints = false
            let center = NSLayoutConstraint(
                item: item_value,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
            let trailing = NSLayoutConstraint(
                item: item_value,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: item_detail_image,
                attribute: .leading,
                multiplier: 1,
                constant: -8
            )
            addConstraints([center, trailing])
        }()
    }
    
    override func update(item: SetsTableViewItem, index: IndexPath) {
        super.update(item: item, index: index)
        item_title.text = item.title
        if let list_item = item as? SetsTableViewItem_List {
            item_image.image = list_item.image
            item_value.text = list_item.select_value
            item_detail_image.image = list_item.detail_image
        }
        else {
            item_image.image = nil
            item_value.text = nil
            item_detail_image.image = nil
        }
    }
    
}

// MARK: Slider

class SetsTableViewCell_Slider: SetsTableViewCell_List {
    
}

// MARK: Action

class SetsTableViewCell_Action: SetsTableViewCell {
    
    var item_button: UIButton = UIButton(type: UIButtonType.system)
    
    override func deploy() {
        super.deploy()
        let _ = {
            addSubview(item_button)
            item_button.translatesAutoresizingMaskIntoConstraints = false
            item_button.addTarget(
                self,
                action: #selector(button_action(_:)),
                for: .touchUpInside
            )
            item_button.layer.borderWidth = 1
            item_button.layer.borderColor = UIColor(red: 71.0/255.0, green: 156.0/255.0, blue: 1, alpha: 1).cgColor
            item_button.layer.cornerRadius = 8
            item_button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 2)
            let top = NSLayoutConstraint(
                item: item_button,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 8
            )
            let bottom = NSLayoutConstraint(
                item: item_button,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: -8
            )
            let leading = NSLayoutConstraint(
                item: item_button,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 20
            )
            let trailing = NSLayoutConstraint(
                item: item_button,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: -20
            )
            addConstraints([top, bottom, leading, trailing])
        }()
    }
    
    override func update(item: SetsTableViewItem, index: IndexPath) {
        super.update(item: item, index: index)
        item_button.setTitle(item.title, for: .normal)
    }
    
    func button_action(_ sender: UIButton) {
        tableview?.tableView(tableview!, didSelectRowAt: index!)
    }

}

// MARK: Info

class SetsTableViewCell_Info: SetsTableViewCell {
    
    var item_label: UILabel = UILabel()
    
    override func deploy() {
        super.deploy()
        let _ = {
            addSubview(item_label)
            item_label.translatesAutoresizingMaskIntoConstraints = false
            item_label.numberOfLines = 0
            let top = NSLayoutConstraint(
                item: item_label,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: 8
            )
            let bottom = NSLayoutConstraint(
                item: item_label,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: self,
                attribute: .bottom,
                multiplier: 1,
                constant: -8
            )
            let leading = NSLayoutConstraint(
                item: item_label,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 20
            )
            let trailing = NSLayoutConstraint(
                item: item_label,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: -20
            )
            addConstraints([top, bottom, leading, trailing])
        }()
    }
    
    override func update(item: SetsTableViewItem, index: IndexPath) {
        super.update(item: item, index: index)
        item_label.text = item.title
    }
    
}


// MARK: - Sets Table View

class SetsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Init
    
    init() {
        super.init(frame: UIScreen.main.bounds, style: .plain)
        deploy()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    private func deploy() {
        dataSource = self
        delegate = self
        register(
            SetsTableViewCell_Switch.self,
            forCellReuseIdentifier: "SetsTableViewCell_Switch"
        )
        register(
            SetsTableViewCell_List.self,
            forCellReuseIdentifier: "SetsTableViewCell_List"
        )
        register(
            SetsTableViewCell_Slider.self,
            forCellReuseIdentifier: "SetsTableViewCell_Slider"
        )
        register(
            SetsTableViewCell_Action.self,
            forCellReuseIdentifier: "SetsTableViewCell_Action"
        )
        register(
            SetsTableViewCell_Info.self,
            forCellReuseIdentifier: "SetsTableViewCell_Info"
        )
    }
    
    // MARK: - Model
    
    var items: [[SetsTableViewItem]] = []
    weak var cell_delegate: SetsTableViewDelegate?
    
    // MARK: - UITableViewDateSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: item.identifier,
            for: indexPath
        ) as! SetsTableViewCell
        cell.delegate = cell_delegate
        cell.tableview = self
        cell.selectionStyle = .none
        cell_delegate?.setsTableView?(
            tableView: self,
            cell: cell,
            loadAtIndex: indexPath,
            item: item
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        (cell as! SetsTableViewCell).update(
            item: item,
            index: indexPath
        )
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.section][indexPath.row].height_row
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! SetsTableViewCell
        switch item.identifier {
        case "SetsTableViewCellSwitch":
            break
        case "SetsTableViewCellList":
            let modal = ModalView.table(item.title)
            modal.index = -1
            if let list_item = item as? SetsTableViewItem_List {
                if let index = list_item.select_lists.index(where: { $0 == list_item.select_value }) {
                    modal.datas(list_item.select_lists).index(index)
                }
            }
            modal.action({ [weak self] (view, value) in
                self?.cell_delegate?.setsTableView?(
                    cell: cell,
                    actionAtIndex: indexPath,
                    value: value!
                )
            }).display(inView: self)
        case "SetsTableViewCellSlider":
            let modal = ModalView.slider(item.title)
            modal.index = -1
            if let list_item = item as? SetsTableViewItem_List {
                modal.datas(list_item.select_lists)
                if let index = list_item.select_lists.index(where: { $0 == list_item.select_value }) {
                    modal.index(index)
                }
            }
            modal.action({ [weak self] (view, value) in
                self?.cell_delegate?.setsTableView?(
                    cell: cell,
                    actionAtIndex: indexPath,
                    value: value!
                )
            }).display(inView: self)
        case "SetsTableViewCellAction":
            let modal = ModalView()
            modal.title_label.text = item.title
            modal.value = item
            modal.action = { [weak self] (view, value) in
                self?.cell_delegate?.setsTableView?(
                    cell: cell,
                    actionAtIndex: indexPath,
                    value: value!
                )
            }
            modal.display(inView: self)
        case "SetsTableViewCellInfo":
            self.cell_delegate?.setsTableView?(
                cell: cell,
                actionAtIndex: indexPath,
                value: item
            )
            self.reloadRows(at: [indexPath], with: .automatic)
        default:
            cell_delegate?.setsTableView?(
                tableView: self,
                selectAtIndex: indexPath,
                item: item
            )
        }
    }
    
}
