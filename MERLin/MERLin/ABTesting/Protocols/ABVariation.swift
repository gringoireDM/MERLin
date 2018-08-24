//
//  ABVariation.swift
//  ABTestingManager
//
//  Created by Giuseppe Lanza on 09/03/2018.
//  Copyright © 2018 Gilt. All rights reserved.
//

import Foundation

/**
 Defining an experiment, as result of the activation you will have a variation.
 Use this variation to define the behavior of your experiment. An Object conforming
 ABVariation should have as many variable as expected from the ABTesting platform.
 
 Let's suppose that for the experiment "my_experiment" the variable "buy_button_title"
 has been defined. Your object should look like
 
 ```swift
 public struct MyExperimentVariation: ABVariation, Decodable {
    var id: String
    var key: String
 
    var buy_button_title: String
 }
 ```
 
 TheExperimentsManager will decode automatically the experiment in your variation object
 and the value of the custom variable will be returned as requested.
*/
public protocol ABVariation: Decodable {
    var id: String { get }
    var key: String { get }
    
    //Define all the expected variables. The ExperimentsManager will produce just variables
    //of type string. If you need any different type we recommend to write the Decodable
    //part yourself.
}
