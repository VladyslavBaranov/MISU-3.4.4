//
//  DragUtils.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 02.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

enum DragAllDirection: EnumKit {
    case up
    case left
    case right
    case down
}

protocol DragDelegate {
    func scrollDidDragWith(direction: DragAllDirection, scrollView: UIScrollView)
}
