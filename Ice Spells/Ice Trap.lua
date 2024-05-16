--[[
	Descri��o da Magia:
	Cria uma armadilha no ch�o, caso um jogador ou um monstro pise ela � ativada e uma explos�o congelante � criada
	
	Explica��o:
	iremos checar v�rias vezes na posi��o onde o jogador castou a magia, se existe alguma criatura (sem ser o caster) naquela posi��o.
	Caso existir a armadilha ser� ativada e o combat ser� executado
	
]]--

local config = {
	checks = 8,								--Quantas vezes vai checar por segundo
	duration = 4000,						--Dura��o da trap
}

--Cria o objeto de Combat com �rea
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setArea(createCombatArea(AREA_CIRCLE2X2))
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_GIANTICE)

--Cria condition de paralyze
local condition = Condition(CONDITION_PARALYZE)
condition:setParameter(CONDITION_PARAM_TICKS, 8000)
condition:setFormula(-0.55, 0, -0.55, 0)
combat:addCondition(condition)

--Calcula a f�rmula de dano da magia
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 1.55) + 16
	local max = (level / 5) + (magicLevel * 2.85) + 24
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	local pos = creature:getPosition()
	local events = {}
	
	--Checa v�rias vezes por segundo se existe algu�m sem ser o caster na posi��o da trap, caso estiver ela explode e cancela os outros eventos futuros.
	for i = 1, config.duration / 1000 * config.checks do
		events[i] = addEvent(function(c)
			if Creature(c) then
				local cid = Creature(c)
				if i % config.checks == 0 or i == 1 then
					doSendMagicEffect(pos, CONST_ME_ICEATTACK)
				end
				local topCreature = Tile(pos):getTopCreature()
				if topCreature and topCreature ~= cid then
					combat:execute(cid, positionToVariant(pos))
					for j = i, #events do
						stopEvent(events[j])
					end
				end
			end
		end, (i - 1) * 1000 / config.checks, creature:getId()) 
	end
	
	return true
end

spell:name("Ice Trap")
spell:words("Ice Trap")
spell:group("attack")
spell:id(187)
spell:cooldown(4 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(18)
spell:mana(65)
spell:isSelfTarget(true)
spell:register()