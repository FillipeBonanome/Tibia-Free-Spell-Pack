--[[
	Descrição da Magia:
	Ataca um inimigo com um golpe de gelo. Caso acertar um oponente você ganha 1 stack dessa magia, ao chegar em 3 stacks o seu alvo será paralisado,
	consumindo os stacks acumulados.
	
	Explicação:
	Utilizaremos uma Storage (212000) para verificar os stacks do nosso jogador. A cada alvo acertado a storage aumentará em 1 ponto. Caso a Storage
	chegue em 3, resetaremos ela para 0 e aplicaremos a paralisia no alvo.
]]--

--Cria o objeto de Combat
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICEATTACK)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ICE)

--Calcula a fórmula de dano da magia
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 1.2) + 6
	local max = (level / 5) + (magicLevel * 2) + 10
	return -min, -max
end

--Cria a condição de paralisia de 45%
local condition = Condition(CONDITION_PARALYZE)
condition:setParameter(CONDITION_PARAM_TICKS, 3000)
condition:setFormula(-0.45, 0, -0.45, 0)

--Quando acerta um oponente realiza a lógica de stacks para a magia
function onTargetCreature(player, target)
	local stacks = player:getStorageValue(212000)
	if stacks == 3 then
		target:addCondition(condition)
		player:setStorageValue(212000, 0)
	end
	player:setStorageValue(212000, math.max(1, player:getStorageValue(212000) + 1))
end

--Aplica os callbacks para o Combat
combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	--Executa o combat
	return combat:execute(creature, variant)
end

spell:name("Frost Bolt")
spell:words("Frost Bolt")
spell:group("attack")
spell:id(180)
spell:cooldown(2 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(12)
spell:mana(20)
spell:range(3)
spell:needCasterTargetOrDirection(true)
spell:register()