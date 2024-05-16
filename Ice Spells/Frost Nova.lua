--[[
	Descri��o da Magia:
	Causa uma explos�o em sua volta, paralisando os inimigos.
	
	Explica��o:
	Nessa spell iremos calcular a dist�ncia entre o jogador e a posi��o que a magia ir� acertar e ent�o, baseado nessa dist�ncia,
	criaremos um addEvent soltando o magicEffect manualmente para dar o efeito de explos�o cont�nua.
	
]]--

--Configura��o b�sica da magia, fica mais f�cil de alterar ela por aqui
local config = {
	delay = 200,																--Delay das anima��es
	animations = {CONST_ME_ICEATTACK, CONST_ME_GIANTICE},						--Lista de Anima��es
}

--Cria o objeto de Combat com �rea
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

--Calcula a f�rmula de dano da magia
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.15) + 32
	local max = (level / 5) + (magicLevel * 7.2) + 48
	return -min, -max
end

--Cria as anima��es aleat�rias em cada posi��o do Combat com delay baseado na dist�ncia entre o jogador e a posi��o.
function onTargetTile(player, pos)
	local distance = getDistanceBetween(player:getPosition(), pos)
	addEvent(function()
		pos:sendMagicEffect(config.animations[math.random(#config.animations)])
	end, math.max(0, (distance - 1)) * config.delay)
end

--Cria a condi��o de paralisia de 25%
local condition = Condition(CONDITION_PARALYZE)
condition:setParameter(CONDITION_PARAM_TICKS, 4000)
condition:setFormula(-0.25, 60, -0.25, 60)
combat:addCondition(condition)

combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	--Executa o combat
	return combat:execute(creature, variant)
end

spell:name("Frost Nova")
spell:words("Frost Nova")
spell:group("attack")
spell:id(183)
spell:cooldown(8 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(46)
spell:mana(315)
spell:isSelfTarget(true)
spell:register()