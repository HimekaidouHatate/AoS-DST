
--  sendi_rapier_ignia


-- 그래픽 자원 설정. 예시엔 드랍 이미지, 장착 이미지, 인벤토리 이미지, 인벤토리 이미지 xml이 설정됨.
--MH: 미쉘이추가한 코드. 미쉘 추가한거 바로 보시려면 컨 + F MH검색.

local assets ={
    Asset("ANIM", "anim/sendi_rapier_ignia.zip"),
    Asset("ANIM", "anim/swap_sendi_rapier_ignia.zip"), --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< swap파일을 로드 하지 않았습니다. 쥐님.
   
   Asset("ATLAS", "images/inventoryimages/sendi_rapier_ignia.xml"),
   Asset("IMAGE", "images/inventoryimages/sendi_rapier_ignia.tex"),
}

local prefabs = {
    "firesplash_fx", --YK : 이펙트 같은 외부 파일들을 로드해야할땐 반드시 prefabs 어규먼트를 넣어주세요.
}

local function UpdateDamage(inst)
    if inst.components.perishable and inst.components.weapon then
        local dmg = TUNING.HAMBAT_DAMAGE * inst.components.perishable:GetPercent()
        dmg = Remap(dmg, 0, TUNING.HAMBAT_DAMAGE, TUNING.HAMBAT_MIN_DAMAGE_MODIFIER*TUNING.HAMBAT_DAMAGE, TUNING.HAMBAT_DAMAGE)
        inst.components.weapon:SetDamage(dmg)
    end
end

local function OnLoad(inst, data)
   -- UpdateDamage(inst)
end
            --onunequip
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_sendi_rapier_ignia", "swap")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    inst.Light:Enable(true)
    -- 장착 시 설정.
    -- owner.AnimState:OverrideSymbol("애니메이션 뱅크명", "빌드명", "빌드 폴더명")
    -- 그 아래 2줄은 물건을 들고 있는 팔 모습을 활성화하고, 빈 팔 모습을 비활성화.
end

local function onunequip(inst, owner)
    --UpdateDamage(inst)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst.Light:Enable(false)
  --  local skin_build = inst:GetSkinBuild()
   -- if skin_build ~= nil then
   --     owner:PushEvent("unequipskinneditem", inst:GetSkinName())
   -- end
end

local DEFAULTBURNTIME = 9
local BURNDAMAGE = 3 -- 데미지
local BURNADDTIME = 9 --지속시간
local BURNPERIOD = 0.2 --도트데미지 간격

local function Enlight(thing)
    --thing.entity:AddLight()
    thing.Light:SetRadius(.5)
    thing.Light:SetFalloff(.2)
    thing.Light:SetIntensity(.8)
    thing.Light:SetColour(1, 0.6, 0.6)
    thing.Light:Enable(true)
    thing:DoTaskInTime(0.5, function() 
        thing.Light:Enable(false)
    end)
end

local function onattack(inst, attacker, target)--파이어 관련 코딩
    local fx = SpawnPrefab("firesplash_fx")
    fx.Transform:SetScale(0.5, 0.5, 0.5)
    fx.Transform:SetPosition(target:GetPosition():Get())
    --Enlight(inst)

    if inst.EnlightTask ~= nil then 
        inst.rad = 0.5
    else 
        local function Dim(inst)
            inst.Light:Enable(true)
            inst.Light:SetRadius(inst.rad)
            inst.rad = inst.rad - 0.1
        end
        inst.entity:AddLight()
        inst.rad = 0.5
        inst.Light:SetRadius(.5)
        inst.Light:SetFalloff(.2)
        inst.Light:SetIntensity(.8)
        inst.Light:SetColour(1, 0.6, 0.6)
        inst.Light:Enable(true)
        inst.EnlightTask = inst.DoPeriodicTask(inst, 0.1, function()
            if inst.rad > 0 then
                Dim(inst)
            else
                inst.rad = 0
                inst.Light:Enable(false)
            end
        end)
    end 

    AoSAddBuff(target, "flame", 2)
end
--유카리

local function onblink(staff, pos, caster)

    if caster.components.sanity ~= nil then
        caster.components.sanity:DoDelta(-15)
    end
end
--

--점멸
local function ontakefuel(inst)
   local afterrepair = inst.components.finiteuses:GetUses() + 20
   if afterrepair >= 200 then
      inst.components.finiteuses:SetUses(200)
   else
      inst.components.finiteuses:SetUses(afterrepair)
   end
end

--수리

local function fn()

    local inst = CreateEntity()  
    -- local trans = inst.entity:AddTransform() <<<<<<<<<< YK : 이거와 같은 경우에, trans라는 변수가 더이상 쓰이지 않을것 같을땐 변수로 할당하지 않는 습관을 들여주세요.(메모리 낭비됨)
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
	inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("sendi_rapier_ignia.tex")	 
	
    MakeInventoryPhysics(inst)

    inst.entity:AddLight()
    inst.Light:SetRadius(.2)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(0.9, 0.3, 0.3)
    inst.Light:Enable(false)

    inst.AnimState:SetBank("sendi_rapier_ignia")
    inst.AnimState:SetBuild("sendi_rapier_ignia")
    inst.AnimState:PlayAnimation("idle") --떨군 이미지추가 
   
    inst:AddTag("sharp") -- 태그 설정, 이 두 태그는 없어도 됨(실행 확인)
    inst:AddTag("pointy") 
    
    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

   
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(65) 
    --inst.components.weapon:SetDamage(10000000000) --코딩용
    
    -- 무기로 설정. 아래는 피해 설정
    inst.components.weapon:SetRange(1.2) --공격범위
    
    
    inst:AddComponent("finiteuses") --내구도 부문 
    inst.components.finiteuses:SetMaxUses(200)--최대 내구도 설정
    inst.components.finiteuses:SetUses(200) -- 현재 내구도  설정
    --inst.components.finiteuses:SetPercent(TUNING.FIRESTAFF_USES) -- 해당 아이템의 현재 내구도를 (최대 내구도 * n)으로 설정
    inst.components.finiteuses:SetOnFinished(inst.Remove)--내구도가 다하면 fn을 실행함.

    inst:AddComponent("blinkstaff") --점멸
	inst.components.blinkstaff:SetFX("firesplash_fx", "firesplash_fx")
    inst.components.blinkstaff.onblinkfn = onblink
    
    -- ---연료
    inst:AddComponent("fueled") --연료가 있는.
    inst.components.fueled.fueltype = "BURNABLE"
    inst.components.fueled:InitializeFuelLevel(10)
    inst.components.fueled.accepting = true
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled:StopConsuming()
    -- ---연료
    
    
    inst.components.weapon:SetOnAttack(onattack)--YK불꽃데미지 
    
    inst:AddComponent("inspectable") --조사 가능하도록 설정
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sendi_rapier_ignia"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sendi_rapier_ignia.xml" --인벤토리 아이템으로 설정됨
   
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunchAndPerish(inst)
    
    inst.OnLoad = OnLoad
    --YK : OnLoad, OnSave, OnPreLoad 함수들은 마지막에 입력해주세요. 
    inst.components.inventoryitem.keepondeath = true
    return inst
end

return Prefab("sendi_rapier_ignia", fn, assets, prefabs) --YK : prefab 어규먼트