--[[
	Descrição da Magia:
	Cria uma explosão de gelo no alvo. Caso ele estiver paralisado o dano é aumentado em 20%.
	
	Explicação:
	Teremos que dividir a magia em 3 Combats: O primeiro combat será responsável pela área da magia, o segundo pelo dano padrão
	e o terceiro pelo dano amplificado. Para cada alvo acertado pelo combat em área (primeiro), iremos verificar se ele possui paralisia, 
	caso ele tenha paralisia executaremos o terceiro combat nele. Caso não tenha paralisia executaremos o segundo combat nele.
]]--

--Cria o objeto de Combat para a área
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_ICEAREA)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ICE)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

--Cria o combat para causar o dano padrão no oponente
local combatDamage = Combat()
combatDamage:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)

--Cria o combat para causar dano amplificado no oponente
local combatAmplifiedDamage = Combat()
combatAmplifiedDamage:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)

--Calcula a fórmula de dano da magia
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 1.45) + 12
	local max = (level / 5) + (magicLevel * 2.35) + 20
	return -min, -max
end

--Calcula a fórmula de dano da magia amplificada
function onGetFormulaValuesAmplified(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 1.45) + 12
	local max = (level / 5) + (magicLevel * 2.35) + 20
	return -min * 1.2, -max * 1.2
end

--Quando acerta um oponente realiza a lógica de bônus de dano
function onTargetCreature(player, target)
	if target:getCondition(CONDITION_PARALYZE) then
		combatAmplifiedDamage:execute(player, numberToVariant(target:getId()))
	else
		combatDamage:execute(player, numberToVariant(target:getId()))
	end
end

--Aplica os callbacks para os Combats
combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")
combatDamage:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")
combatAmplifiedDamage:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValuesAmplified")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	--Executa o Combat
	return combat:execute(creature, variant)
end

spell:name("Freezing Orb")
spell:words("Freezing Orb")
spell:group("attack")
spell:id(181)
spell:cooldown(4 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(26)
spell:mana(85)
spell:needCasterTargetOrDirection(true)
spell:register()