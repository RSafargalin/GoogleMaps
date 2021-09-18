//
//  Constant.swift
//  GMaps
//
//  Created by Ruslan Safargalin on 27.08.2021.
//

import Foundation
import UIKit

struct Constant {
    
    // MARK: - Sizes
    
    enum Sizes: CGFloat {
        case TextField = 44,
             Label = 20
        
        enum Default: CGFloat {
            
            case spacing = 15
            
            enum Button: CGFloat {
                case TapAreaSize = 44.0
                
                enum AddProductToCartButton: CGFloat {
                    case width = 88,
                         height = 44
                }
            }
            
            enum CollectionView {
                enum Reviews: CGFloat {
                    case height = 230
                    
                    enum Item: CGFloat {
                        case height = 200
                    }
                }
            }
            
            enum Icon: CGFloat {
                enum CreditCard: CGFloat {
                    case width = 36,
                         height = 24
                }
                
                case ProductPrice = 24
            }
            
            enum Layer: CGFloat {
                case cornerRadius = 10
            }
        }
    }
    
    // MARK: - Margins
    
    enum Margins: CGFloat {
        case TextFieldFromLabel = 15
    }
}
