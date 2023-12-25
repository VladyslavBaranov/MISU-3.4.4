//
//  RecommendationSleep.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 05.08.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit
import Charts

class RecoSleepVC: ScrollPresentVC {
    let mainImage: UIImageView = .makeImageView(contentMode: .scaleAspectFill)
    let detailedLabelView: UIView = .createCustom(bgColor: .white, cornerRadius: Constants.cornerRadius)
    let detailedLabel: UILabel = .createTitle(text: "Detailed", fontSize: 16, color: .black, alignment: .left, numberOfLines: 999)
    let nextStack: UIStackView = .createCustom(axis: .vertical, alignment: .leading)
    let readNextLabel: UILabel = .createTitle(text: NSLocalizedString("Read next", comment: ""), fontSize: 16, weight: .semibold, color: .appDefault.blackKoliya)
    let nextTitleLabel: UILabel = .createTitle(text: NSLocalizedString("Next", comment: ""), fontSize: 16)
    let nextButton: UIButton = .createCustom(title: NSLocalizedString("Next", comment: ""), fontSize: 16)
    //CoolButton.init(title: NSLocalizedString("Next", comment: ""), fontSize: 16, textColor: .white, color: .appDefault.redNew, shadow: true)
    
    var reco: RecommendationSleepModel? {
        didSet {
            if let img = reco?.fullImageURL {
                mainImage.setImage(url: img, defaultImageName: "alarmDreamsCellBG")
            } else {
                mainImage.image = UIImage(named: "alarmDreamsCellBG")
            }
            titleLabel.text = reco?.title
            subTitleLabel.text = reco?.subtitle
            mainImage.contentMode = .scaleAspectFill
            if let str = reco?.text {
                // Fix testBigStr to str
                detailedLabel.attributedText = str.convertFromHTML()
            }
            nextReco = HealthDataController.shared.nextSleepRecommendation(after: reco)
        }
    }
    
    var nextReco: RecommendationSleepModel? = nil {
        didSet {
            if let nr = nextReco {
                nextTitleLabel.text = nr.title
                
                mainStack.addArrangedSubview(nextStack)
                nextStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: Constants.inset).isActive = true
                nextStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -Constants.inset).isActive = true
            } else {
                nextStack.removeFromSuperview()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nextReco = HealthDataController.shared.nextSleepRecommendation(after: reco)
    }
    
    @IBAction func nextAction() {
        print("asd")
        let nxt = self.nextReco
        let pvc = self.presentingViewController
        dismiss(animated: true) {
            let vc = RecoSleepVC()
            vc.reco = nxt
            pvc?.present(vc, animated: true)
        }
    }
    
    override func setUp() {
        super.setUp()
        bgImage.image = nil
        
        mainStack.insertArrangedSubview(mainImage, at: 0)
        mainStack.spacing = -Constants.inset
        mainStack.customBottomAnchorConstraint?.constant = -Constants.inset
        
        mainImage.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        mainImage.heightAnchor.constraint(equalTo: mainImage.widthAnchor, multiplier: 0.7).isActive = true
        
        titleLabel.removeFromSuperview()
        mainImage.addSubview(titleLabel)
        titleLabel.textAlignment = .natural
        
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.leadingAnchor.constraint(equalTo: mainImage.leadingAnchor, constant: Constants.inset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: -Constants.inset).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: mainImage.bottomAnchor, constant: -Constants.inset*3).isActive = true
        
        mainStack.addArrangedSubview(detailedLabelView)
        detailedLabelView.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        detailedLabelView.addSubview(detailedLabel)
        detailedLabel.customConstraints(alignment: .topLeading, on: detailedLabelView, inset: .init(const: Constants.inset*1.25))
        
        mainStack.setCustomSpacing(0, after: detailedLabelView)
        mainStack.addArrangedSubview(nextStack)
        //nextStack.bottomAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: -Constants.inset).isActive = true
        nextStack.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: Constants.inset).isActive = true
        nextStack.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: -Constants.inset).isActive = true
        
        nextStack.addArrangedSubview(readNextLabel)
        nextStack.addArrangedSubview(nextTitleLabel)
        nextStack.addArrangedSubview(nextButton)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        nextButton.widthAnchor.constraint(equalTo: nextStack.widthAnchor).isActive = true
    }
}

class RecoSleepCell: BestCVCell {
    var reco: RecommendationSleepModel? {
        didSet {
            if let img = reco?.preImageURL {
                bgImageView.setImage(url: img, defaultImageName: "alarmDreamsCellBG")
            } else {
                bgImageView.image = UIImage(named: "alarmDreamsCellBG")
            }
            titleLabel.text = reco?.title
            subTitleLabel.text = reco?.subtitle
            bgImageView.contentMode = .scaleAspectFill
        }
    }
    
    func cellSelected() {
        let vc = RecoSleepVC()
        vc.reco = reco
        controller()?.present(vc, animated: true)
    }
}

enum RecommendationSleepStruct: Int, EnumKit, CaseIterable {
    case alarmClock = 0
    case moreDreams = 1
    case qualitySleep = 2
    
    var localizedTitle: String {
        return NSLocalizedString(title, comment: "")
    }
    
    var localizedSubTitle: String {
        return NSLocalizedString(subTitle, comment: "")
    }
    
    var bgCellImage: UIImage? {
        return .init(named: bgCellImageName)
    }
    
    var title: String {
        switch self {
        case .alarmClock:
            return "Будильник"
        case .qualitySleep:
            return "Як покращити якість сну?"
        case .moreDreams:
            return "Як бачити більше снів?"
        }
    }
    
    var subTitle: String {
        switch self {
        case .alarmClock:
            return "Будильник"
        case .qualitySleep:
            return "Як покращити якість сну?"
        case .moreDreams:
            return "Як бачити більше снів?"
        }
    }
    
    var bgCellImageName: String {
        switch self {
        case .qualitySleep:
            return "qualityDreamCellBG"
        case .alarmClock:
            return "alarmDreamsCellBG"
        case .moreDreams:
            return "moreDreamsCellBG"
        }
    }
}


let testBigStr = """
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Document</title>
<style>
.text-wrapper {
width: 90%;
height: auto;
background: #ffffff;
color: #171926;
border-radius: 15px;
margin: 10px 0 10px 0;
}

p,
b {
font-family: Arial, Helvetica, sans-serif;
font-style: normal;
font-weight: normal;
line-height: 120%;
font-size: 16px;
margin-bottom: 20px;
text-align: left;
padding: 0 10px;
}

b {
font-weight: bold;
}

li {
margin: 0 0 10px 0;
font-size: 16px;
}
</style>
</head>

<body>
<div class="text-wrapper">
<p>
Для того щоб сон був якісний і максимально ефективний, важливо дотримуватися режиму. Необхідно лягати
спати
і вставати в один і той же час. Засинати найкраще між 22:30 та 23:30.</p>

<ul>
<li>
    <p>Налаштувати себе на легке засинання можна дотримуючись простих рекомендацій: </p>
</li>
<li>
    <p>Провітрюйте приміщення перед сном </p>
</li>
<li>
    <p>Відмовтесь від гаджетів за 1 годину до сну </p>
</li>
<li>
    <p>Не переїдайте та вечеряйте не менше ніж за 2 години до сну </p>
</li>
<li>
    <p>Світло від невеличних свічок допоможе мозку розслабитись та налаштуватись на сон </p>
</li>
</ul>
</div>
<p> Майже всі сни, які бачить людина, припадають на фазу швидкого сну. Щоб бачити більше снів дотримуйтесь
простих рекомендацій.
Провітрюйте приміщення перед сном та не переїдайте за 2 години до сну.</p>
<ul>
<li>
<p>Спогади з дитинства </p>
</li>
<li>
<p>Знайомі запахи з дитинства </p>
</li>
<li>
<p>Нова нескладна інформація </p>
</li>
<li>
<p>Концентрація на улюблених речах </p>
</li>
</ul>
<p> допоможуть покращити швидкий сон та бачити більше снів.</p>

<p>Намагайтеся відмовитися від стимуляторів та заспокійливих. Вони негативно впливають на загальний сон, його
якість та седативний ефект.
За годину до сну не відволікайтесь на гаджети, а відволічіть себе чимось, наприклад:</p>
<ul>
<li>
<p>фізичні активності </p>
</li>
<li>
<p>читання книг </p>
</li>
<li>
<p>спілкування з сім'єю чи прогулянка </p>
</li>
</ul>
<p>За 2 години до сну краще утриматись від смачненького. Саме фаза глибокого сну допомагає нам відчувати себе
бадьорими та сповненими сил."</p>
</div>
</body>

</html>
"""
