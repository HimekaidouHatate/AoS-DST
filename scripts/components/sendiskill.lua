local CONST = TUNING.SENDI

local SendiSkill = Class(function(self, inst)
    self.inst = inst

	self.shouldcharge = false
	self.angle = 0

	-- RAPIER
	self.tickafterskill = 0
end)

local function ValidatePosition(inst)
	if not inst:IsOnValidGround() then
		local dest = FindNearbyLand(inst:GetPosition(), 8)
		if dest ~= nil then
			if inst.Physics ~= nil then
				inst.Physics:Teleport(dest:Get())
			elseif act.inst.Transform ~= nil then
				inst.Transform:SetPosition(dest:Get())
			end
		end
	end	
end

local function DoRapierCharge(inst)
	local self = inst.components.sendiskill
	local charge = self.shouldcharge
	local angle = self.angle

	if charge then
		local VELOCITY = 0.3
		local RADIUS = 2

		local fx = SpawnPrefab("firesplash_fx")
		fx.Transform:SetScale(0.4, 0.4, 0.4)
		fx.Transform:SetPosition(inst:GetPosition():Get())

		self.tickafterskill = self.tickafterskill + 1
		inst.Physics:SetMotorVel(35, 0, 0)

		local playerpos = inst:GetPosition()
		local ents = TheSim:FindEntities(playerpos.x + math.sin(angle), 0, playerpos.z + math.cos(angle), RADIUS, nil, { "INLIMBO" })
		for k,v in pairs(ents) do 
			if v.components.health ~= nil and _G.IsPreemptiveEnemy(inst, v) then
				local targetpos = v:GetPosition()
				v.Transform:SetPosition(targetpos.x + (math.sin(angle) * VELOCITY) , 0, targetpos.z + (math.cos(angle) * VELOCITY))
				if not v:HasTag("damagetaken") then
					v.components.combat:GetAttacked(inst, CONST.SKILL_RAPIER_DAMAGE_1) -- 데미지1
					v:AddTag("damagetaken")
					v:DoTaskInTime(15 * FRAMES, function()
						v:RemoveTag("damagetaken")
					end)
				end	
			end
		end
	end
end

function SendiSkill:GetRapierTarget()
	local targets = _G.GetSkillTargetsInRadius(self.inst, CONST.SKILL_RAPIER_TARGET_RADIUS)
	if targets ~= nil then
		return targets[1].Transform:GetWorldPosition()
	end
end

function SendiSkill:IsCharging()
	return self.shouldcharge
end

function SendiSkill:OnStartRapier(inst, angle)
	if inst.SkillTask == nil then 
		self.angle = angle
		inst.SkillTask = inst:DoPeriodicTask(0, DoRapierCharge)  -- 0초마다 반복 = 1프레임(0.033초)마다 반복
		inst.components.talker:Say(GetString(inst.prefab, "SKILL_RAPIER"))
	end
end

function SendiSkill:Explode(inst)
	self.shouldcharge = true
	if inst.components.aosmana ~= nil then
		inst.components.aosmana:DoDelta( -CONST.SKILL_RAPIER_MANACOST )
	end

	local x, y, z = inst.Transform:GetWorldPosition()

	local fx = SpawnPrefab("explode_small")
	fx.Transform:SetScale(1.4, 1.4, 1.4)
	fx.Transform:SetPosition(x, y, z)

	local ents = TheSim:FindEntities(x, y, z, 5, { "_combat" })
	for k,v in pairs(ents) do 
		if v.components.health ~= nil and _G.IsPreemptiveEnemy(inst, v) then
			v.components.combat:GetAttacked(inst, CONST.SKILL_RAPIER_DAMAGE_2) -- 데미지2
		end
	end
end

function SendiSkill:OnFinishCharge(inst)
	inst.Physics:Stop()
    inst.Physics:SetMotorVel(0, 0, 0)
	ValidatePosition(inst)

	self.shouldcharge = false
	self.tickafterskill = 0
	if inst.SkillTask ~= nil then 
		inst.SkillTask:Cancel()
		inst.SkillTask = nil
	end
end

local function DoIgniaRunCharge(inst)
	local self = inst.components.sendiskill
	local angle = self.angle

	inst.Physics:SetMotorVel(25, 0, 0)

	self.tickafterskill = self.tickafterskill + 1
end

function SendiSkill:OnStartIgniaRun(inst)
	if inst.SkillTask == nil then 
		self.angle = inst.Transform:GetRotation()
		self.shouldcharge = true
		inst.SkillTask = inst:DoPeriodicTask(0, DoIgniaRunCharge)
		inst.components.talker:Say(GetString(inst.prefab, "SKILL_IGNIARUN"))
		MakePysicalInvincible(inst, true)

		if inst.components.aosmana ~= nil then
			inst.components.aosmana:DoDelta( -CONST.SKILL_IGNIARUN_MANACOST )
		end

		SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
end

return SendiSkill