//
//  mapperLevel.swift
//  rogue

import Foundation
import data
import domain

public struct LevelMapper {
    public static func toDTO(_ level: Level) -> LevelDTO {
        return LevelDTO(rooms: level.rooms.map(RoomMapper.toDTO),
                        corridors: level.corridors.map(CorridorMapper.toDTO),
                        exitPosition: PositionMapper.toDTO(level.exitPosition),
                        player: PlayerMapper.toDTO(level.player),
                        enemies: level.enemies.map(EnemyMapper.toDTO),
                        items: level.items.mapKeys(PositionMapper.toDTO).mapValues(ItemMapper.toDTO),
                        levelNumber: level.levelNumber,
                        gameMap: GameMapMapper.toDTO(level.gameMap),
                        exploredPositions: Set(level.exploredPositions.map(PositionMapper.toDTO)))
    }
    
    public static func toDomain(_ dto: LevelDTO) -> Level {
        let level = Level(
            dto.rooms.map(RoomMapper.toDomain),
            dto.corridors.map(CorridorMapper.toDomain),
            PositionMapper.toDomain(dto.exitPosition),
            PlayerMapper.toDomain(dto.player),
            dto.enemies.map(EnemyMapper.toDomain),
            dto.items.mapKeys(PositionMapper.toDomain).mapValues(ItemMapper.toDomain),
            dto.levelNumber,
            GameMapMapper.toDomain(dto.gameMap)
        )
        
        level.exploredPositions = Set(dto.exploredPositions.map(PositionMapper.toDomain))
        return level
    }
}

extension Dictionary {
    func mapKeys<T>(_ transform: (Key) throws -> T) rethrows -> [T: Value] {
        var result = [T: Value]()
        for (key, value) in self {
            result[try transform(key)] = value
        }
        return result
    }
}

struct RoomMapper {
    static func toDTO(_ room: Room) -> RoomDTO {
        RoomDTO(topRight: PositionMapper.toDTO(room.topRight),
                lowLeft: PositionMapper.toDTO(room.lowLeft),
                doors: room.doors.map(DoorMapper.toDTO))
    }
    
    static func toDomain(_ dto: RoomDTO) -> Room {
        Room(PositionMapper.toDomain(dto.topRight),
             PositionMapper.toDomain(dto.lowLeft),
             dto.doors.map(DoorMapper.toDomain))
    }
}

struct CorridorMapper {
    static func toDTO(_ corridor: Corridor) -> CorridorDTO {
        CorridorDTO(route: corridor.route.map(PositionMapper.toDTO))
    }

    static func toDomain(_ dto: CorridorDTO) -> Corridor {
        return Corridor(route: dto.route.map(PositionMapper.toDomain))
    }
}

struct PositionMapper {
    static func toDTO(_ position: Position) -> PositionDTO {
        PositionDTO(x: position.x, y: position.y)
    }

    static func toDomain(_ dto: PositionDTO) -> Position {
        Position(dto.x, dto.y)
    }
}

struct DoorMapper {
    static func toDTO(_ door: Door) -> DoorDTO {
        DoorDTO(position: PositionMapper.toDTO(door.position),
                direction:  DirectionMapper.toDTO(door.direction),
                color: ColorMapper.toDTO(door.color),
                isUnlocked: door.isUnlocked)
    }
    static func toDomain(_ dto: DoorDTO) -> Door {
        Door(PositionMapper.toDomain(dto.position),
             DirectionMapper.toDomain(dto.direction),
             ColorMapper.toDomain(dto.color),
             isUnlocked: dto.isUnlocked)
    }
}

struct DirectionMapper {
    static func toDTO(_ direction: Direction) -> DirectionDTO {
        return DirectionDTO(rawValue: direction.rawValue)!
    }

    static func toDomain(_ dto: DirectionDTO) -> Direction {
        return Direction(rawValue: dto.rawValue)!
    }
}

struct ColorMapper {
    static func toDTO(_ color: Color) -> ColorDTO {
        return ColorDTO(rawValue: color.rawValue)!
    }

    static func toDomain(_ dto: ColorDTO) -> Color {
        return Color(rawValue: dto.rawValue)!
    }
}

struct PlayerMapper {

    static func toDTO(_ player: Player) -> PlayerDTO {
        return PlayerDTO(characteristics: CharacteristicsMapper.toDTO(player.characteristics),
                         backpack: BackpackMapper.toDTO(player.backpack),
                         weapon: player.weapon.map { ItemMapper.toDTO($0) },
                         buffs: BuffManagerMapper.toDTO(player.buffManager),
                         isAsleep: player.isAsleep)
    }

    static func toDomain(_ dto: PlayerDTO) -> Player {
        let weapon: Weapon? = {
            guard let weaponDTO = dto.weapon else { return nil }
            guard case let .weapon(typeDTO) = weaponDTO.type else { return nil }
            let type = WeaponTypeMapper.toDomain(typeDTO)
            let damage = weaponDTO.damage ?? Int.random(in: type.baseDamage)
            return Weapon(weaponType: type, damage: damage)
        }()

        return Player(characteristics: CharacteristicsMapper.toDomain(dto.characteristics),
                      backpack: BackpackMapper.toDomain(dto.backpack),
                      weapon: weapon,
                      buffManager: BuffManagerMapper.toDomain(dto.buffs),
                      isAsleep: dto.isAsleep)
    }
}

struct CharacteristicsMapper {
    static func toDTO(_ characteristics: Characteristics) -> CharacteristicsDTO {
        return CharacteristicsDTO(position: PositionMapper.toDTO(characteristics.position),
                           maxHealth: characteristics.maxHealth,
                           health: characteristics.health,
                           agility: characteristics.agility,
                           strength: characteristics.strength)
    }

    static func toDomain(_ dto: CharacteristicsDTO) -> Characteristics {
        return Characteristics(position: PositionMapper.toDomain(dto.position),
                        maxHealth: dto.maxHealth,
                        health: dto.health,
                        agility: dto.agility,strength: dto.strength)
    }
}

public struct BackpackMapper {

    public static func toDTO(_ backpack: Backpack) -> BackpackDTO {
        var itemsDTO: [ItemCategoryDTO: [ItemDTO]] = [:]

        for (category, items) in backpack.items {
            let categoryDTO = ItemCategoryMapper.toDTO(category)
            itemsDTO[categoryDTO] = items.map { ItemMapper.toDTO($0) }
        }

        return BackpackDTO(items: itemsDTO,
                           totalTreasureValue: backpack.totalTreasureValue)
    }

    public static func toDomain(_ dto: BackpackDTO) -> Backpack {
        var items: [ItemCategory: [any ItemProtocol]] = [:]

        for (categoryDTO, itemsDTO) in dto.items {
            let category = ItemCategoryMapper.toDomain(categoryDTO)
            items[category] = itemsDTO.map { ItemMapper.toDomain($0) }
        }

        return Backpack(items, dto.totalTreasureValue)
    }
}

public struct ItemMapper {

    public static func toDTO(_ item: any ItemProtocol) -> ItemDTO {
        switch item {
        case let food as Food:
            return ItemDTO(type: .food(FoodTypeMapper.toDTO(food.foodType)))
        case let weapon as Weapon:
            return ItemDTO(type: .weapon(WeaponTypeMapper.toDTO(weapon.weaponType)),
                           damage: weapon.damage)
        case let scroll as Scroll:
            return ItemDTO(type: .scroll(ScrollTypeMapper.toDTO(scroll.scrollType)),
                           value: scroll.value)
        case let elixir as Elixir:
            return ItemDTO(type: .elixir(ElixirTypeMapper.toDTO(elixir.elixirType)),
                           value: elixir.value,
                           duration: elixir.duration)
        case let treasure as Treasure:
            return ItemDTO(type: .treasure(TreasureTypeMapper.toDTO(treasure.treasureType)))
        case let key as Key:
            return ItemDTO(type: .key(ColorMapper.toDTO(key.keyColor)),
                           color: ColorMapper.toDTO(key.keyColor))
        default:
            return ItemDTO()
        }
    }

    public static func toDomain(_ dto: ItemDTO) -> any ItemProtocol {
        switch dto.type {
        case .food(let foodTypeDTO):
            return Food(foodType: FoodTypeMapper.toDomain(foodTypeDTO))
        case .weapon(let weaponTypeDTO):
            let weaponType = WeaponTypeMapper.toDomain(weaponTypeDTO)
            let damage = dto.damage ?? Int.random(in: weaponType.baseDamage)
            return Weapon(weaponType: weaponType, damage: damage)
        case .scroll(let scrollTypeDTO):
            let type = ScrollTypeMapper.toDomain(scrollTypeDTO)
            let value = dto.value ?? Int.random(in: type.effectValue)
            return Scroll(scrollType: type, value: value)
        case .elixir(let elixirTypeDTO):
            let type = ElixirTypeMapper.toDomain(elixirTypeDTO)
            let value = dto.value ?? Int.random(in: type.effectValue)
            let duration = dto.duration ?? 60
            return Elixir(elixirType: type, value: value, duration: duration)
        case .treasure(let treasureTypeDTO):
            return Treasure(treasureType: TreasureTypeMapper.toDomain(treasureTypeDTO))
        case .key(let colorDTO):
            return Key(keyColor: ColorMapper.toDomain(colorDTO))
        }
    }
}

public struct ItemCategoryMapper {
    public static func toDTO(_ category: ItemCategory) -> ItemCategoryDTO {
        return ItemCategoryDTO(rawValue: category.rawValue)!
    }
    public static func toDomain(_ dto: ItemCategoryDTO) -> ItemCategory {
        return ItemCategory(rawValue: dto.rawValue)!
    }
}

public struct FoodTypeMapper {
    public static func toDTO(_ type: FoodType) -> FoodTypeDTO {
        return FoodTypeDTO(rawValue: type.rawValue)!
    }

    public static func toDomain(_ dto: FoodTypeDTO) -> FoodType {
        return FoodType(rawValue: dto.rawValue)!
    }
}

public struct ElixirTypeMapper {
    public static func toDTO(_ type: ElixirType) -> ElixirTypeDTO {
        return ElixirTypeDTO(rawValue: type.rawValue)!
    }

    public static func toDomain(_ dto: ElixirTypeDTO) -> ElixirType {
        return ElixirType(rawValue: dto.rawValue)!
    }
}

public struct ScrollTypeMapper {
    public static func toDTO(_ type: ScrollType) -> ScrollTypeDTO {
        return ScrollTypeDTO(rawValue: type.rawValue)!
    }

    public static func toDomain(_ dto: ScrollTypeDTO) -> ScrollType {
        return ScrollType(rawValue: dto.rawValue)!
    }
}

public struct WeaponTypeMapper {
    public static func toDTO(_ type: WeaponType) -> WeaponTypeDTO {
        return WeaponTypeDTO(rawValue: type.rawValue)!
    }

    public static func toDomain(_ dto: WeaponTypeDTO) -> WeaponType {
        return WeaponType(rawValue: dto.rawValue)!
    }
}

public struct TreasureTypeMapper {
    public static func toDTO(_ type: TreasureType) -> TreasureTypeDTO {
        return TreasureTypeDTO(rawValue: type.rawValue)!
    }

    public static func toDomain(_ dto: TreasureTypeDTO) -> TreasureType {
        return TreasureType(rawValue: dto.rawValue)!
    }
}

public struct BuffManagerMapper {
    public static func toDTO(_ manager: BuffManager) -> BuffsDTO {
        return BuffsDTO(health: manager.buffs.health.map { ElixirBufMapper.toDTO($0) },
                        agility: manager.buffs.agility.map { ElixirBufMapper.toDTO($0) },
                        strength: manager.buffs.strength.map { ElixirBufMapper.toDTO($0) })
    }

    public static func toDomain(_ dto: BuffsDTO) -> BuffManager {
        let buffs = Buffs(health: dto.health.map { ElixirBufMapper.toDomain($0) },
                          agility: dto.agility.map { ElixirBufMapper.toDomain($0) },
                          strength: dto.strength.map { ElixirBufMapper.toDomain($0) })
        return BuffManager(buffs: buffs)
    }
}

public struct ElixirBufMapper {
    public static func toDTO(_ buf: ElixirBuf) -> ElixirBufDTO {
        return ElixirBufDTO(statIncrease: buf.statIncrease,
                            effectEnd: buf.effectEnd.timeIntervalSince1970)
    }

    public static func toDomain(_ dto: ElixirBufDTO) -> ElixirBuf {
        return ElixirBuf(statIncrease: dto.statIncrease,
                         effectEnd: Date(timeIntervalSince1970: dto.effectEnd))
    }
}

public struct ItemTypeMapper {

    public static func toDTO(_ type: ItemType) -> ItemTypeDTO {
        switch type {
        case .food(let foodType): return .food(FoodTypeMapper.toDTO(foodType))
        case .weapon(let weaponType): return .weapon(WeaponTypeMapper.toDTO(weaponType))
        case .scroll(let scrollType): return .scroll(ScrollTypeMapper.toDTO(scrollType))
        case .elixir(let elixirType): return .elixir(ElixirTypeMapper.toDTO(elixirType))
        case .treasure(let treasureType): return .treasure(TreasureTypeMapper.toDTO(treasureType))
        case .key(let color): return .key(ColorMapper.toDTO(color))
        }
    }

    public static func toDomain(_ dto: ItemTypeDTO) -> ItemType {
        switch dto {
        case .food(let foodTypeDTO): return .food(FoodTypeMapper.toDomain(foodTypeDTO))
        case .weapon(let weaponTypeDTO): return .weapon(WeaponTypeMapper.toDomain(weaponTypeDTO))
        case .scroll(let scrollTypeDTO): return .scroll(ScrollTypeMapper.toDomain(scrollTypeDTO))
        case .elixir(let elixirTypeDTO): return .elixir(ElixirTypeMapper.toDomain(elixirTypeDTO))
        case .treasure(let treasureTypeDTO): return .treasure(TreasureTypeMapper.toDomain(treasureTypeDTO))
        case .key(let colorDTO): return .key(ColorMapper.toDomain(colorDTO))
        }
    }
}

struct EnemyMapper {

    static func toDTO(_ enemy: EnemyProtocol) -> EnemyDTO {
        let typeDTO = EnemyTypeMapper.toDTO(enemy.type)
        let characteristicsDTO = CharacteristicsMapper.toDTO(enemy.characteristics)
        var isResting: Bool? = nil
        var wasFirstAttacked: Bool? = nil
        var depictsItem: Bool? = nil
        var disguisedItemType: ItemTypeDTO? = nil

        if let ogre = enemy as? Ogre {
            isResting = ogre.getIsResting()
        }
        if let vampire = enemy as? Vampire {
            wasFirstAttacked = vampire.getWasFirstAttacked()
        }
        if let mimic = enemy as? Mimic {
            depictsItem = mimic.depictsItem
            disguisedItemType = ItemTypeMapper.toDTO(mimic.disguisedItemType)
        }

        return EnemyDTO(type: typeDTO,
                        characteristics: characteristicsDTO,
                        hostility: enemy.hostility,
                        isVisible: enemy.isVisible,
                        indexRoom: enemy.indexRoom,
                        isResting: isResting,
                        wasFirstAttacked: wasFirstAttacked,
                        depictsItem: depictsItem,
                        disguisedItemType: disguisedItemType)
    }

    static func toDomain(_ dto: EnemyDTO) -> Enemy {
        let characteristics = CharacteristicsMapper.toDomain(dto.characteristics)
        let type = EnemyTypeMapper.toDomain(dto.type)

        let enemy: Enemy = {
            switch type {
            case .zombie:
                return Zombie(characteristics: characteristics, hostility: dto.hostility)
            case .vampire:
                let vampire = Vampire(characteristics: characteristics, hostility: dto.hostility)
                if let wasAttacked = dto.wasFirstAttacked {
                    vampire.setWasFirstAttacked(wasAttacked)
                }
                return vampire
            case .ghost:
                return Ghost(characteristics: characteristics, hostility: dto.hostility)
            case .ogre:
                let ogre = Ogre(characteristics: characteristics, hostility: dto.hostility)
                ogre.setIsResting(dto.isResting!)
                return ogre
            case .snakeMage:
                return SnakeMage(characteristics: characteristics, hostility: dto.hostility)
            case .mimic:
                let mimic = Mimic(characteristics: characteristics, hostility: dto.hostility)
                if let depicts = dto.depictsItem {
                    mimic.depictsItem = depicts
                }
                if let disguised = dto.disguisedItemType {
                    mimic.disguisedItemType = ItemTypeMapper.toDomain(disguised)
                }
                return mimic
            }
        }()
        enemy.isVisible = dto.isVisible
        enemy.indexRoom = dto.indexRoom
        return enemy
    }
}

public struct EnemyTypeMapper {
    public static func toDTO(_ type: EnemyType) -> EnemyTypeDTO {
        return EnemyTypeDTO(rawValue: type.rawValue)!
    }

    public static func toDomain(_ dto: EnemyTypeDTO) -> EnemyType {
        return EnemyType(rawValue: dto.rawValue)!
    }
}

public struct GameMapMapper {
    public static func toDTO(_ gameMap: GameMap) -> GameMapDTO {
        return GameMapDTO(walkablePositions: Set(gameMap.walkablePositions.map(PositionMapper.toDTO)),
                          visibleTiles: Set(gameMap.visibleTiles.map(PositionMapper.toDTO)),
                          seenTiles: Set(gameMap.seenTiles.map(PositionMapper.toDTO)))
    }

    public static func toDomain(_ dto: GameMapDTO) -> GameMap {
        return GameMap(Set(dto.walkablePositions.map(PositionMapper.toDomain)),
                       Set(dto.visibleTiles.map(PositionMapper.toDomain)),
                       Set(dto.seenTiles.map(PositionMapper.toDomain)))
    }
}
