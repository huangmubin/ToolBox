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
    @objc optional func setsTableView(tableView: SetsTableView, cell: SetsTableViewCell, displayAtIndex index: IndexPath, item: SetsTableViewItem)
    
    @objc optional func setsTableView(tableView: SetsTableView, header: UITableViewHeaderFooterView?, loadAtSection section: Int)
    @objc optional func setsTableView(tableView: SetsTableView, header: UIView?, displayAtSection section: Int)
    @objc optional func setsTableView(tableView: SetsTableView, heightAtSection section: Int) -> CGFloat
    @objc optional func setsTableView(tableView: SetsTableView, headerTitleAtSection section: Int) -> String?
    
    @objc optional func setsTableView(cell: SetsTableViewCell, actionAtIndex index: IndexPath, value: Any)
    
    @objc optional func setsTableView(tableView: SetsTableView, selectAtIndex index: IndexPath, item: SetsTableViewItem)
}

// MARK: - Sets Table View Model

@objc protocol SetsTableViewItem {
    var identifier: String { get set }
    var height_row: CGFloat { get set }
    var title: String { get set }
    
    var value: Any? { get set }
    var temp: Any? { get set }
}

@objc protocol SetsTableViewItem_Image {
    var image: UIImage? { get set }
}

protocol SetsTableViewItem_Switch: SetsTableViewItem, SetsTableViewItem_Image {
    //var switch_value: Bool? { get set }
}

protocol SetsTableViewItem_List: SetsTableViewItem, SetsTableViewItem_Image {
    //var select_value: String? { get set }
    var select_lists: [String] { get set }
    var detail_image: UIImage? { get set }
}

class SetsTableViewItemModel: SetsTableViewItem {
    
    var identifier: String = "SetsTableViewCell_Info"
    var height_row: CGFloat = 44
    var title: String = "SetsTableViewCell"
    
    var value: Any?
    var temp: Any?
    
    init() {
        
    }
    init(dictionary: [String: Any]) {
        if let value = dictionary["identifier"] as? String {
            self.identifier = value
        }
        if let value = dictionary["height_row"] as? CGFloat {
            self.height_row = value
        }
        if let value = dictionary["title"] as? String {
            self.title = value
        }
        if let value = dictionary["value"] {
            self.value = value
        }
        if let value = dictionary["temp"] {
            self.temp = value
        }
    }
    
    class func analysis(dictionary: [String: Any]) -> SetsTableViewItemModel? {
        if let identifier = dictionary["identifier"] as? String {
            switch identifier {
            case "SetsTableViewCell_Info", "SetsTableViewCell_Action":
                return SetsTableViewItemModel(dictionary: dictionary)
            case "SetsTableViewCell_Slider", "SetsTableViewCell_List":
                return SetsTableViewItemModel_List(dictionary: dictionary)
            case "SetsTableViewCell_Switch":
                return SetsTableViewItemModel_Switch(dictionary: dictionary)
            default: break
            }
        }
        return nil
    }
    
    // [[[String: Any]]]
    class func analysis(datas: [Any]) -> [[SetsTableViewItemModel]] {
        var model_items = [[SetsTableViewItemModel]]()
        for data in datas {
            if let list = data as? [Any] {
                var model_rows = [SetsTableViewItemModel]()
                for value in list {
                    if let dic = value as? [String: Any] {
                        if let model = analysis(dictionary: dic) {
                            model_rows.append(model)
                        }
                    }
                }
                model_items.append(model_rows)
            }
        }
        return model_items
    }
    
}

class SetsTableViewItemModel_Switch: SetsTableViewItemModel, SetsTableViewItem_Switch {
    
    var image: UIImage?
    //    var switch_value: Bool?
    
    override init() {
        super.init()
    }
    override init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        if let value = dictionary["image"] as? String {
            self.image = UIImage(named: value)
        }
        //        if let value = dictionary["switch_value"] as? Bool {
        //            self.switch_value = value
        //        }
    }
}

class SetsTableViewItemModel_List: SetsTableViewItemModel, SetsTableViewItem_List {
    
    var image: UIImage?
    //    var select_value: String?
    var select_lists: [String] = []
    var detail_image: UIImage?
    
    override init() {
        super.init()
    }
    override init(dictionary: [String: Any]) {
        super.init(dictionary: dictionary)
        if let value = dictionary["image"] as? String {
            self.image = UIImage(named: value)
        }
        //        if let value = dictionary["select_value"] as? String {
        //            self.select_value = value
        //        }
        if let value = dictionary["select_lists"] as? [String] {
            self.select_lists = value
        }
        if let value = dictionary["detail_image"] as? String {
            self.detail_image = UIImage(named: value)
        }
    }
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
    
    // MARK: Layout
    
    var layout_title_leading: NSLayoutConstraint?
    
}

// MARK: Switch

class SetsTableViewCell_Switch: SetsTableViewCell {
    
    var item_image: UIImageView = UIImageView()
    var item_title: UILabel = UILabel()
    var item_switch: UISwitch = UISwitch()
    var layout_switch_trailing: NSLayoutConstraint?
    
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
            layout_title_leading = leading
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
                constant: -30
            )
            layout_switch_trailing = trailing
            addConstraints([center, trailing])
        }()
    }
    
    override func update(item: SetsTableViewItem, index: IndexPath) {
        super.update(item: item, index: index)
        item_title.text = NSLocalizedString(item.title, comment: "")
        if let switch_item = item as? SetsTableViewItem_Switch {
            item_image.image = switch_item.image
            var on: Bool?
            if let value = switch_item.value as? String {
                switch value.lowercased() {
                case "ok", "on", "yes", "true", "1":
                    on = true
                case "off", "no", "false", "0":
                    on = false
                default:
                    break
                }
            }
            if let value = switch_item.value as? Bool {
                on = value
            }
            if let value = switch_item.value as? Int {
                on = value == 1
            }
            
            if let value = on {
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
            layout_title_leading = leading
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
        item_title.text = NSLocalizedString(item.title, comment: "")
        if let list_item = item as? SetsTableViewItem_List {
            item_image.image = list_item.image
            item_detail_image.image = list_item.detail_image
            if let value = list_item.value as? String {
                item_value.text = NSLocalizedString(value, comment: "")
                item_value.textColor = UIColor.black
            }
            else {
                item_value.text = NSLocalizedString("---", comment: "")
                item_value.textColor = UIColor.lightGray
            }
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
    var layout_button_space: NSLayoutConstraint?
    
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
            let centerX = NSLayoutConstraint(
                item: item_button,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
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
            layout_button_space = leading
            addConstraints([top, bottom, leading, centerX])
        }()
    }
    
    override func update(item: SetsTableViewItem, index: IndexPath) {
        super.update(item: item, index: index)
        item_button.setTitle(
            NSLocalizedString(item.title, comment: ""),
            for: .normal
        )
        item_button.setTitleColor(tableview!.button_color, for: .normal)
        item_button.layer.borderColor = tableview!.button_color!.cgColor
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
        if let info = item.value as? String {
            item_label.text = NSLocalizedString(item.title, comment: "") + " : " + NSLocalizedString(info, comment: "")
        }
        else {
            item_label.text = NSLocalizedString(item.title, comment: "")
        }
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
            UITableViewHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: "UITableViewHeaderFooterView"
        )
        
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
    @IBInspectable
    var button_color: UIColor? = UIColor(
        red: 71.0/255.0,
        green: 156.0/255.0,
        blue: 1,
        alpha: 1
    )
    @IBInspectable
    var header_height: CGFloat = 30
    
    func items(index: IndexPath) -> SetsTableViewItem {
        return items[index.section][index.row]
    }
    
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "UITableViewHeaderFooterView"
        )
        cell_delegate?.setsTableView?(
            tableView: self,
            header: view,
            loadAtSection: section
        )
        return view
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cell_delegate?.setsTableView?(
            tableView: self,
            headerTitleAtSection: section
        )
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        (cell as! SetsTableViewCell).update(
            item: item,
            index: indexPath
        )
        cell_delegate?.setsTableView?(
            tableView: self,
            cell: cell as! SetsTableViewCell,
            displayAtIndex: indexPath,
            item: item
        )
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        cell_delegate?.setsTableView?(
            tableView: self,
            header: view,
            displayAtSection: section
        )
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return items[indexPath.section][indexPath.row].height_row
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cell_delegate?.setsTableView?(
            tableView: self,
            heightAtSection: section
            ) ?? header_height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        if item.value == nil && item.identifier != "SetsTableViewCell_Action" {
            return
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! SetsTableViewCell
        switch item.identifier {
        case "SetsTableViewCell_Switch":
            break
        case "SetsTableViewCell_List":
            let modal = ModalView.table(item.title)
            modal.index = -1
            if let list_item = item as? SetsTableViewItem_List {
                modal.datas(list_item.select_lists)
                if let value = list_item.value as? String {
                    if let index = list_item.select_lists.index(where: { $0 == value }) {
                        modal.index(index)
                    }
                }
            }
            modal.action({ [weak self] (view, value) in
                self?.cell_delegate?.setsTableView?(
                    cell: cell,
                    actionAtIndex: indexPath,
                    value: value!
                )
            }).display(inView: self)
        case "SetsTableViewCell_Slider":
            let modal = ModalView.slider(item.title)
            modal.index = -1
            if let list_item = item as? SetsTableViewItem_List {
                modal.datas(list_item.select_lists)
                if let value = list_item.value as? String {
                    if let index = list_item.select_lists.index(where: { $0 == value }) {
                        modal.index(index)
                    }
                }
            }
            modal.action({ [weak self] (view, value) in
                self?.cell_delegate?.setsTableView?(
                    cell: cell,
                    actionAtIndex: indexPath,
                    value: value!
                )
            }).display(inView: self)
        case "SetsTableViewCell_Action":
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
        case "SetsTableViewCell_Info":
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
