--[[
	Descrição da Magia:
	Cria uma onda de gelo a sua frente, inimigos receberão dano, aliados receberão um buff de velocidade temporário.
	
	Explicação:
	No evento onTargetTile iremos verificar se existe uma criatura em uma posição, caso ela existir iremos verificar se ela
	é um aliado, para então dar um buff a ela. Também utilizaremos desse evento para criar efeitos customizados com delay
	baseado na distância do jogador até a posição da magia.
	
]]--

--Configurações básicas
local config = {
	animations = {CONST_ME_ICEAREA},
	delay = 100,
}

--Cria o objeto de Combat com área
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setArea(createCombatArea(AREA_WAVE4))

--Calcula a fórmula de dano da magia
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.15) + 32
	local max = (level / 5) + (magicLevel * 7.2) + 48
	return -min, -max
end

--Buff de velocidade
local condition = Condition(CONDITION_HASTE)
condition:setParameter(CONDITION_PARAM_TICKS, 5000)
condition:setParameter(CONDITION_PARAM_SUBID, 2)
condition:setFormula(0.9, -72, 0.9, -72)

--[[
	Cria as animações aleatórias em cada posição do Combat com delay baseado na distância entre o jogador e a posição.
	Buffa um summon seu ou um aliado de PT com move speed.
--]]
function onTargetTile(player, pos)
	local distance = getDistanceBetween(player:getPosition(), pos)
	addEvent(function()
		pos:sendMagicEffect(config.animations[math.random(#config.animations)])
	end, math.max(0, (distance - 1)) * config.delay)
	
	local topCreature = Tile(pos):getTopCreature()
	
	if topCreature and topCreature:getMaster() == player or (player:getParty() ~= nil and player:getParty() == topCreature:getParty()) then
		topCreature:addCondition(condition)
		topCreature:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end
end

combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	--Executa o combat
	return combat:execute(creature, variant)
end

spell:name("Icy Wind")
spell:words("Icy Wind")
spell:group("attack")
spell:id(184)
spell:cooldown(8 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(52)
spell:mana(245)
spell:needDirection(true)
spell:register()