local MakePlayerCharacter = require "prefabs/player_common"
local CONST = TUNING.SENDI

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}
local prefabs = {

	}

local start_inv = {--시작 인벤토리
	
	"spear",
	"taffy",
	"taffy",
	"taffy",
	"taffy",
	"taffy",
	"sleepbomb",
	"sleepbomb",
}

local function onbecamehuman(inst)

	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "tees_speed_mod", 1) --죽었다 살아난 후의 스피드. [스폰 시점인지는 알수없음.]
	
end

local function onbecameghost(inst)

   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "tees_speed_mod", 2.0)
end

local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end
	
local function CalcSanityAura(inst, observer)--정신
	if observer:HasTag("character") then--발견한자의 이름 [오라를 받을사람]
		return TUNING.SANITYAURA_MED
	end	
	return 0
end
	
	
local function common_postinit (inst) --정신
		inst:AddTag("tees") --자신의 태그
		inst:AddTag("frog")
		inst:AddTag("insect")
		inst:AddTag("animal")	
		inst:AddTag("houndfriend")--성질테그
		inst:AddTag("hound")
		inst:AddTag("warg")--바그
		inst:AddTag("pig")
		inst:AddTag("werepig")
		inst:AddTag("cattoy")
		
		inst.MiniMapEntity:SetIcon( "tees.tex" )--발견한 자신의 미니맵 이름 
		inst:AddComponent("sanityaura")
		inst.components.sanityaura.aurafn = CalcSanityAura
end

local function DoPoisonDamage(inst) --티스의 독데미지

    inst.components.health:DoDelta(-5, true, "poison") -- 도트피해딜 수치

    inst.AnimState:SetMultColour(1,0,1,1)
    inst:DoTaskInTime(1, function(inst) inst.AnimState:SetMultColour(1,1,1,1) end)
end

local function onattackother(inst, data)-- 33초에 거쳐 딜을입힘.
if data.target and data.target.components.health and not data.target.components.health:IsDead() then
if not data.target:HasTag("player") then --플레이어에게 딜이 들어가지않음.
if data.target.poisontask == nil then

data.target.poisontask = data.target:DoPeriodicTask(1/3, DoPoisonDamage) --1초에 3회의 데미지를 입힘.

data.target.poisonwearofftask = data.target:DoTaskInTime(5, function(inst) inst.poisontask:Cancel() inst.poisontask = nil end) --데미지 지속 시간
            end
        end
    end
end
local master_postinit = function(inst)

	inst.soundsname = "wilson"
	inst:AddTag("bookbuilder")-- 위커바컴의 책을 제조합니다.
	inst:ListenForEvent("onattackother", onattackother) --독뎀 태그
	inst:AddTag("poisonous") --독속성태그 추가
    inst.components.combat.poisonous = true--독속성태그 추가 진실값
	
	inst:AddComponent("teeslevel")--레벨업
	-- Stats	
	inst.components.health:SetMaxHealth(CONST.DEFAULT_HEALTH) -- 피
	inst.components.hunger:SetMax(CONST.DEFAULT_HUNGER) -- 배고팡
	inst.components.sanity:SetMax(CONST.DEFAULT_SANITY) -- 정신
	


	inst.components.health.fire_damage_scale = 0.1 --불 데미지 배수 
	inst.components.combat.damagemultiplier = CONST.DEFAULT_DAMAGEMULTIPLIER	--데미지 배수 
	
	
	inst.components.hunger.hungerrate = 1.2 * TUNING.WILSON_HUNGER_RATE --허기수치
	inst.components.combat.min_attack_period = 0.2--공격속도
	--inst.components.health:StartRegen(0.3, 0.8)   --체력 회복
	
	inst.OnLoad = onload
    inst.OnNewSpawn = onload
	
			--잠금해제
	inst:DoTaskInTime(0, function(inst)
		inst.components.builder:AddRecipe("sleepbomb")--선잠주머니
		inst:PushEvent("unlockrecipe", { recipe = "sleepbomb" })
	end)	
	inst:DoTaskInTime(0, function(inst)
		inst.components.builder:AddRecipe("blowdart_sleep")--수면다트
		inst:PushEvent("unlockrecipe", { recipe = "blowdart_sleep" })
	end)		
	inst:DoTaskInTime(0, function(inst)
		inst.components.builder:AddRecipe("blowdart_fire")--화염다트
		inst:PushEvent("unlockrecipe", { recipe = "blowdart_fire" })
	end)	


	-- inst:ListenForEvent("hungerdelta", OnHungerDelta)-- 허기에따른 변화 마침코드
	-- inst:ListenForEvent("Hungeranimal", OnHungeranimal)-- 허기에따른 변화 마침코드2
	--inst:ListenForEvent("tess_force_proc", OnHungeranimal)-- 허기에따른 변화 마침코드2
	

end


return MakePlayerCharacter("tees", prefabs, assets, common_postinit, master_postinit, start_inv)