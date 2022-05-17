//
//  ContentView.swift
//  OneButtonAR
//
//  Created by Nien Lam on 9/8/21
//
//  Altered by Eamon Goodman on 11/29/2021

import SwiftUI
import ARKit
import RealityKit
import Combine
import OSCKit
import AVFoundation


class ViewModel: ObservableObject {
    
    @Published var sliderValue: Float = 0

    let uiSignal = PassthroughSubject<UISignal, Never>()

    enum UISignal {
        case screenTapped
        case reset
        case cam
//        case x_on
//        case y_on
//        case z_on
//        case input_on
    }
}

struct ContentView : View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .onTapGesture {
                    viewModel.uiSignal.send(.screenTapped)
                }
            
            VStack(alignment: .leading, spacing: 35) {
                
                // Height slider
                Slider(value: $viewModel.sliderValue, in: 0...1)
                    .frame(width: 300, height: 0)
                    .rotationEffect(.degrees(-90.0), anchor: .bottomLeading)
                
            
                Button {
                    viewModel.uiSignal.send(.reset)
                } label: {
                    Label("Reset", systemImage: "gobackward")
                        .font(.system(.title))
                        .foregroundColor(.white)
                        .labelStyle(IconOnlyLabelStyle())
//                        .frame(width: 44, height: 44)
                }
                
                Button {
                    viewModel.uiSignal.send(.cam)
                } label: {
                    Label("Cam", systemImage: "camera.fill")
                        .font(.system(.title))
                        .foregroundColor(.white)
                        .labelStyle(IconOnlyLabelStyle())
//                        .frame(width: 44, height: 44)
                }
                
//              // Switches for OSC in / out
//                Button {
//                    viewModel.uiSignal.send(.x_on)
//                } label: {
//                    Label("X Out", systemImage: "x.circle")
//                        .font(.system(.title))
//                        .foregroundColor(.black)
// //                       .labelStyle(IconOnlyLabelStyle())
//                        .frame(width: 200, height: 44)
//                }
//
//                Button {
//                    viewModel.uiSignal.send(.y_on)
//                } label: {
//                    Label("Y Out", systemImage: "y.circle")
//                        .font(.system(.title))
//                        .foregroundColor(.black)
// //                      .labelStyle(IconOnlyLabelStyle())
//                        .frame(width: 200, height: 44)
//                }
//
//                Button {
//                    viewModel.uiSignal.send(.z_on)
//                } label: {
//                    Label("Z Out", systemImage: "z.circle")
//                        .font(.system(.title))
//                        .foregroundColor(.black)
// //                        .labelStyle(IconOnlyLabelStyle())
//                        .frame(width: 200, height: 44)
//                }
            
//                Button {
//                    viewModel.uiSignal.send(.input_on)
//                } label: {
//                    Label("Input", systemImage: "move.3d")
//                        .font(.system(.title))
//                        .foregroundColor(.black)
// //                        .labelStyle(IconOnlyLabelStyle())
//                        .frame(width: 200, height: 44)
//                }

            }
            
        
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding(50)
        }
        .edgesIgnoringSafeArea(.all)
        .statusBar(hidden: true)
    }
}

struct ARViewContainer: UIViewRepresentable {
    let viewModel: ViewModel

    func makeUIView(context: Context) -> ARView {
        SimpleARView(frame: .zero, viewModel: viewModel)
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}



class SimpleARView: ARView, OSCUdpClientDelegate, OSCUdpServerDelegate {
    var viewModel: ViewModel
    var arView:         ARView { return self }
    
    var originAnchor:   AnchorEntity!
    var pov:            AnchorEntity!
    
    var subscriptions = Set<AnyCancellable>()
    var collisionSubs: [Cancellable] = []
    
//    let planeModel = try! Entity.loadModel(named: "planet.usdz")
    
    var entity: ModelEntity!
    var entity2: ModelEntity!
    
    var obj1:  Entity!
    var obj2:  Entity!
    var obj3:  Entity!
    var obj4:  Entity!
    var obj5:  Entity!
    var obj6:  Entity!
    var obj7:  Entity!
    var obj8:  Entity!
    var obj9:  Entity!
    var obj10: Entity!
    var obj11: Entity!
    var obj12: Entity!
    
    var cam = true
    
    var xOn = true
    var yOn = true
    var zOn = true
    
    var ydist: Float = 0
    
//    var xin: Float = 1.0
//    var inputOn = false
    
    var client: OSCUdpClient!
    var server: OSCUdpServer!
    
    


    init(frame: CGRect, viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        // SET UP CLIENT
        client = OSCUdpClient(host: "10.23.11.46",
                              port: 8998,
                              delegate: self)
        
        server = OSCUdpServer(port: 8997,
                                  delegate: self)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        UIApplication.shared.isIdleTimerDisabled = true
        
        setupScene()
    }

    func setupScene() {
        
        // Create an anchor at scene origin.
        originAnchor = AnchorEntity(world: .zero)
        arView.scene.addAnchor(originAnchor)
        
        
        // Add pov entity that follows the camera.
        pov = AnchorEntity(.camera)
        arView.scene.addAnchor(pov)

        // Setup world tracking.
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        configuration.sceneReconstruction = .mesh
        arView.renderOptions = [.disableMotionBlur, .disableDepthOfField, .disablePersonOcclusion]
        arView.debugOptions.insert(.showSceneUnderstanding)
        arView.environment.sceneUnderstanding.options = .physics
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
//        configuration.planeDetection = [.horizontal, .vertical]
//        arView.environment.sceneUnderstanding.options.insert(.receivesLighting)
        arView.session.run(configuration)
        
        addImagePlane()
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj1) { event in
            do{try self.client.send(try OSCMessage(with:"/1", arguments: [] ))} catch {}
//            print("💥 1 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj2) { event in
            do{try self.client.send(try OSCMessage(with:"/2", arguments: [] ))} catch {}
//            print("💥 2 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj3) { event in
            do{try self.client.send(try OSCMessage(with:"/3", arguments: [] ))} catch {}
//            print("💥 3 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj4) { event in
            do{try self.client.send(try OSCMessage(with:"/4", arguments: [] ))} catch {}
//            print("💥 4 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj5) { event in
            do{try self.client.send(try OSCMessage(with:"/5", arguments: [] ))} catch {}
//            print("💥 5 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj6) { event in
            do{try self.client.send(try OSCMessage(with:"/6", arguments: [] ))} catch {}
//            print("💥 6 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj7) { event in
            do{try self.client.send(try OSCMessage(with:"/7", arguments: [] ))} catch {}
//            print("💥 7 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj8) { event in
            do{try self.client.send(try OSCMessage(with:"/8", arguments: [] ))} catch {}
//            print("💥 8 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj9) { event in
            do{try self.client.send(try OSCMessage(with:"/9", arguments: [] ))} catch {}
//            print("💥 9 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj10) { event in
            do{try self.client.send(try OSCMessage(with:"/10", arguments: [] ))} catch {}
//            print("💥 10 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj11) { event in
            do{try self.client.send(try OSCMessage(with:"/11", arguments: [] ))} catch {}
//            print("💥 11 ")
        })
        
        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
                                                      on: obj12) { event in
            do{try self.client.send(try OSCMessage(with:"/12", arguments: [] ))} catch {}
//            print("💥 12 ")
        })
        
        
//        collisionSubs.append(scene.subscribe(to: CollisionEvents.Began.self,
//                                                      on: entity2) { event in
// //            do{try self.client.send(try OSCMessage(with:"/12", arguments: [] ))} catch {}
//            print("💥 🎱 ")
//        })
        
        
//        let meshAnchors = arView.session.currentFrame?.anchors.compactMap({ $0 as? ARMeshAnchor })
//
//        collisionSubs.append(arView.scene.subscribe(to: CollisionEvents.Began.self,
//                                               on: meshAnchors as? EventSource) { event in
// //            do{try self.client.send(try OSCMessage(with:"/x", arguments: [] ))} catch {}
// //            if (  "impact > 0.5"  ) {
//            print("💥 MESH ")
// //           }
//        })
        
      
        
        // Called every frame.
        scene.subscribe(to: SceneEvents.Update.self) { event in
            self.renderLoop()
        }.store(in: &subscriptions)
        
        viewModel.uiSignal.sink { [weak self] in
            self?.processUISignal($0)
        }.store(in: &subscriptions)
        
        // Process slider value.
        viewModel.$sliderValue.sink { value in
            self.ydist = value
            self.entity.position.y = (value - 0.5) * 3
        }.store(in: &subscriptions)
    
    }
    

    func processUISignal(_ signal: ViewModel.UISignal) {
        switch signal {
            
        case .screenTapped:
            makeBall()
            
        case .reset:
            originAnchor.children.removeAll()
            addImagePlane()
            
        case .cam:
            cam = !cam
            
//        case .x_on:
//            xOn = !xOn
//
//        case .y_on:
//            yOn = !yOn
//
//        case .z_on:
//            zOn = !zOn
//
//        case .input_on:
//            inputOn = !inputOn
        }
    }
    
    
    func addImagePlane() {

        // CTRL BUBBLE
        let material = SimpleMaterial(color: .white.withAlphaComponent(0.8), isMetallic: true)
        entity = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [material])
        entity.transform.matrix = pov.transformMatrix(relativeTo: originAnchor)
        * float4x4(translation: [0.0, 0.0, -1.5])
        entity.generateCollisionShapes(recursive: false)
        arView.installGestures([.all], for: entity)
        entity.physicsBody = PhysicsBodyComponent(massProperties: .init(mass: 0.00, inertia: [0.0, 0.0, 0.0]),
                                                       material: .generate(),
                                                       mode: .kinematic)
        originAnchor.addChild(entity)


        // INSTRUMENT BOXES
        obj1  = makeBox(posX: 1.2, posY: -0.5, color: .green)
        originAnchor.addChild(obj1)
        obj2  = makeBox(posX: 1.2, posY: -1.7, color: .green)
        originAnchor.addChild(obj2)
        obj3  = makeBox(posX: 1.2, posY: -2.9, color: .green)
        originAnchor.addChild(obj3)
        obj4  = makeBox(posX: 1.2, posY: -4.1, color: .green)
        originAnchor.addChild(obj4)
        obj5  = makeBox(posX: 0.0, posY: -0.5, color: .blue)
        originAnchor.addChild(obj5)
        obj6  = makeBox(posX: 0.0, posY: -1.7, color: .blue)
        originAnchor.addChild(obj6)
        obj7  = makeBox(posX: 0.0, posY: -2.9, color: .blue)
        originAnchor.addChild(obj7)
        obj8  = makeBox(posX: 0.0, posY: -4.1, color: .blue)
        originAnchor.addChild(obj8)
        obj9  = makeBox(posX: -1.2, posY: -0.5, color: .red)
        originAnchor.addChild(obj9)
        obj10 = makeBox(posX: -1.2, posY: -1.7, color: .red)
        originAnchor.addChild(obj10)
        obj11 = makeBox(posX: -1.2, posY: -2.9, color: .red)
        originAnchor.addChild(obj11)
        obj12 = makeBox(posX: -1.2, posY: -4.1, color: .red)
        originAnchor.addChild(obj12)
        
        // for loading a model
//        entity = planeModel.clone(recursive: false)
//        entity.orientation = pov.orientation
//        entity.scale = SIMD3(repeating: 0.001)
    }
    
    // Helper method for making instrument boxes
    func makeBox(posX: Float, posY: Float, color: UIColor) -> Entity {
        let boxMesh  = MeshResource.generateBox(width: 0.2, height: 5.0, depth: 0.2)
        let material = SimpleMaterial(color: color.withAlphaComponent(0.6), isMetallic: true)
        let box = ModelEntity(mesh: boxMesh, materials: [material])
        box.position.x = posX
        box.position.z = posY
        box.generateCollisionShapes(recursive: false)
        box.physicsBody = PhysicsBodyComponent(massProperties: .default,
                                               material: .generate(),
                                               mode: .static)
        return box
    }
    
    func makeBall(){
        let material = SimpleMaterial(color: .white.withAlphaComponent(0.75), isMetallic: false)
        entity2 = ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [material])
        entity2.transform.matrix = pov.transformMatrix(relativeTo: originAnchor)
        * float4x4(translation: [0.0, 0.7, -1.2])
        entity2.generateCollisionShapes(recursive: false)
        entity2.physicsBody = PhysicsBodyComponent(massProperties: .init(mass: 5.0, inertia: [1.3, 1.3, 1.3]),
                                                   material: .generate(friction: 0.01, restitution: 1.7),
                                                       mode: .dynamic)
        originAnchor.addChild(entity2)
    }

    
    func renderLoop () {
        
        let position = entity.position(relativeTo: originAnchor)
//        print (position.x/2 + 0.5, position.y/2 + 0.5, position.z/2 + 0.5)
        
        do{
            if (xOn == true) {
                try client.send(try OSCMessage(with:"/x", arguments: [position.x/2 + 0.5]))
            }
            
            if (yOn == true) {
                try client.send(try OSCMessage(with:"/y", arguments: [1 - (position.z/2 + 0.5) ]))
            }
            
            if (zOn == true) {
                try client.send(try OSCMessage(with:"/z", arguments: [position.y + 0.5]))
            }
        } catch {print ("OSC ERROR")}
        
        if (cam == false) {
            arView.environment.background = .color(.black)
        }
        else{
            arView.environment.background = .cameraFeed()
        }
        
//        //spin
//        entity.orientation *= simd_quatf(angle: 0.01, axis: [0, 1, 0])
        
//        // move entity with OSC in (untested)
//            if (inputOn == true) {
//                try server.startListening()
//                entity.position.x = 5/xin
//            }
//            if (inputOn == false) {
//                server.stopListening()
//                entity.position.x = entity.position.x
//            }
    }
    
    
    
    // "CONFORM TO CLIENTS PROTOCOL"
    func client(_ client: OSCUdpClient,
                didSendPacket packet: OSCPacket,
                fromHost host: String?,
                port: UInt16?) {
//        print("client sent packet to \(client.host):\(client.port)")
    }

    func client(_ client: OSCUdpClient,
                didNotSendPacket packet: OSCPacket,
                fromHost host: String?,
                port: UInt16?,
                error: Error?) {
        print("client did not send packet to \(client.host):\(client.port)")
    }

    func client(_ client: OSCUdpClient,
                socketDidCloseWithError error: Error) {
        print("Client Error: \(error.localizedDescription)")
    }
    
    func server(_ server: OSCUdpServer,
                didReceivePacket packet: OSCPacket,
                fromHost host: String,
                port: UInt16) {
        print("Server did receive packet from \(host):\(port)")
//        guard let message = packet as? OSCMessage else { return }
//        let annotation = OSCAnnotation.annotation(for: message, style: .spaces, type: true)
//        xin = (annotation as NSString).floatValue
    }

    func server(_ server: OSCUdpServer,
                socketDidCloseWithError error: Error?) {
        if let error = error {
           print("Server did stop listening with error: \(error.localizedDescription)")
        } else {
           print("Server did stop listening")
        }
    }

    func server(_ server: OSCUdpServer,
                didReadData data: Data,
                with error: Error) {
        print("Server did read data with error: \(error.localizedDescription)")
    }
}
