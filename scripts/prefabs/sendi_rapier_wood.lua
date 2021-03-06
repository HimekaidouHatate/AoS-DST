
-- 그래픽 자원 설정. 예시엔 드랍 이미지, 장착 이미지, 인벤토리 이미지, 인벤토리 이미지 xml이 설정됨.

local assets ={
    Asset("ANIM", "anim/sendi_rapier_wood.zip"),
    Asset("ANIM", "anim/swap_sendi_rapier_wood.zip"),
   --swap
   Asset("ATLAS", "images/inventoryimages/sendi_rapier_wood.xml"),
   Asset("IMAGE", "images/inventoryimages/sendi_rapier_wood.tex"),
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

   
    owner.AnimState:OverrideSymbol("swap_object", "swap_sendi_rapier_wood", "swap")
								--..들려있는 장비 제작시 그냥.. scml 변환하지말고 png변환만하자.(ㅍ_ㅍ)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
	
	-- 장착 시 설정.
	-- owner.AnimState:OverrideSymbol("애니메이션 뱅크명", "빌드명", "빌드 폴더명")
	-- 그 아래 2줄은 물건을 들고 있는 팔 모습을 활성화하고, 빈 팔 모습을 비활성화.


   end

   
local function onunequip(inst, owner)
    --UpdateDamage(inst)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
  --  local skin_build = inst:GetSkinBuild()
   -- if skin_build ~= nil then
   --     owner:PushEvent("unequipskinneditem", inst:GetSkinName())
   -- end
end

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
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("sendi_rapier_wood.tex")	 
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sendi_rapier_wood")
    inst.AnimState:SetBuild("sendi_rapier_wood")
    inst.AnimState:PlayAnimation("idle")
   --떨군 이미지추가 
   
    inst:AddTag("sharp") 
    inst:AddTag("pointy") 
	-- 태그 설정, 이 두 태그는 없어도 됨(실행 확인)

    if not TheWorld.ismastersim then
        return inst
    end

	inst.entity:SetPristine()


    inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(25)
	--무기로 설정. 아래는 피해 설정
	inst.components.weapon:SetRange(1.2)
	--공격범위
	
	
	inst:AddComponent("finiteuses") --내구도 부문 
    inst.components.finiteuses:SetMaxUses(200)--최대 내구도 설정
	inst.components.finiteuses:SetUses(200) -- 현재 내구도  설정
	--inst.components.finiteuses:SetPercent(TUNING.FIRESTAFF_USES) -- 해당 아이템의 현재 내구도를 (최대 내구도 * n)으로 설정
	inst.components.finiteuses:SetOnFinished(inst.Remove)--내구도가 다하면 fn을 실행함.

	-- ---연료
    inst:AddComponent("fueled") --연료가 있는.
    inst.components.fueled.fueltype = "BURNABLE"
    inst.components.fueled:InitializeFuelLevel(10)
	inst.components.fueled.accepting = true
	inst.components.fueled:SetTakeFuelFn(ontakefuel)
	inst.components.fueled:StopConsuming()
	-- ---연료

	
    inst.OnLoad = OnLoad

    inst:AddComponent("inspectable")
		--조사 가능하도록 설정
	
    inst:AddComponent("inventoryitem")
   inst.components.inventoryitem.imagename = "sendi_rapier_wood"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sendi_rapier_wood.xml"
		--인벤토리 아이템으로 설정됨
   
    MakeHauntableLaunchAndPerish(inst)
   
   

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	--장착 가능하도록, 장착밑 해제시의 위의 두 펑션을 작동
	
    return inst
end

return Prefab("sendi_rapier_wood", fn, assets) 