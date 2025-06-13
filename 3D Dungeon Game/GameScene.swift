//
//  GameScene.swift
//  3D Dungeon Game
//
//  Created by Carson Wood on 4/28/25.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var player: SKSpriteNode!
      var hasKey = false
      var summonButton: SKSpriteNode!
      var golem: SKSpriteNode?
      var golemHasBrokenDoor = false
    var backgroundMusicPlayer: AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = .zero
        
        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // loop forever
                backgroundMusicPlayer?.volume = 0.5
                backgroundMusicPlayer?.play()
            } catch {
                print("Failed to load background music: \(error)")
            }
        }
        // Room size
        let tileSize = CGSize(width: 16, height: 16)
        let numCols = 10
        let numRows = 7
        let worldWidth = CGFloat(numCols) * tileSize.width
        let worldHeight = CGFloat(numRows) * tileSize.height
        
        // Setup Camera FIRST
        let cameraNode = SKCameraNode()
        self.camera = cameraNode
        addChild(cameraNode)
        cameraNode.setScale(0.5)
        cameraNode.position = CGPoint(x: worldWidth / 2, y: worldHeight / 2)
        
        // NOW build world
        setupWorld()
        placeGrass()
        setupPlayer()
        setupControls()
        setupBed()
        setupBookshelf()
        setupKey()
        setupTextBox()
        setupActionBox()
    }
    
    func setupWorld() {
        let tileSize = CGSize(width: 16, height: 16)
        
        // Room size in tiles
        let numCols = 10
        let numRows = 7
        
        // World size based on room
        let worldWidth = CGFloat(numCols) * tileSize.width
        let worldHeight = CGFloat(numRows) * tileSize.height
        
        // 🌿 Call your new improved grass tiling function
        placeGrass()
        
        // Lay down floor tiles
        for row in 0..<numRows {
            for col in 0..<numCols {
                let floorTile = SKSpriteNode(imageNamed: "floor")
                floorTile.size = tileSize
                floorTile.position = CGPoint(
                    x: CGFloat(col) * tileSize.width + tileSize.width / 2,
                    y: CGFloat(row) * tileSize.height + tileSize.height / 2
                )
                floorTile.zPosition = -1
                addChild(floorTile)
            }
        }

        for col in -1...numCols {
            // ✅ Place bottom wall (no skip here)
            placeWall(x: col, y: -1)

            // ✅ Place top wall — skip for door
            if col == numCols / 2 {
                continue // skip center tile for door on TOP row
            }
            placeWall(x: col, y: numRows)
        }

        // Left and right walls
        for row in 0..<numRows {
            placeWall(x: -1, y: row)
            placeWall(x: numCols, y: row)
        }

        setupDoor()
    }
    
    
    
    func placeWall(x: Int, y: Int) {
        let tileSize = CGSize(width: 16, height: 16)
        let wallTile = SKSpriteNode(imageNamed: "wall")
        wallTile.size = tileSize
        wallTile.position = CGPoint(
            x: CGFloat(x) * tileSize.width + tileSize.width / 2,
            y: CGFloat(y) * tileSize.height + tileSize.height / 2
        )
        wallTile.zPosition = 0
        wallTile.name = "wall"
        wallTile.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
        wallTile.physicsBody?.isDynamic = false
        addChild(wallTile)
    }
    
    func placeGrass() {
        let tileSize = CGSize(width: 16, height: 16)

        let worldTilesWide = Int(size.width / tileSize.width)
        let worldTilesHigh = Int(size.height / tileSize.height)

        let rangeX = -worldTilesWide...worldTilesWide
        let rangeY = -worldTilesHigh...worldTilesHigh

        for row in rangeY {
            for col in rangeX {
                let grassTypes = ["grass1", "grass2"]
                let randomGrass = grassTypes.randomElement()!

                let grassTile = SKSpriteNode(imageNamed: randomGrass)
                grassTile.size = tileSize
                grassTile.position = CGPoint(
                    x: CGFloat(col) * tileSize.width + tileSize.width / 2,
                    y: CGFloat(row) * tileSize.height + tileSize.height / 2
                )
                grassTile.zPosition = -3
                addChild(grassTile)
            }
        }
    }
    
    func setupDoor() {
        let tileSize = CGSize(width: 16, height: 16)

        let door = SKSpriteNode(imageNamed: "door")
        door.size = tileSize
        door.name = "door"

        // Door at middle of top wall
        let doorX = CGFloat(5) * tileSize.width + tileSize.width / 2
        let doorY = CGFloat(7) * tileSize.height + tileSize.height / 2

        door.position = CGPoint(x: doorX, y: doorY)
        door.zPosition = 1

        // 🚪 Add solid body
        door.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
        door.physicsBody?.isDynamic = false

        addChild(door)
    }
    
    func setupPlayer() {
        let tileSize = CGSize(width: 16, height: 16)
        
        player = SKSpriteNode(imageNamed: "player")
        player.size = tileSize
        player.name = "player"
        
        // Center player in middle of room
        let playerX = CGFloat(5) * tileSize.width + tileSize.width / 2
        let playerY = CGFloat(3) * tileSize.height + tileSize.height / 2
        
        player.position = CGPoint(x: playerX, y: playerY)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        addChild(player)
    }
    
    func setupControls() {
        guard let camera = self.camera else { return }
        
        let buttonSize = CGSize(width: 50, height: 50)
        let buttonAlpha: CGFloat = 0.5
        
        let baseX = -size.width / 2 + 100
        let baseY = -size.height / 2 + 150
        
        // Up Button
        let upButton = SKSpriteNode(imageNamed: "upArrow")
        upButton.size = buttonSize
        upButton.alpha = buttonAlpha
        upButton.name = "up"
        upButton.position = CGPoint(x: baseX, y: baseY + 60)
        camera.addChild(upButton)
        
        // Down Button
        let downButton = SKSpriteNode(imageNamed: "downArrow")
        downButton.size = buttonSize
        downButton.alpha = buttonAlpha
        downButton.name = "down"
        downButton.position = CGPoint(x: baseX, y: baseY - 60)
        camera.addChild(downButton)
        
        // Left Button
        let leftButton = SKSpriteNode(imageNamed: "leftArrow")
        leftButton.size = buttonSize
        leftButton.alpha = buttonAlpha
        leftButton.name = "left"
        leftButton.position = CGPoint(x: baseX - 60, y: baseY)
        camera.addChild(leftButton)
        
        // Right Button
        let rightButton = SKSpriteNode(imageNamed: "rightArrow")
        rightButton.size = buttonSize
        rightButton.alpha = buttonAlpha
        rightButton.name = "right"
        rightButton.position = CGPoint(x: baseX + 60, y: baseY)
        camera.addChild(rightButton)
    }
    

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let worldLocation = touch.location(in: self)
    let nodesAtTouch = self.nodes(at: worldLocation)
    
    for node in nodesAtTouch {
        switch node.name {
        case "bookshelf":
            textLabel.text = "You read a forbidden spell..."
            unlockSummonButton()
        case "summonGolem":
            summonGolem()
        default: break
            }
        }
        
        for node in nodes(at: worldLocation) {
            if let name = node.name {
                var targetPosition = player.position
                
                switch name {
                case "up":
                    targetPosition.y += 16
                case "down":
                    targetPosition.y -= 16
                case "left":
                    targetPosition.x -= 16
                case "right":
                    targetPosition.x += 16
                default:
                    break
                }
                
                if canMove(to: targetPosition) {
                    player.position = targetPosition
                }
            }
        }
    }
    
    
    
    func setupBed() {
        let tileSize = CGSize(width: 16, height: 16)
        
        let bed = SKSpriteNode(imageNamed: "bed")
        bed.size = tileSize
        bed.name = "bed"
        
        // Place bed near bottom of room
        let bedX = CGFloat(5) * tileSize.width + tileSize.width / 2
        let bedY = CGFloat(1) * tileSize.height + tileSize.height / 2
        
        bed.position = CGPoint(x: bedX, y: bedY)
        
        bed.physicsBody = SKPhysicsBody(rectangleOf: tileSize)
        bed.physicsBody?.isDynamic = false
        addChild(bed)
    }
    
    func setupBookshelf() {
        let bookshelf = SKSpriteNode(imageNamed: "bookshelf")
        bookshelf.size = CGSize(width: 16, height: 16)
        bookshelf.name = "bookshelf"

        // Place near top-left of room
        let tileSize = CGSize(width: 16, height: 16)
        let shelfX = CGFloat(2) * tileSize.width + tileSize.width / 2
        let shelfY = CGFloat(5) * tileSize.height + tileSize.height / 2

        bookshelf.position = CGPoint(x: shelfX, y: shelfY)
        bookshelf.zPosition = 1
        addChild(bookshelf)

        bookshelf.physicsBody = SKPhysicsBody(rectangleOf: bookshelf.size)
        bookshelf.physicsBody?.isDynamic = false
    }
    
    func setupKey() {
        let tileSize = CGSize(width: 16, height: 16)
        
        let key = SKSpriteNode(imageNamed: "key")
        key.size = tileSize
        key.name = "key"
        
        // Hide key under the bed
        let keyX = CGFloat(5) * tileSize.width + tileSize.width / 2
        let keyY = CGFloat(1) * tileSize.height + tileSize.height / 2
        
        key.position = CGPoint(x: keyX, y: keyY)
        key.zPosition = 0.5
        addChild(key)
    }
    
    func canMove(to newPosition: CGPoint) -> Bool {
        let nodesAtTarget = nodes(at: newPosition)
        
        for node in nodesAtTarget {
            if node.name == "wall" || (node.name == "door" && !hasKey) {
                return false // Wall or locked door blocks movement
            }
        }
        return true
    }
    
    var textLabel: SKLabelNode!

    func setupTextBox() {
        guard let camera = self.camera else { return }
        
        // Text Background
        let textBox = SKSpriteNode(color: .darkGray, size: CGSize(width: 250, height: 60))
        textBox.position = CGPoint(x: size.width/2 - 150, y: -size.height/2 + 50)
        textBox.zPosition = 100 // above world
        camera.addChild(textBox)
        
        // Text Label inside the Box
        textLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        textLabel.fontSize = 18
        textLabel.fontColor = .white
        textLabel.position = CGPoint.zero
        textLabel.zPosition = 101
        textLabel.text = "Escape the Dungeon!"
        textBox.addChild(textLabel)
    }
    
    func setupActionBox() {
        guard let camera = self.camera else { return }

        summonButton = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 40))
        summonButton.position = CGPoint(x: size.width / 2 - 120, y: -size.height / 2 + 130)
        summonButton.alpha = 0
        summonButton.name = "summonGolem"
        summonButton.zPosition = 100
        camera.addChild(summonButton)

        let summonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        summonLabel.fontSize = 14
        summonLabel.fontColor = .white
        summonLabel.text = "Summon Golem"
        summonLabel.position = CGPoint.zero
        summonLabel.zPosition = 101
        summonButton.addChild(summonLabel)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        enumerateChildNodes(withName: "bookshelf") { node, _ in
            if self.player.frame.intersects(node.frame) {
                self.textLabel.text = "You read a forbidden spell..."
                self.unlockSummonButton()
            }
        }
        if !hasKey {
            enumerateChildNodes(withName: "key") { node, _ in
                if self.player.frame.intersects(node.frame) {
                    self.hasKey = true
                    node.removeFromParent()
                    print("You picked up the key!")
                }
            }
        } else {
            enumerateChildNodes(withName: "door") { node, _ in
                if node.physicsBody != nil {
                    node.physicsBody = nil // 🚪 Remove door collision if you have the key
                    print("Door unlocked!")
                }
            }
        }
    }
    func unlockSummonButton() {
        summonButton.alpha = 1
        print("Summon button unlocked!")
    }

    func summonGolem() {
        let tileSize = CGSize(width: 16, height: 16)
        let golemSprite = SKSpriteNode(imageNamed: "golem")
        golemSprite.size = tileSize
        golemSprite.position = CGPoint(x: CGFloat(1) * tileSize.width + tileSize.width / 2,
                                       y: CGFloat(3) * tileSize.height + tileSize.height / 2)
        golemSprite.name = "golem"
        golemSprite.zPosition = 2
        addChild(golemSprite)
        self.golem = golemSprite

        // Define door target position again
        let doorX = CGFloat(5) * tileSize.width + tileSize.width / 2
        let doorY = CGFloat(7) * tileSize.height + tileSize.height / 2

        let dx = doorX - golemSprite.position.x
        let dy = doorY - golemSprite.position.y
        let moveToDoor = SKAction.moveBy(x: dx, y: dy, duration: 2.0)

        let breakDoor = SKAction.run {
            self.enumerateChildNodes(withName: "door") { node, _ in
                node.removeFromParent()
                self.textLabel.text = "The golem smashed the door!"
                self.golemHasBrokenDoor = true
            }
        }

        // 👣 After breaking, walk up and fade out
        let walkAway = SKAction.moveBy(x: 0, y: 16 * 3, duration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()

        let sequence = SKAction.sequence([
            moveToDoor,
            breakDoor,
            walkAway,
            fadeOut,
            remove
        ])
        golemSprite.run(sequence)
    }
}
