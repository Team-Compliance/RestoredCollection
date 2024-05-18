local Translations = {}

local translationsTable = {
    collectible = {},
    trinket = {}
}

function Translations:AddTranslation(item, id, name, description, language)
    if item ~= "collectible" and item ~= "trinket" then return end
    if not translationsTable[item][language] then
        translationsTable[item][language] = {}
    end
    if type(id) == "number" and type(name) == "string" and type(description) == "string" then
        translationsTable[item][language][id] = {name, description}
    end
end

--ru
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS, "Каменные бомбы", "Каменный взрыв, +5 бомб", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS, "Пустые бомбы", "Спускаемся в подвал", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE, "Шахматная фигура", "Шахматный друг", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS, "Бомбы-кубики", "Рероллер предметов, +5 бомб", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE, "Ослиная челюсть", "Давай, подходи!", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH, "Менора", "Множитель выстрелов", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, "Древнее откровение", "Помни, что было раньше", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, "Сердце Вифании", "Аккумулятор веры", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, "Веревка Хранителя", "Выбей деньги из них!", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, "Счастливая семерка", "Удача благоволит смелым", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, "Пацифист", "Неси любовь, а не войну", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, "Безопасные бомбы", "Для твоего блага", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER, "Старая гильотина", "Новая точка зрения", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD, "Голова Макса", "Скорострельность ↑", "ru")
for i = 0, 5 do
    Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i, "Коробка с завтраком", "Переносной буфет", "ru")
end
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR, "Книга отчаяния", "Временная скорострельность ↑", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "Чаша со слезами", "Всплеск!", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, "Книга иллюзий", "Армия тебя", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, "Дробилка пилюль", "Раздай их всем!", "ru")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, "Вуду булавка", "Ай!", "ru")
Translations:AddTranslation("trinket", RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC, "Игровой кальмар", "Подтекающий приятель", "ru")

--spa
--Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS, "Stone Bombs", "Rock blast +5 bombs", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS, "Bombas de fogueo", "Entra al sótano", "Спускаемся в подвал", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE, "Rey en jaque", "Amigo ajedrezado", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS, "Bombas de dado", "+5 bombas, cambia tus objetos", "spa")
--Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE, "Donkey Jawbone", "Come at me!", "spa")
--Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH, "Menorah", "Shot multiplier", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, "Antigua Revelación", "Recuerda lo que solía haber", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, "Corazón de Beth", "Acumulador de fe", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, "La soga de Keeper", "¡Sácales todo el dinero!", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, "7 de la suerte", "La suerte favorece a la audacia", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, "Pacifista", "Haz el amor, no la guerra", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, "Bombas de seguridad", "Por tu propio bien, +5 bombas", "spa")
--Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER, "Ol' Lopper", "A new point of view", "spa")
--Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD, "Max's Head", "Tears up", "spa")
for i = 0, 5 do
    --Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i, "Lunch Box", "Portable buffet", "spa")
end
--Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR, "Book of Despair", "Temporary tears up", "spa")
--Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "Bowl of Tears", "Splash!", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, "Libro de las ilusiones", "Un ejército de ti", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, "Triturador de píldoras", "¡Dáselas a todos!", "spa")
Translations:AddTranslation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, "Pin de vudú", "Comparte tu dolor", "spa")
--Translations:AddTranslation("trinket", RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC, "Game Squid", "Leaky buddy", "spa")

local function ShowTranslation(queue, translationTable)
    local translations = translationTable[Options.Language]
    if translations then
        local translation = translations[queue.ID]
        if translation then
            Game():GetHUD():ShowItemText(translation[1], translation[2])
        end
    end
end

---@param player EntityPlayer
function Translations:onUpdate(player)
	if player.Parent then return end
    local data = player:GetData()
    if data.queueNow == nil and player.QueuedItem.Item then
        data.queueNow = player.QueuedItem.Item
        if data.queueNow:IsCollectible() then
            ShowTranslation(data.queueNow, translationsTable.collectible)
        elseif data.queueNow:IsTrinket() then
            ShowTranslation(data.queueNow, translationsTable.trinket)
        end
    elseif data.queueNow ~= nil and player.QueuedItem.Item == nil then
        data.queueNow = nil
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Translations.onUpdate)