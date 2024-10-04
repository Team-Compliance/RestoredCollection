if not EID then return end

-- Mod Icon (TODO)
EID:setModIndicatorName("Restored Collection")
local iconSprite = Sprite()
iconSprite:Load("gfx/eid_restored_icon.anm2", true)
--EID:addIcon("Restored Items Icon", "Icon", 0, 10, 9, 1, 1, iconSprite)
--EID:setModIndicatorIcon("Restored Items Icons")
EID:addIcon("ImmortalHeart", "Icon", 0, 10, 9, 1, 1, iconSprite)
EID:addIcon("SunHeart", "Icon", 1, 10, 9, 1, 1, iconSprite)
EID:addIcon("IllusionHeart", "Icon", 2, 10, 9, 1, 1, iconSprite)

-- Items
--Stone Bombs
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS,
    "{{Bomb}} +5 Bombs#Bombs create rock waves in all 4 cardinal directions#The rock waves can damage enemies, destroy objects, and reveal secret rooms",
    "Stone Bombs", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS,
    "{{Bomb}} +5 Bombas#Las bombas colocadas ahora generan olas de piedra en los 4 puntos cardinales al explotar#Las olas de piedra pueden dañar enemigos, destruir objetos y revelar salas secretas#+5 bombas",
    "Bombas de Piedra", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS,
    "{{Bomb}} +5 бомб#Бомбы теперь создают каменные волны во все 4-е основные стороны#Каменные волны могут наносить урон врагам, разрушать объекты и открывать секретные комнаты#+5 бомб",
    "Каменные бомбы", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS,
    "{{Bomb}} +5 Bombas#Bombas colocadas agora explodem e criam ondas de pedra em todas as 4 direções cardeais#As ondas de pedra podem causar dano aos inimigos, destruir objetos, e revelar salas secretas#+5 Bombas",
    "Bombas de Pedra", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS,
    "{{Bomb}} +5 Bombs#放置的炸弹现在会爆炸并在所有4个基本方向产生岩石波#岩石波可以伤害敌人，摧毁物体，并揭示隐藏房#+5炸弹", "岩石炸弹", "zh_cn")
--Blank Bombs
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS,
    "{{Bomb}} +5 Bombs#Bombs explode instantly, -50% bomb damage#Press {{ButtonRT}} + {{ButtonLB}} to place bombs normally#The player is immune from their own bombs#Bombs destroy enemy projectiles and knock back enemies",
    "Blank Bombs", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS,
    "{{Bomb}} +5 Bombas#Las bombas explotan inmediatamente. -50% daño de bomba#Pulsa {{ButtonRT}} + {{ButtonLB}} para poner bombas normales#El jugador es inmune a sus bombas#Las bombas que exploten eliminarán los disparos enemigos y empujarán a los enemigos cercanos",
    "Bombas de Fogueo", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS,
    "{{Bomb}} +5 бомб#Бомбы мгновенно взрываются, -50% урон от них#Нажмите кнопку {{ButtonRT}} + {{ButtonLB}}, чтобы разместить обычные бомбы#Игрок невосприимчив к урону от собственной бомбы#Размещенные бомбы уничтожают вражеские снаряды и отбрасывают врагов в радиусе",
    "Пустые бомбы", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS,
    "{{Bomb}} +5 Bombas#-50% de dano de bomba.#Pressione {{ButtonRT}} + {{ButtonLB}} para colocar bombas normais#O jogador é imune a dano de suas próprias bombas#Bombas colocadas destroem projetéis de inimigos e empurram os inimigos ao seu redor",
    "Bombas de Festim", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS,
    "{{Bomb}} +5 Bombs#炸弹立即爆炸。-50%炸弹伤害#按{{ButtonRT}} + {{ButtonLB}}放置普通炸弹。100%炸弹伤害#玩家对自己的炸弹免疫#放置的炸弹会摧毁敌人的抛射物并击退周围的敌人",
    "空白炸弹", "zh_cn")

--Checked Mate
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE,
    "Spawns a familiar that moves by jumping from tile to tile, dealing 20 damage to nearby enemies and 40 damage to enemies directly landed on",
    "Checked Mate", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE,
    "Создает фамильяра, который перемещается, прыгая с места на место, нанося 20 урона возле врагов и 40 урона при приземлении прямо на врагов",
    "Checked Mate", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE,
    "Genera un Rey de Ajedréz que saltará de cuadro en cuadro#Inflige 20 puntos de daño en área cada vez que aterriza#Si la pieza aterriza directamente sobre un enemigo, inflige 40 puntos de daño",
    "Rey en jaque", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE,
    "Gera um familiar que se movimenta pulando de quadrado em quadrado.#Causa 20 pontos de dano em área ao aterrissar.#Se o familiar aterrissar diretamente sobre um inimigo, causa 40 de dano.",
    "Xeque Mate", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE,
    "生成一个从方块到方块跳跃的宠物#每次着陆时造成20点范围伤害#如果宠物直接着陆在敌人上,造成40点伤害",
    "将军", "zh_cn")
if Sewn_API then
    Sewn_API:AddFamiliarDescription(
        RestoredCollection.Enums.Familiars.CHECKED_MATE.Variant,
        "Increases damage",
        "Increases damage further and range"
    )
end

--Dice Bombs
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS,
    "{{Bomb}} +5 Bombs#Bombs reroll pedestal items within its explosion radius#Has a 25% chance to destroy items instead of rerolling them#Holding certain dice actives will add additional effects",
    "Dice Bombs")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS,
    "{{Bomb}} +5 бомб#Бомбы меняют артефакты на пьедесталах в радиусе взрыва#25% шанс уничтожить пьедестал вместо замены артефакта#Имея определенные кубики, добавляются дополнительные еффекты",
    "Бомбы-кубики", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS,
    "{{Bomb}} +5 Bombas#Las explosiones cambiarán los pedestales de objetos que se encuentren dentro de su radio de explosión#Poseer ciertos objetos activos de dados otorgará efectos adicionales",
    "Bombas de dados", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS,
    "{{Bomb}} +5 Bombas#Explosões agora irão rerolar os pedestais de item pegos na área de explosão#Tem 25% de chance de destruir items ao invés de rerolar eles#Possuir certos items ativos de dados adicionará efeitos adicionais",
    "Bombas de Dado", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS,
    "{{Bomb}} +5 Bombs#爆炸将重置爆炸范围内的基座物品#持有某些骰子物品将添加额外效果", "骰子炸弹", "zh_cn")
--Book of Despair
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR,
    "↑ {{Tears}} +100% Tears up when used#Less effective for each concecutive use in the same room", "Book of Despair", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR,
    "↑ {{Tears}} Lágrimas +100% al usarlo#El efecto es menos efectivo con cada uso en la misma habitación",
    "El Libro de la Desesperación", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR,
    "↑ {{Tears}} +100% к скорострельности при использовании#Эффект слабее при каждом использовании в той же комнате",
    "Книга отчаяния", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR,
    "↑ {{Tears}} +100% Lágrimas quando usado#O efeito é menos efetivo à cada uso na mesma sala", "Livro do Desespero", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR,
    "↑ {{Tears}} +100% 射速#在同一房间使用后效果会逐渐减弱", "绝望之书", "zh_cn")
EID:assignTransformation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR, "12") -- Bookworm

--Bowl of Tears
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS,
    "Fires a cluster of tears#Each tear shot by Isaac increases item charge by one", "Bowl of Tears", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS,
    "Otorga una recarga por cada lágrima que dispare el jugador#Al usarse, dispara una ráfaga de lágrimas en la dirección seleccionada",
    "Tazón de Lágrimas", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS,
    "Стреляет скоплением слёз#Каждый выстрел слезы Исааком увеличивает заряд артефакта на один", "Чаша слёз", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS,
    "Atira um aglomerado de lágrimas#Adiciona uma carga por cada lágrima que Isaac dispara", "Tigela de Lágrimas",
    "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS,
    "发射一团眼泪#每发射一颗眼泪，充能就会加一", "眼泪之碗", "zh_cn")

--Donkey Jawbone
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE,
    "{{BleedingOut}} When taking damage, Isaac does a spin attack that deals 8x damage, inflicts bleed, and blocks projectiles",
    "Donkey Jawbone", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE,
    "Al recibir daño, realizarás un ataque giratorio, dañando a los enemigos cercanos y bloqueando proyectiles por un momento",
    "Quijada de burro", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE,
    "{{BleedingOut}} При получении урона Исаак совершает круговую атаку, которая наносит 8x урона, вызывает кровотечение и блокирует снаряды",
    "Ослиная челюсть", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE,
    "Quando for atingido, esse item causa que você faça um ataque giratório, que causa dano em inimigos próximos e bloqueia projéteis por um curto período",
    "Maxilar de Burro", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE,
    "受到伤害时，会进行旋风斩，对附近的敌人造成伤害并在短时间内阻挡抛射物", "驴下颚骨", "zh_cn")

--Menorah
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH,
    "Menorah familiar that gives multishot proportionate to the number of lit candles#↓ {{Tears}} -0.5x tear rate for each candle lit#Getting hit with 7 lit candles bursts 8 blue flames and makes Isaac unable to shoot for a little while",
    "Menorah", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH,
    "Genera un familiar Menorah#El número de lágirmas Isaac aumentan en función de las velas encendidas, máximo 7 velas#↓ {{Tears}} Reduce el tiempo de disparo entre dos y lo multiplica por la suma de las velas encendidas mas 1 #Recibir daño con 7 velas encendidas hace estallar 8 llamas azules y hace que Isaac no pueda disparar por un rato",
    "Menorah", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH,
    "Фамильяр подсвечник, который дает доп. слезы пропорционально количеству зажженных свечей#↓ {{Tears}} -0.5 скорострельности за каждую заженную свечу#Получая урон с 7 заженными свечами разбрасывает 8 синих огней и делает Исаака неспособным стрелять некоторое время",
    "Менора", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH,
    "Gera um familiar menorah que causa as lágrimas de Isaac serem multiplicadas pelo número de velas acesas#↓ {{Tears}} Reduz o tempo de disparo de cada lágrima pela metade e multiplica pela soma das velas acesas mais 1#Ser atingido com as 7 velas acesas gera 8 chamas azuis e impede Isaac de atirar lágrimas por um tempinho",
    "Menorah", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH,
    "生成一个烛台宠物，使玩家发射眼泪数量乘火焰数量#受伤增加火焰数量#↓ {{Tears}} 减半射击延迟，然后乘火焰数量加1#7个火焰受伤爆炸#爆炸产生8个蓝色火焰并使玩家无法射击一小段时间",
    "烛台", "zh_cn")

if Sewn_API then
    Sewn_API:AddFamiliarDescription(
        RestoredCollection.Enums.Familiars.MENORAH.Variant,
        "Higher fire rate per flame",
        "Higher fire rate per flame#You can keep firing even with no flames"
    )
end

--Ancient Revelation
local AncientDesc =
"Grants flight#{{ImmortalHeart}} +2 Immortal Hearts#↑ {{Shotspeed}} +0.48 Shot Speed#↑ {{Tears}} +1 Tears#Spectral tears#Tears turn 90 degrees to target enemies that they may have missed"
local AncientDescRu =
"Даёт полёт#{{ImmortalHeart}} +2 бессмертных сердца#↑ {{Shotspeed}} +0.48 к скорости полёта слезы#↑ {{Tears}} +1 к скорострельности#Спектральные слёзы#Слёзы поворачиваются на 90 градусов, чтобы попасть во врагов, которых они могли пропустить"
local AncientDescSpa =
"Otorga vuelo#{{ImmortalHeart}} +2 Corazones inmortales#↑ {{Shotspeed}} Vel. de tiro +0.48#↑ {{Tears}} Lágrimas +1#Lágrimas espectrales#Las lágrimas girarán en 90 grados hacia un enemigo si es que fallan"
local AncientDescPt_Br =
"Concede voo#{{ImmortalHeart}} +2 Corações imortais#↑ {{Shotspeed}} +0.48 Vel. de tiro#↑ {{Tears}} +1 Lágrimas#Lágrimas espectrais#Lágrimas viram 90 graus para atingir inimigos que elas não acertaram"
local AncientDescZh_Cn =
"获得飞行能力#{{ImmortalHeart}} +2 不朽之心#↑ {{Shotspeed}} +0.48 泪速#↑ {{Tears}} +1 射速#幽灵眼泪#眼泪转向90度以瞄准未击中的敌人"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, AncientDesc,
    "Ancient Revelation", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, AncientDescRu,
    "Древнее откровение", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, AncientDescSpa,
    "Antigua Revelación", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, AncientDescPt_Br,
    "Revelação Anciã", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, AncientDescZh_Cn,
    "远古启示", "zh_cn")
EID:assignTransformation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, "10") -- Seraphim

--Beth's Heart
local BHDescEng =
"{{Throwable}} Throwable familiar that converts soul and black hearts to active item charges, stores up to 6 charges#{{HalfSoulHeart}}: 1 charge#{{SoulHeart}}: 2 charges#{{BlackHeart}}: 3 charges#Press {{ButtonRT}} to supply the charges to the active item"
local BHDescSpa =
"{{Throwable}} Genera un familiar lanzable#Almacena corazones de alma y corazones negros para usarlos como cargas para el objeto activo, máximo 6 cargas#{{HalfSoulHeart}}: 1 carga#{{SoulHeart}}: 2 cargas#{{BlackHeart}}: 3 cargas#Presiona {{ButtonRT}} para suministrar las cargas al objeto activo"
local BHDescRu =
"{{Throwable}} Бросаемый спутник который превращает синие и чёрные сердца в заряды для активируемых предметов, максимум 6 зарядов#{{HalfSoulHeart}}: 1 заряд#{{SoulHeart}}: 2 заряда#{{BlackHeart}}: 3 заряда#Нажав {{ButtonRT}} заряжается активный предмет"
local BHDescPt_Br =
"{{Throwable}} Gera um familiar arremessável#Armazenas corações de alma e negros para usar como carga para o seu item ativo, máximo de 6 cargas#{{HalfSoulHeart}}: 1 carga#{{SoulHeart}}: 2 cargas#{{BlackHeart}}: 3 cargas##Aperta {{ButtonRT}} para fornecer as cargas para o item ativo"
local BHDescZh_cn =
"{{Throwable}} 生成一个可投掷的跟班#储存魂心和黑心作为道具的充能，最多6次充能#{HalfSoulHeart}}: 1次充能#{{SoulHeart}}: 2次充能#{{BlackHeart}}: 3次充能#按{{ButtonRT}}为激活 道具提供充能"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescEng, "Beth's Heart", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescSpa, "El corazón de Beth",
    "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescRu, "Сердце Вифании", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescPt_Br, "Coração de Bethany",
    "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescZh_cn, "伯大尼之心",
    "zh_cn")

--Illusion Hearts - Book Of Illusions
local BOIDesc = "Spawns an illusion clone when used#Illusion clones are the same character as you and die in one hit"
local BOIDescSpa =
"Genera un clon de ilusión tras usarlo#El clon es el mismo personaje que el tuyo#Morirá al recibir un golpe"
local BOIDescRu =
"При использовании создаёт иллюзию# Иллюзия - это тот же персонаж, что и ваш, которые умирают от одного удара"
local BOIDescPt_Br =
"Gera um clone de ilusão quando usado#Clones de ilusão são o mesmo personagem que você e morrem em um golpe"
local BOIDescZh_cn =
"使用时生成一个幻影克隆#幻影克隆与你相同并且一击即死"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, BOIDesc, "Book of Illusions",
    "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, BOIDescSpa,
    "El Libro de las ilusiones", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, BOIDescRu, "Книга иллюзий",
    "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, BOIDescPt_Br,
    "Livro das Ilusões", "pt_br")
EID:assignTransformation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, "12")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, BOIDescZh_cn, "幻影之书",
    "zh_cn")

 --todo have the description actively change if playing as keeper
--Keeper's Rope
local KeepersRopeDescEng =
"Grants flight#↓ {{Luck}} -2 Luck down#{{Coin}} When enemies spawn they have a 25% chance to contain 1-3 pennies which can extracted by damaging them#!!! The pennies disappear after 3 seconds"
local KeepersRopeDescRu =
"Даёт полёт#↓ {{Luck}} -2 к удаче#{{Coin}} Когда монстры появляются у них есть 25% шанс иметь 1-3 монет, которые выпадают при нанесении им урона#!!! Монеты исчезают через 3 секунды"
local KeepersRopeDescSpa =
"Puedes volar##{{Luck}} Suerte -2 si no se está jugando como {{Player14}} Keeper o {{Player33}} Tainted Keeper#{{Coin}} Cuando se generen los enemigos, tendrán un 25% de tener 1-3 monedas #Las puedes obtener al hacerles daño#{{Player14}} Con Keeper los enemigos tendrán 16.7% de tener 1-2 monedas#{{Player33}} Con Tainted Keeper Contaminado los enemigos tendrán un 12.5% de tener 1 moneda#!!! Las monedas desaparecen después de 3 segundos"
local KeepersRopeDescPt_Br =
"Concede voo#↓ {{Luck}} -2 sorte caso não esteja jogando como {{player14}} Keeper ou {{Player33}} Tainted Keeper#{{Coin}} Quando monstros surgem, possuem 25% de chance de conter entre 1-3 moedas que podem ser extraidas ao causar dano a eles#{{Player14}} Ao jogar de Keeper, monstros tem 16.7% de chance de conter 1-2 moedas#{{Player33}} Ao jogar de Tainted Keeper, monstros tem 12.5% de chance de conter 1 moeda#!!! As moedas desaparecerão após 3 segundos"
local KeepersRopeDescZh_cn =
"获得飞行能力#↓ {{Luck}} 如果不是{{Player14}} 店长或{{Player33}} 里店长则-2幸运#{{Coin}} 当怪物生成时，它们有25%的几率包含1-3个硬币，可以通过对它们造成伤害来提取#{{Player14}} 作为店长时，怪物有16.7%的几率包含1-2个硬币#{{Player33}} 作为里店长时，怪物有12.5%的几率包含1个硬币#!!! 硬币在3秒后消失"

local KeepersRopeDesc_Keeper = {
    en_us = "Grants flight#{{Coin}} When enemies spawn they have a 16.7% chance to contain 1-2 pennies which can extracted by damaging them#!!! The pennies disappear after 3 seconds",
    ru = "Даёт полёт#{{Coin}} Когда монстры появляются у них есть 16.7% шанс иметь 1-2 монет, которые выпадают при нанесении им урона#!!! Монеты исчезают через 3 секунды",
    spa = "Puedes volar##{{Luck}} Suerte -2 si no se está jugando como {{Player14}} Keeper o {{Player33}} Tainted Keeper#{{Coin}} Cuando se generen los enemigos, tendrán un 25% de tener 1-3 monedas #Las puedes obtener al hacerles daño#{{Player14}} Con Keeper los enemigos tendrán 16.7% de tener 1-2 monedas#{{Player33}} Con Tainted Keeper Contaminado los enemigos tendrán un 12.5% de tener 1 moneda#!!! Las monedas desaparecen después de 3 segundos",
    pt_br = "Concede voo#↓ {{Luck}} -2 sorte caso não esteja jogando como {{player14}} Keeper ou {{Player33}} Tainted Keeper#{{Coin}} Quando monstros surgem, possuem 25% de chance de conter entre 1-3 moedas que podem ser extraidas ao causar dano a eles#{{Player14}} Ao jogar de Keeper, monstros tem 16.7% de chance de conter 1-2 moedas#{{Player33}} Ao jogar de Tainted Keeper, monstros tem 12.5% de chance de conter 1 moeda#!!! As moedas desaparecerão após 3 segundos",
    zn_cn = "获得飞行能力#↓ {{Luck}} 如果不是{{Player14}} 店长或{{Player33}} 里店长则-2幸运#{{Coin}} 当怪物生成时，它们有25%的几率包含1-3个硬币，可以通过对它们造成伤害来提取#{{Player14}} 作为店长时，怪物有16.7%的几率包含1-2个硬币#{{Player33}} 作为里店长时，怪物有12.5%的几率包含1个硬币#!!! 硬币在3秒后消失"
}

local KeepersRopeDesc_TKeeper = {
en_us = "Grants flight#{{Coin}} When enemies spawn they have a 12.5% chance to contain 1 penny which can extracted by damaging them#!!! The penny disappears after 3 seconds",
ru = "Даёт полёт#{{Coin}} Когда монстры появляются у них есть 12.5% шанс иметь 1 монету, которая выпадают при нанесении им урона#!!! Монета исчезает через 3 секунды",
spa = "Puedes volar##{{Luck}} Suerte -2 si no se está jugando como {{Player14}} Keeper o {{Player33}} Tainted Keeper#{{Coin}} Cuando se generen los enemigos, tendrán un 25% de tener 1-3 monedas #Las puedes obtener al hacerles daño#{{Player14}} Con Keeper los enemigos tendrán 16.7% de tener 1-2 monedas#{{Player33}} Con Tainted Keeper Contaminado los enemigos tendrán un 12.5% de tener 1 moneda#!!! Las monedas desaparecen después de 3 segundos",
pt_br = "Concede voo#↓ {{Luck}} -2 sorte caso não esteja jogando como {{player14}} Keeper ou {{Player33}} Tainted Keeper#{{Coin}} Quando monstros surgem, possuem 25% de chance de conter entre 1-3 moedas que podem ser extraidas ao causar dano a eles#{{Player14}} Ao jogar de Keeper, monstros tem 16.7% de chance de conter 1-2 moedas#{{Player33}} Ao jogar de Tainted Keeper, monstros tem 12.5% de chance de conter 1 moeda#!!! As moedas desaparecerão após 3 segundos",
zn_cn = "获得飞行能力#↓ {{Luck}} 如果不是{{Player14}} 店长或{{Player33}} 里店长则-2幸运#{{Coin}} 当怪物生成时，它们有25%的几率包含1-3个硬币，可以通过对它们造成伤害来提取#{{Player14}} 作为店长时，怪物有16.7%的几率包含1-2个硬币#{{Player33}} 作为里店长时，怪物有12.5%的几率包含1个硬币#!!! 硬币在3秒后消失",
}

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, KeepersRopeDescEng, "Keeper's Rope")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, KeepersRopeDescRu,
    "Веревка Хранителя", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, KeepersRopeDescSpa,
    "La soga de Keeper", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, KeepersRopeDescPt_Br,
    "Corda do Keeper", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, KeepersRopeDescZh_cn,
    "店长的绳子", "zh_cn")



local function KeeperRopeConditions(descObj)
    if descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE then
        local player = Game():GetNearestPlayer(descObj.Entity.Position)
        return player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B
    end
    return false
end

local function KeepersRopeKeeperModifierCallback(descObj)
    local player = Game():GetNearestPlayer(descObj.Entity.Position)
    local lang = EID:getLanguage()
    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER then
        descObj.Description = KeepersRopeDesc_Keeper[lang] or KeepersRopeDesc_Keeper["en_us"]
    end
    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
        descObj.Description = KeepersRopeDesc_TKeeper[lang] or KeepersRopeDesc_TKeeper["en_us"]
    end
    return descObj
end

EID:addDescriptionModifier("Keeper's Rope Keeper Modifier", KeeperRopeConditions, KeepersRopeKeeperModifierCallback)

--Lucky seven
local Sevendesc =
"Whenever any pickup count ends in a 7, Isaac has a chance to shoot golden tears that turn enemies into special slot machines#The chance is increased the more pickup counts end in 7"
local SevendescRu =
"Всякий раз, когда один из предметов игрока заканчивается на 7, у Исаака есть шанс выстрелить золотыми слезами, которые при попадании во врагов превращают их в особые игровые автоматы"
local SevendescSpa =
"Si el numero de cualquier recolectable del jugador termina en 7, se tendrá la posibilidad de lanzar una lágrima dorada que genera una máquina tragaperras especial al golpear a un enemigo"
local SevendescPt_Br =
"Se o número de qualquer um dos números de pickup do jogador acabar em um 7, Isaac terá a chance de atirar uma lágrima dourada que cria uma máquina Caça-níquel especial quando atingir um monstro"
local SevendescZh_cn =
"当玩家的任何掉落物数量以7结尾时，玩家有机会发射金色眼泪，击中怪物时生成特殊老虎机"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, Sevendesc, "Lucky Seven")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, SevendescRu, "Счастливая семерка",
    "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, SevendescSpa, "7 de la suerte",
    "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, SevendescPt_Br, "Sete Sortudo",
    "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, SevendescZh_cn, "幸运七",
    "zh_cn")

--Pacifist
local Pacdesc =
"Combat rooms are cleared after 30 seconds of not damaging any enemies#Spawns chests at the start of each floor for each special room left unexplored on the previous floor"
local PacdescRu =
"Дает награду предметами на следующем этаже в зависимости от того, сколько комнат вы не зачистили на текущем"
local PacdescSpa =
"Genera recolectables en el siguiente piso en función a cuantas habitaciones no limpiaste en el piso actual"
local PacdescPt_Br =
"Gera pickups de recompensa no início do próximo andar baseado em quantas salas você não completou no andar anterior"
local PacdescZh_cn =
"根据上一层未清理的房间数量，在下一层开始时给予掉落物奖励"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, Pacdesc, "Pacifist")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, PacdescRu, "Пацифист", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, PacdescSpa, "Pacifista", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, PacdescPt_Br, "Pacifista", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, PacdescZh_cn, "和平主义者", "zh_cn")


---Pill crusher
local PCDesc =
"{{Pill}} Gives a random pill when picked up#Increase pill drop rate when held#Consumes currently held pill and applies an effect to the entire room depending on the type of pill"
local PCDescSpa =
"{{Pill}} Genera una píldora aleatoria al tomarlo#Las píldora aparecen con mas frecuencia#Consume la píldora que posees y aplica un efecto a la sala, basado en la píldora"
local PCDescRu =
"{{Pill}} Дает случайную пилюлю#Увеличивает шанс появления пилюль#Использует текущую пилюлю и накладывает зависимый от её типа эффект на всю комнату"
local PCDescPt_Br =
"{{Pill}} Gera uma pílula aleatória quando pego#{{Pill}} Aumenta a taxa de queda de pílulas enquanto segurado# Consome a sua pílula atual e aplica um efeito na sala inteira dependendo no tipo de pílula consumida"
local PCDescZh_cn =
"{{Pill}} 拾取时给予一个随机药丸#持有时增加药丸掉落率#消耗当前持有的药丸并根据药丸类型对整个房间施加效果"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDesc, "Pill Crusher", "en_us")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescSpa, "Triturador de Pildoras",
    "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescRu, "Дробилка пилюль", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescPt_Br,
    "Triturador de Pílulas", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, PCDescZh_cn, "药丸粉碎机", "zh_cn")


--Safety Bombs
local SBDesc = "{{Bomb}} +5 Bombs#Placed bombs will not explode until the player leaves its explosion radius"
local SBDescSpa = "{{Bomb}} +5 Bombas#Las bombas que coloques no explotarán hasta que te alejes de su radio de explosión"
local SBDescRu = "{{Bomb}} +5 бомб#Размещенные бомбы не взорвутся, пока игрок не покинет радиус взрыва"
local SBDescPt_Br = "{{Bombs}} +5 Bombas#Bombas não irão explodir até o jogador sair de sua área de explosão"
local SBDescZh_cn = "{{Bomb}} +5 炸弹#放置的炸弹直到玩家离开爆炸范围才会爆炸"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, SBDesc, "Safety Bombs")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, SBDescSpa, "Bombas de Seguridad",
    "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, SBDescRu, "Безопасные бомбы", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, SBDescPt_Br, "Bombas de Segurança",
    "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, SBDescZh_cn, "安全炸弹", "zh_cn")

--Voodoo Pin
local VDPdesc =
"Throwable voodoo pin that swaps Isaac's hitbox with enemy hitboxes#Lasts until enemy is dead#Hitting bosses makes it last for 5 seconds"
local VDPdescRu =
"Бросаемая булавка вуду, которая меняет хитбоксы Исаака и врага местами#Еффект длится до смерти врага#При подании в босса действует 5 секунд"
local VDPdescSpa =
"Isaac sostiene un pin de vudú que puede ser lanzado al enemigo#Si el pin golpea a un monstruo, su hitbox será intercambiada por la de Isaac hasta que muera#Si golpea a un jefe, durará 5 segundos"
local VDPdescPt_Br =
"Isaac segura um alfinete de voodoo que pode ser atirado em um inimigo#Se o alfinete acertar um monstro, a sua hitbox será invertida com a hitbox do Isaac#Dura até o inimigo morrer#Acertar chefes fará o efeito durar por apenas 5 segundos"
local VDPdescZh_cn =
"玩家拿着一个可以扔向敌人的巫毒针#如果针刺中怪物，它的碰撞箱将与玩家的碰撞箱交换，直到怪物死亡#击中boss会持续5秒"

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, VDPdesc, "Voodoo Pin")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, VDPdescRu, "Вуду булавка", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, VDPdescSpa, "Pin de vudú", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, VDPdescPt_Br, "Alfinete de Voodoo",
    "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, VDPdescZh_cn, "巫毒针", "zh_cn")

--Lunch Box
for i = 0, 5 do
    EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i,
        "Charged by collecting {{Heart}} Red Hearts#{{Collectible664}} Spawns a 'food' item#{{Warning}} Disappears after 6 uses",
        "Lunch Box")
    EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i,
        "Заряжается подпором {{Heart}} красных сердец#При использовании спавнит один из 'съедобных' предметов#{{Warning}} Исчезает после 6 использований",
        "Коробка c ланчем", "ru")
    EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i,
        "Se carga colleccionando {{Heart}} corazones rojos#Cuando se usa, aparece uno de los objetos de 'comida'#Desaparece después de 6 usos",
        "Caja del almuerzo", "spa")
    EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i,
        "通过收集{{Heart}}红心充能#使用时生成一个“食物”物品#使用6次后消失",
        "午餐盒", "zh_cn")
end

--Max's Head
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD,
    "↑ {{Tears}} +1.5 tears up#Every 4th tear is shot with low fire delay", "Max's Head")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD,
    "↑ {{Tears}} +1.5 к скорострельности#Каждая 4-я слеза выстреливает с меньшей задержкой выстрела", "Голова Макса", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD,
    "↑ {{Tears}} +1.5 lagrimas hacia arriba#Cada cuarta lagrima, el disparo acelera", "Cabeza de Max", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD,
    "↑ {{Tears}} +1.5 lágrimas#Toda quarta lágrima é mais veloz", "Cabeça do Max", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD,
    "^{{Tears}}+1.5射速#第4滴眼泪射速更快", "麦克斯的头", "zh_cn")



--Ol' Lopper
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER,
    "Disconnects Isaac's head from his body allowing it to move like Mr. Maw head#The head deals 10.5x Isaac's damage per second", "Ol' Lopper")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER,
    "Отсоединяет голову Исаака от его тела, позволяя ей двигаться как голова Мистера Пасть#Голова наносит 10.5-кратный урон Исаака в секунду", "Ол 'Лоппер", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER,
    "Desconecta la cabeza de Isaac de su cuerpo, permitiéndole moverla como la cabeza de Sr. Maw", "Ol' Looper", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER,
    "Desconecta a cabeça de Isaac do seu corpo, permitindo com que se mova como a cabeça de Mr. Maw", "Ol' Looper",
    "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER,
    "将玩家的头与身体分离，使其可以像大嘴头尸头一样移动", "老割头", "zh_cn")

--Pumpkin Mask
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK,
    "Fires a rapid inacurate strike of seeds at a set interval#Seeds do 40% of the player's damage", "Pumpkin Mask")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK,
    "Выпускает быстрые неточные выстрелы семенами в определенные интервалы#Семена наносят 40% урона игрока",
    "Тыквенная маска", "ru")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK,
    "Dispara rápidamente y sin precisión una ráfaga de semillas#Las semillas están disparadas en un rango de 30º desde la dirección de disparo",
    "Mascara de Calabaza", "spa")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK,
    "Dispara rapidamente e com baixa precisão uma série de sementes#Sementes são disparadas dentro de 30° da direção do disparo",
    "Máscara de Abóbora", "pt_br")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK,
    "快速不准确地发射种子#种子在射击方向的30°范围内发射", "南瓜面具", "zh_cn")

--Melted Candle
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE,
"↑ {{Tears}} +0.5 tears#{{Burning}} Gives an aura that burns enemies#{{Burning}} 30% chance to shoot a wax tear that burns and slows enemies#{{Luck}} 70% chance with 28 luck#The flame sometimes grows, giving {{Tears}} +1.5 tears and replacing wax tears with a larger aura#Large flame lasts up to 5 seconds",
    "Melted Candle")
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE, 
"↑ {{Tears}} +0.5 к скорострельности#{{Burning}} Дает ауру, которая сжигает врагов#{{Burning}} 30% шанс выстрелить восковой слезой, которая сжигает и замедляет врагов#{{Luck}} 70% шанс с 28 удачей#Пламя иногда выростает, давая {{Tears}} +1.5 к скорострельности и заменяя восковые слезы более крупной аурой#Большое пламя длится до 5 секунд",
    "Расплавленная свеча", "ru")
--[[EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE, 
"↑ Lágrimas hacia arriba +0.5 cuando un fuego pequeño es encendido#↑ Lágrimas arriba +1.5 cuando un fuego grande es encendido#10% de encender un fuego grande cuando un fuego pequeño es encendido#Cuando un fuego pequeño es encendido, 30% de disparar una lágrima de cera que ralentiza y prende fuego a enemigos#Después de 5 segundos sin disparar, el fuego de la vela disminuye", 
"Vela derretida", "spa")]]

--Tammy's Tail
EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC,
"↑ {{Tears}} +0.5 tears#{{Heart}} +20% chance for heart pickups to be double hearts#{{UnknownHeart}} +50% chance for pickups to be hearts for the room after taking damage",
    "Tammy's Tail")

EID:addCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC,
"↑ {{Tears}} +0.5 к скорострельности#{{Heart}} +20% шанс, что сердца будут двойными сердцами#{{UnknownHeart}} +50% шанс, что предметы будут сердцами в комнате после получения урона",
    "Хвост Тамми", "ru")

--Game Squid
EID:addTrinket(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "{{Slow}} 8% chance to a shoot slowing tear that leaves black creep on impact #{{Luck}} 100% chance at 18 luck")
EID:addTrinket(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "{{Slow}} 8% шанс выстрелить замедляющей слезой, которая оставляет черную лужу при столкновении", "Игровой кальмар", "ru")
EID:addTrinket(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "{{Slow}} 8% de disparar una lágrima ralentizada que deja un charco negro cuando impacta", "", "spa")
EID:addTrinket(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "{{Slow}} 8% de chance de disparar uma lágrima que desascelera e deixa uma poça preta no impacto", "Lula dos Games", "pt_br")
EID:addTrinket(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "{{Slow}} 8%发射减速眼泪，在击中时留下黑色水迹", "游戏鱿鱼", "zh_cn")
EID:addGoldenTrinketMetadata(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "↑ +3% on top for every trinket multiplier")
EID:addGoldenTrinketMetadata(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "↑ +3% дополнительно за каждый множитель брелка", nil, nil, "ru")
EID:addGoldenTrinketMetadata(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "↑ +3% cuando se usa con cualquier trinket de multiplicador", nil, nil, "spa")
EID:addGoldenTrinketMetadata(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "↑ +3% de chance por cada multiplicador de trinkets", nil, nil, "pt_br")
EID:addGoldenTrinketMetadata(RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
    "↑每个饰品乘数上限+3%", nil, nil, "zh_cn")

local function ActOfContritionConditions(descObj)
    return descObj.ObjType == 5 and descObj.ObjVariant == 100 and descObj.ObjSubType == CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION and TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "ActOfContritionImmortal") == 1
end

local function ActOfContritionModifierCallback(descObj)
    descObj.Description = descObj.Description:gsub("Eternal", "Immortal")
    descObj.Description = descObj.Description:gsub("вечное", "бессмертное")
    descObj.Description = descObj.Description:gsub("eterno", "inmortales")
    descObj.Description = descObj.Description:gsub("Eterno", "imortais")
    descObj.Description = descObj.Description:gsub("永恒之心", "不朽之心")
    return descObj
end

EID:addDescriptionModifier("Immortal Act of Contrition Modifier", ActOfContritionConditions, ActOfContritionModifierCallback)