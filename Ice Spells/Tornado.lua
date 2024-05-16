--[[
	Descrição da Magia:
	Cria um tornado em sua volta.
	
	Explicação:
	Essa magia é bem pesada, por isso ela tem um cooldown alto. Precisamos calcular o ângulo em cada posição da magia e então calcular o delay
	para soltar o combatDamage e causar dano naquela posição.
	
]]--

local config = {
	hits = 2,								--Quantas voltas o tornado vai dar
	animations = {CONST_ME_ICETORNADO},		--Lista de efeitos para o tornado
	duration = 1500,						--Duração de uma volta do tornado
}

--Cria o objeto de Combat com área
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setArea(createCombatArea(AREA_CIRCLE6X6))

--Cria o objeto de Combat para dano
local combatDamage = Combat()
combatDamage:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)

--Calcula a fórmula de dano da magia, é divida por config.hits para o dano não ser alterado se mudar o config
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 6.5) + 100
	local max = (level / 5) + (magicLevel * 9.0) + 150
	return -min / config.hits, -max / config.hits
end

--Calcula o ângulo entre 2 pontos
local function getAngleBetweenTwoPoints(position1, position2)
	local deltaX = position1.x - position2.x
	local deltaY = position1.y - position2.y
	return math.atan2(deltaY, deltaX) * 180 / math.pi - 180
end

--[[
	Cria as animações aleatórias em cada posição do Combat com delay baseado no ângulo, tendo como centro a posição do jogador
--]]
function onTargetTile(player, pos)
	local angle = getAngleBetweenTwoPoints(player:getPosition(), pos)
	addEvent(function(c)
		if Creature(c) then
			combatDamage:execute(Creature(c), positionToVariant(pos))
			pos:sendMagicEffect(config.animations[math.random(#config.animations)])
		end
	end, math.abs(angle) * config.duration / 360, player:getId())
end

combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
combatDamage:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	--Pega a posição inicial
	local spellPos = Position(variant.pos)
	--Executa os outros combats para cada volta
	for i = 1, config.hits - 1 do
		addEvent(function(c)
			if Creature(c) then
				combat:execute(Creature(c), variant)
			end
		end, i * config.duration, creature:getId())
	end
	--Executa o combat
	return combat:execute(creature, variant)
end

spell:name("Tornado")
spell:words("Tornado")
spell:group("attack")
spell:id(185)
spell:cooldown(60 * 1000)
spell:groupCooldown(4 * 1000)
spell:level(75)
spell:mana(1350)
spell:isSelfTarget(true)
spell:register()