//
//  RxCocoa+UICollectionViewFlowLayout.swift
//  MERLin
//
//  Created by Giuseppe Lanza on 23/12/2018.
//  Copyright © 2018 Giuseppe Lanza. All rights reserved.
//

import RxCocoa
import RxSwift

public extension Reactive where Base: UICollectionViewFlowLayout {
    var itemSize: Binder<CGSize> {
        return Binder(base) {
            $0.itemSize = $1
        }
    }
    
    var headerReferenceSize: Binder<CGSize> {
        return Binder(base) {
            $0.headerReferenceSize = $1
        }
    }
    
    var footerReferenceSize: Binder<CGSize> {
        return Binder(base) {
            $0.footerReferenceSize = $1
        }
    }
}
