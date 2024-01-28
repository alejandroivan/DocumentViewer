//
//  AppLayoutAnchor.swift
//  DocumentViewer
//
//  Copyright © 2024 Alejandro Melo Domínguez
//
//  Provided under the MIT license.
//

import UIKit

// MARK: - Layout Anchors Protocol

/// Typealias just in case we have any naming conflict.
public typealias AppLayoutAnchor = ApplicationLayoutAnchor

/// Defines a constraint protocol, which can be applied to `UIView`s.
public protocol ApplicationLayoutAnchor {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
}

/// Defines the return type for a collection of constraints when using the `.pinConstraint...()` variants.
/// If you add multiple constraints and two use the same `NSLayoutConstraint.Attribute`s,
/// then only the last one in the list will be returned.
/// All constraints in this collection are activated by default.
public typealias AppLayoutAnchorConstraintCollection = [NSLayoutConstraint.Attribute: NSLayoutConstraint]

extension AppLayoutAnchorConstraintCollection where Value: NSLayoutConstraint {
    public typealias Constraint = Value?

    public var top: Constraint { self[.top] }
    public var bottom: Constraint { self[.bottom] }
    public var leading: Constraint { self[.leading] }
    public var trailing: Constraint { self[.trailing] }
    public var width: Constraint { self[.width] }
    public var height: Constraint { self[.height] }
    public var centerX: Constraint { self[.centerX] }
    public var centerY: Constraint { self[.centerY] }
    public var left: Constraint { self[.left] }
    public var right: Constraint { self[.right] }
}

/// Conforming to the protocol.
extension UIView: AppLayoutAnchor {}
extension UILayoutGuide: AppLayoutAnchor {}

// MARK: - Pinning

public extension UIView {

    @discardableResult
    func pin(
        _ attributes: NSLayoutConstraint.Attribute...,
        to item: AppLayoutAnchor? = nil,
        relation: NSLayoutConstraint.Relation = .equal,
        constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        priority: UILayoutPriority = .required
    ) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = []

        for attribute in attributes {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: relation,
                toItem: item,
                attribute: attribute,
                multiplier: multiplier,
                constant: constant
            )
            constraint.priority = priority
            constraint.identifier = String(describing: attribute)
            constraints.append(constraint)
        }

        NSLayoutConstraint.activate(constraints)
        return self
    }

    func pinConstraint(
        _ attributes: NSLayoutConstraint.Attribute...,
        to item: AppLayoutAnchor? = nil,
        relation: NSLayoutConstraint.Relation = .equal,
        constant: CGFloat = 0,
        multiplier: CGFloat = 1,
        priority: UILayoutPriority = .required
    ) -> AppLayoutAnchorConstraintCollection {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints: AppLayoutAnchorConstraintCollection = [:]

        for attribute in attributes {
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: relation,
                toItem: item,
                attribute: attribute,
                multiplier: multiplier,
                constant: constant
            )
            constraint.priority = priority
            constraint.identifier = String(describing: attribute)
            constraints[attribute] = constraint
        }

        let values: [NSLayoutConstraint] = constraints.values.compactMap { $0 }
        NSLayoutConstraint.activate(values)

        return constraints
    }

    @discardableResult
    func pin(
        _ attribute: NSLayoutConstraint.Attribute,
        to yAnchor: NSLayoutYAxisAnchor,
        offset: CGFloat = 0,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required
    ) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = yAxisAnchor(for: attribute).constraint(for: relation, to: yAnchor, constant: offset)
        constraint.priority = priority
        constraint.identifier = String(describing: attribute)
        constraint.isActive = true
        return self
    }

    func pinConstraint(
        _ attribute: NSLayoutConstraint.Attribute,
        to yAnchor: NSLayoutYAxisAnchor,
        offset: CGFloat = 0,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = yAxisAnchor(for: attribute).constraint(for: relation, to: yAnchor, constant: offset)
        constraint.priority = priority
        constraint.identifier = String(describing: attribute)
        constraint.isActive = isActive
        return constraint
    }

    @discardableResult
    func pin(
        _ attribute: NSLayoutConstraint.Attribute,
        to xAnchor: NSLayoutXAxisAnchor,
        offset: CGFloat = 0,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required
    ) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = xAxisAnchor(for: attribute).constraint(for: relation, to: xAnchor, constant: offset)
        constraint.priority = priority
        constraint.identifier = String(describing: attribute)
        constraint.isActive = true
        return self
    }

    func pinConstraint(
        _ attribute: NSLayoutConstraint.Attribute,
        to xAnchor: NSLayoutXAxisAnchor,
        offset: CGFloat = 0,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = xAxisAnchor(for: attribute).constraint(for: relation, to: xAnchor, constant: offset)
        constraint.priority = priority
        constraint.identifier = String(describing: attribute)
        constraint.isActive = isActive
        return constraint
    }

    func pinConstraint(
        _ attribute: NSLayoutConstraint.Attribute,
        constant: CGFloat = 0,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        isActive: Bool = true
    ) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = layoutDimension(for: attribute).constraint(for: relation, constant: constant)
        constraint.priority = priority
        constraint.identifier = String(describing: attribute)
        constraint.isActive = isActive
        return constraint
    }
}

// MARK: - Helpers

extension UIView {

    fileprivate func yAxisAnchor(for location: NSLayoutConstraint.Attribute) -> NSLayoutYAxisAnchor {
        switch location {
        case .top: return topAnchor
        case .bottom: return bottomAnchor
        case .firstBaseline: return firstBaselineAnchor
        case .lastBaseline: return lastBaselineAnchor
        case .centerY: return centerYAnchor
        default:
            fatalError("Only y-axis attributes can translate to y-axis anchors.")
        }
    }

    fileprivate func xAxisAnchor(for location: NSLayoutConstraint.Attribute) -> NSLayoutXAxisAnchor {
        switch location {
        case .left: return leftAnchor
        case .right: return rightAnchor
        case .leading: return leadingAnchor
        case .trailing: return trailingAnchor
        case .centerX: return centerXAnchor
        default:
            fatalError("Only x-axis attributes can translate to x-axis anchors.")
        }
    }

    fileprivate func layoutDimension(for dimension: NSLayoutConstraint.Attribute) -> NSLayoutDimension {
        switch dimension {
        case .width: return widthAnchor
        case .height: return heightAnchor
        default:
            fatalError("Only width/height attributes can translate to layout dimensions.")
        }
    }
}

public extension NSLayoutYAxisAnchor {

    func constraint(
        for relation: NSLayoutConstraint.Relation,
        to anchor: NSLayoutYAxisAnchor,
        constant: CGFloat = 0
    ) -> NSLayoutConstraint {
        switch relation {
        case .lessThanOrEqual:
            return constraint(lessThanOrEqualTo: anchor, constant: constant)
        case .equal:
            return constraint(equalTo: anchor, constant: constant)
        case .greaterThanOrEqual:
            return constraint(greaterThanOrEqualTo: anchor, constant: constant)
        @unknown default:
            return constraint(equalTo: anchor, constant: constant)
        }
    }
}

public extension NSLayoutXAxisAnchor {

    func constraint(
        for relation: NSLayoutConstraint.Relation,
        to anchor: NSLayoutXAxisAnchor,
        constant: CGFloat = 0
    ) -> NSLayoutConstraint {
        switch relation {
        case .lessThanOrEqual:
            return constraint(lessThanOrEqualTo: anchor, constant: constant)
        case .equal:
            return constraint(equalTo: anchor, constant: constant)
        case .greaterThanOrEqual:
            return constraint(greaterThanOrEqualTo: anchor, constant: constant)
        @unknown default:
            return constraint(equalTo: anchor, constant: constant)
        }
    }
}

public extension NSLayoutDimension {
    func constraint(
        for relation: NSLayoutConstraint.Relation,
        constant: CGFloat = 0
    ) -> NSLayoutConstraint {
        switch relation {
        case .lessThanOrEqual:
            return constraint(lessThanOrEqualToConstant: constant)
        case .equal:
            return constraint(equalToConstant: constant)
        case .greaterThanOrEqual:
            return constraint(greaterThanOrEqualToConstant: constant)
        @unknown default:
            return constraint(equalToConstant: constant)
        }
    }
}

// MARK: - Bulk Constraints

// MARK: UIEdgeInsets Helpers

public extension UIEdgeInsets {

    init(uniform: CGFloat) {
        self.init(
            top: uniform,
            left: uniform,
            bottom: -uniform,
            right: -uniform
        )
    }
}

// MARK: Definitions

/// Returns a list of attribute pairs, used for simplicity.
/// For example, if we use `edges()`, we'll get pairs of all the edge constraints
/// associated with a constant (.top, .bottom, .leading, .trailing)
fileprivate enum BulkAttributes {

    typealias AttributePair = (attribute: NSLayoutConstraint.Attribute, constant: CGFloat)
    typealias AttributePairs = [AttributePair]

    // Edges

    static func edges(_ insets: UIEdgeInsets) -> AttributePairs {
        [
            (attribute: .leading, constant: insets.left),
            (attribute: .trailing, constant: insets.right),
            (attribute: .top, constant: insets.top),
            (attribute: .bottom, constant: insets.bottom),
        ]
    }

    // Center

    static func center(_ offset: CGPoint) -> AttributePairs {
        [
            (attribute: .centerX, constant: offset.x),
            (attribute: .centerY, constant: offset.y)
        ]
    }

    // Size

    static func size(_ constant: CGSize) -> AttributePairs {
        [
            (attribute: .width, constant: constant.width),
            (attribute: .height, constant: constant.height)
        ]
    }
}

// MARK: - UIView Helpers

public extension UIView {

    // MARK: Edges

    @discardableResult
    /// Pins `self` to the edges of `item`.
    /// - Parameters:
    ///   - item: `item` to which `self` is pinning.
    ///   - insets: `UIEdgeInsets` from `item`'s frame. The default value is `.zero`.
    /// - Returns: `self` so this can be chained with other pinning calls.
    func pinEdges(
        to item: AppLayoutAnchor,
        insets: UIEdgeInsets
    ) -> UIView {
        for pair in BulkAttributes.edges(insets) {
            pin(pair.attribute, to: item, constant: pair.constant)
        }
        return self
    }

    /// Pins `self` to the edges of `item`.
    /// - Parameters:
    ///   - item: `item` to which `self` is pinning.
    ///   - insets: `UIEdgeInsets` from `item`'s frame. The default value is `.zero`.
    /// - Returns: The constraints assigned to `self`.
    func pinConstraintEdges(
        to item: AppLayoutAnchor,
        insets: UIEdgeInsets
    ) -> AppLayoutAnchorConstraintCollection {
        var constraints: AppLayoutAnchorConstraintCollection = [:]

        for pair in BulkAttributes.edges(insets) {
            let constraint = pinConstraint(pair.attribute, to: item, constant: pair.constant)
            constraints.merge(constraint) { _, new in new }
        }

        return constraints
    }

    @discardableResult
    /// Pins `self` to the edges of `item`.
    /// - Parameters:
    ///   - item: `item` to which `self` is pinning.
    ///   - constant: The `constant` to be used as spacing to the edges. The default value is `.zero`.
    ///               The negative sign will be automatically applied where necessary (.trailing, .bottom, etc).
    /// - Returns: `self` so this can be chained with other pinning calls.
    func pinEdges(
        to item: AppLayoutAnchor,
        constant: CGFloat = .zero
    ) -> UIView {
        pinEdges(to: item, insets: UIEdgeInsets(uniform: constant))
    }

    /// Pins `self` to the edges of `item`.
    /// - Parameters:
    ///   - item: `item` to which `self` is pinning.
    ///   - constant: The `constant` to be used as spacing to the edges. The default value is `.zero`.
    ///               The negative sign will be automatically applied where necessary (.trailing, .bottom, etc).
    /// - Returns: The constraints assigned to `self`.
    func pinConstraintEdges(
        to item: AppLayoutAnchor,
        constant: CGFloat = .zero
    ) -> AppLayoutAnchorConstraintCollection {
        pinConstraintEdges(to: item, insets: UIEdgeInsets(uniform: constant))
    }

    // MARK: Center

    @discardableResult
    /// Pins `self.center` to `item.center`.
    /// - Parameters:
    ///   - item: `item` to which `center` is being pinned by `self.center`.
    ///   - offset: An `offset` point to be used as a distance to `item.center`.
    /// - Returns: `self` so this can be chained with other pinning calls.
    func pinCenter(
        to item: AppLayoutAnchor,
        offset: CGPoint = .zero
    ) -> UIView {
        for pair in BulkAttributes.center(offset) {
            pin(pair.attribute, to: item, constant: pair.constant)
        }
        return self
    }

    /// Pins `self.center` to `item.center`.
    /// - Parameters:
    ///   - item: `item` to which `center` is being pinned by `self.center`.
    ///   - offset: An `offset` point to be used as a distance to `item.center`.
    /// - Returns: The constraints assigned to `self`.
    func pinConstraintCenter(
        to item: AppLayoutAnchor,
        offset: CGPoint = .zero
    ) -> AppLayoutAnchorConstraintCollection {
        var constraints: AppLayoutAnchorConstraintCollection = [:]

        for pair in BulkAttributes.center(offset) {
            let constraint = pinConstraint(pair.attribute, to: item, constant: pair.constant)
            constraints.merge(constraint) { _, new in new }
        }

        return constraints
    }

    // MARK: Size

    @discardableResult
    /// Pins `self`'s size to `item`'s size.
    /// - Parameters:
    ///   - view: The `UIView` from which `self`'s size is pinning to.
    ///   - padding: A size `padding` to differ from `view`'s size. The default value is `.zero`.
    ///   - priority: The `priority` assigned to the constraints. The default value is `.required`.
    /// - Returns: `self` so this can be chained with other pinning calls.
    func pinSize(
        to view: UIView,
        padding: CGSize = .zero,
        priority: UILayoutPriority = .required
    ) -> UIView {
        for pair in BulkAttributes.size(padding) {
            pin(pair.attribute, to: view, constant: pair.constant, priority: priority)
        }
        return self
    }

    /// Pins `self`'s size to `item`'s size.
    /// - Parameters:
    ///   - view: The `UIView` from which `self`'s size is pinning to.
    ///   - padding: A size `padding` to differ from `view`'s size. The default value is `.zero`.
    ///   - priority: The `priority` assigned to the constraints. The default value is `.required`.
    /// - Returns: The constraints assigned to `self`.
    func pinConstraintSize(
        to view: UIView,
        padding: CGSize = .zero,
        priority: UILayoutPriority = .required
    ) -> AppLayoutAnchorConstraintCollection {
        var constraints: AppLayoutAnchorConstraintCollection = [:]

        for pair in BulkAttributes.size(padding) {
            let constraint = pinConstraint(pair.attribute, to: view, constant: pair.constant, priority: priority)
            constraints.merge(constraint) { _, new in new }
        }

        return constraints
    }

    @discardableResult
    /// Pins `self` to a constant size.
    /// - Parameters:
    ///   - constant: The `size` to which `self`'s size will pin to.
    ///   - priority: The `priority` assigned to the constraints. The default value is `.required`.
    /// - Returns: `self` so this can be chained with other pinning calls.
    func pinSize(
        to size: CGSize,
        priority: UILayoutPriority = .required
    ) -> UIView {
        for pair in BulkAttributes.size(size) {
            pin(pair.attribute, constant: pair.constant, priority: priority)
        }
        return self
    }

    /// Pins `self` to a constant size.
    /// - Parameters:
    ///   - constant: The `size` to which `self`'s size will pin to.
    ///   - priority: The `priority` assigned to the constraints. The default value is `.required`.
    /// - Returns: The constraints assigned to `self`.
    func pinConstraintSize(
        to size: CGSize,
        priority: UILayoutPriority = .required
    ) -> AppLayoutAnchorConstraintCollection {
        var constraints: AppLayoutAnchorConstraintCollection = [:]

        for pair in BulkAttributes.size(size) {
            let constraint = pinConstraint(pair.attribute, constant: pair.constant, priority: priority)
            constraints[pair.attribute] = constraint
        }

        return constraints
    }

    @discardableResult
    /// Pins `self` to a constant _squared_ size.
    /// This means it will be a "constant x constant" sized view.
    /// - Parameters:
    ///   - constant: The `constant` to which `self`'s size will square-pin to.
    ///   - priority: The `priority` assigned to the constraints. The default value is `.required`.
    /// - Returns: `self` so this can be chained with other pinning calls.
    func pinSize(
        to constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> UIView {
        let size = CGSize(width: constant, height: constant)
        return pinSize(to: size, priority: priority)
    }

    /// Pins `self` to a constant _squared_ size.
    /// This means it will be a "constant x constant" sized view.
    /// - Parameters:
    ///   - constant: The `constant` to which `self`'s size will square-pin to.
    ///   - priority: The `priority` assigned to the constraints. The default value is `.required`.
    /// - Returns: `self` so this can be chained with other pinning calls.
    func pinConstraintSize(
        to constant: CGFloat,
        priority: UILayoutPriority = .required
    ) -> AppLayoutAnchorConstraintCollection {
        let size = CGSize(width: constant, height: constant)
        return pinConstraintSize(to: size, priority: priority)
    }
}
