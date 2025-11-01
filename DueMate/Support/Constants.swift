//
//  Constants.swift
//  DueMate
//
//  Created by Kacey Kim on 6/10/25.
//

import Foundation

struct Constants {
    static let userID = 1
    
    static let categoryOptions = [
        RadioOption(title: "거실", value: "living", onImage: "ic_living", offImage: "ic_living_off"),
        RadioOption(title: "화장실", value: "washroom", onImage: "ic_washroom", offImage: "ic_washroom_off"),
        RadioOption(title: "세탁실", value: "laudry", onImage: "ic_laundry", offImage: "ic_laundry_off"),
        RadioOption(title: "부엌", value: "kitchen", onImage: "ic_kitchen", offImage: "ic_kitchen_off"),
        RadioOption(title: "침실", value: "bedroom", onImage: "ic_bedroom", offImage: "ic_bedroom_off"),
        RadioOption(title: "기타", value: "etc", onImage: "ic_etc", offImage: "ic_etc_off")
    ]
}
