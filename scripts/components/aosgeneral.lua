local AoSGeneral = Class(function(self, inst)
    self.inst = inst
    self.skins = { "DEFAULT", }
end)

local function SetSkinBuild(inst)
    local index = inst.skinindex
    local skins = inst.components.aosgeneral.skins

    if index == 1 then
        inst.AnimState:SetBuild(inst.prefab)
    else
        local OverrideSkin = GetModConfigData("skinoverride", TOS_MODNAME)
        inst.AnimState:SetBuild(inst.prefab.."_skin_"..skins[index])

        if OverrideSkin == 2 then
            inst.AnimState:ClearOverrideSymbol("swap_body")
        elseif OverrideSkin == 3 and not inszt.components.inventory:EquipHasTag("sendis") then
            inst.AnimState:ClearOverrideSymbol("swap_body")
        end

        if inst.components.inventory:EquipHasTag("sleevefix") then
            inst.AnimState:OverrideSymbol("arm_upper", "sendi", "arm_upper")
        else
            inst.AnimState:ClearOverrideSymbol("arm_upper")
        end
    end
end

local function OnChangeSkin(inst) -- YUKARI 스킨관련
    local skins = inst.components.aosgeneral.skins
    inst.skinindex = inst.skinindex >= #skins and 1 or inst.skinindex + 1
    SetSkinBuild(inst)
    -- TODO : 감정표현 추가
end

local function OnEquip(inst, data) 
    if data.eslot == EQUIPSLOTS.BODY then
        SetSkinBuild(inst)
    end
end

local function eatunfinishedfoodfn(inst, data)
    local mana_amount = data.food.aosmana or data.food.components.edible.sanityvalue ~= nil and data.food.components.edible.sanityvalue > 0 and data.food.components.edible.sanityvalue * TUNING.AOS_GENERAL.MANA_RESTORE_FROM_FOOD_MULTIPLIER or 0 -- 음식 먹을 때 오르는 정신력으로부터 마나가 회복
    data.feeder.components.aosmana:DoDelta(mana_amount)
    
    local food = data.food
    local name = string.upper(string.sub(food.prefab, 12))
    local string = STRINGS.CHARACTERS[string.upper(data.feeder.prefab)].ONEATSENDIFOOD[name] 
    --[[
    or food:HasTag("sendistaple") and GetString(data.feeder, "SENDISTAPLE") 
    or food:HasTag("sendifood") and GetString(data.feeder, "SENDIFOOD") 
    or food:HasTag("unfinished") and GetString(data.feeder, "UNFINISHED") 
    or food:HasTag("sendimeat") and GetString(data.feeder, "SENDIMEAT")
    ]]--

    data.feeder.components.talker:Say(string)
end

function AoSGeneral:SetSkins(ref)
    self.skins = ref
end

function AoSGeneral:Patch()
    local inst = self.inst
    inst.skinindex = 1

    inst:ListenForEvent("equip", OnEquip )
    inst:ListenForEvent("unequip", OnEquip )
    inst:ListenForEvent("oneat", eatunfinishedfoodfn) -- 먹었을 때

    inst.ChangeSkin = OnChangeSkin
end

return AoSGeneral
