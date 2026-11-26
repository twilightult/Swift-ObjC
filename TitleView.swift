import UIKit

// No disclaimer, no constraint list. Only the signature.
final class TitleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false

        let main = UILabel()
        main.text = "MC"
        main.textColor = UIColor(red: 0.17, green: 0.18, blue: 0.29, alpha: 1)
        main.font = .systemFont(ofSize: 34, weight: .heavy)
        main.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "SWIFT · OBJC"
        sub.textColor = UIColor(red: 0.48, green: 0.42, blue: 0.95, alpha: 1)
        sub.font = .systemFont(ofSize: 11, weight: .semibold)
        sub.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [main, sub])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 18)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
