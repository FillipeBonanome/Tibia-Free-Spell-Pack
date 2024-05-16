--[[
	Descrição da Magia:
	Causa uma explosão em sua volta, paralisando os inimigos.
	
	Explicação:
	Nessa spell iremos calcular a distância entre o jogador e a posição que a magia irá acertar e então, baseado nessa distância,
	criaremos um addEvent soltando o magicEffect manualmente para dar o efeito de explosão contínua.
	
]]--

--Configuração básica da magia, fica mais fácil de alterar ela por aqui
local config = {
	delay = 200,																--Delay das animações
	animations = {CONST_ME_ICEATTACK, CONST_ME_GIANTICE},						--Lista de Animações
}

--Cria o objeto de Combat com área
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setArea(createCombatArea(AREA_CIRCLE3X3))

--Calcula a fórmula de dano da magia
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.15) + 32
	local max = (level / 5) + (magicLevel * 7.2) + 48
	return -min, -max
end

--Cria as animações aleatórias em cada posição do Combat com delay baseado na distância entre o jogador e a posição.
function onTargetTile(player, pos)
	local distance = getDistanceBetween(player:getPosition(), pos)
	addEvent(function()
		pos:sendMagicEffect(config.animations[math.random(#config.animations)])
	end, math.max(0, (distance - 1)) * config.delay)
end

--Cria a condição de paralisia de 25%
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