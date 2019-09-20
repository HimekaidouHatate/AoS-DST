local CONST = TUNING.ANAN

local AnanLevel = Class(function(self, inst)
    self.inst = inst

    self.level = CONST.INTERNAL_TYPE_ZERO
    self.exp = CONST.INTERNAL_TYPE_ZERO
end)

function AnanLevel:GetMaxExp() 
    --
	return 10 + self.level * 47 + math.ceil(1.375 ^ self.level) --레벨 당 경험치통 공식
	
	
end

function AnanLevel:AddExp(amount)
	if self.level < 30 then
        if amount >= self:GetMaxExp() then
        --amount[얻은경험치]가 맥스 경험치보다 같거나 크다면 
            local leftover = amount - (self:GetMaxExp() - self.exp)
        --남은 경험치 - (맥스최대경험치 - 가진경험치)
            self:LevelUp()
        --레벨업
            return self:AddExp(leftover)
        --리턴 exp
        end
	else
	    amount = 0
	end
	
    self.exp = self.exp + amount
   --가진 exp는 가진 exp+ 얻은경험치량
   
    if self.exp >= self:GetMaxExp() then --M,G 추가본
      local leftover = amount - (self:GetMaxExp() - self.exp)
      self:LevelUp()
      return self:AddExp(leftover)
   end
end

function AnanLevel:LevelUp()
    self.exp = 0
    self.level = self.level + 1
    self.inst.components.talker:Say(GetString(self.inst, "DESCRIBE_LEVELUP"))
    self:ApplyStatus()
end

function AnanLevel:ApplyStatus()
    local inst = self.inst
	local hunger_percent = inst.components.hunger:GetPercent()
	local health_percent = inst.components.health:GetPercent()
	local sanity_percent = inst.components.sanity:GetPercent()
	local ignoresanity = inst.components.sanity.ignore
    inst.components.sanity.ignore = false
	
	inst.components.health.maxhealth = CONST.DEFAULT_HEALTH + self.level * 5.5 --채력
	inst.components.hunger.max = CONST.DEFAULT_HUNGER + self.level * 3 --허기
	inst.components.sanity.max = CONST.DEFAULT_SANITY + self.level * 4 --정신
	
	inst.components.combat.damagemultiplier = CONST.DEFAULT_DAMAGEMULTIPLIER + self.level * 0.08
	
    inst.components.health:SetPercent(health_percent)
	inst.components.hunger:SetPercent(hunger_percent)
	inst.components.sanity:SetPercent(sanity_percent)
	inst.components.sanity.ignore = ignoresanity
	
end

function AnanLevel:OnSave()
    return {
		level = self.level,
        exp = self.exp,
	}
end

function AnanLevel:OnLoad(data)
	if data ~= nil then
		self.level = data.level or 0
		self.exp = data.exp or 0
        self:ApplyStatus()
	end
end

return AnanLevel