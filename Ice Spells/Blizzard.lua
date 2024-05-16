--[[
	Descrição da Magia:
	Cria uma chuva de gelo em uma posição fixa
	
	Explicação:
	Iremos usar 2 Combats "iguais", um para pegar as posições da magia e outro para causar dano. Precisamos pegar as posições da Magia
	para criarmos o efeito de chuva no local
	
]]--

--Configurações básicas da magia
local config = {
	hits = 16,											--Quantos hits vão dar
	duration = 4000,									--Duração da magia
	intensity = 48,										--Intensidade dos pingos
	animations = {										--Animações
		{CONST_ANI_SMALLICE, CONST_ME_ICETORNADO},
		{CONST_ANI_ICE, CONST_ME_ICEATTACK},
	}
}

--Cria o objeto de Combat responsável para pegar as posições afetadas
local combat = Combat()
combat:setArea(createCombatArea(AREA_CIRCLE5X5))

--Cria o objeto de Combat para dano
local combatDamage = Combat()
combatDamage:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combatDamage:setArea(createCombatArea(AREA_CIRCLE5X5))

--Calcula a fórmula de dano da magia, é divida por config.hits para o dano não ser alterado se mudar o config
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 8.5) + 250
	local max = (level / 5) + (magicLevel * 10.0) + 330
	return -min / config.hits, -max / config.hits
end

combatDamage:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	--Pega a posição central da magia
	local spellPos = variant.number and Creature(variant.number):getPosition() or variant.pos
	--Pega a lista de posições em que a magia irá afetar
	local positions = combat:getPositions(creature, variant)
	
	--Animações: Pega uma posição aleatória da lista de posições e realiza a animação de chuva naquela posição
	for i = 1, config.duration / 1000 * config.intensity do
		addEvent(function()
			local randomPosition = positions[math.random(#positions)]
			local upPosition = {x = randomPosition.x - 3, y = randomPosition.y - 3, z = randomPosition.z}
			local randomAnimation = config.animations[math.random(#config.animations)]
			doSendDistanceShoot(upPosition, randomPosition, randomAnimation[1])
			addEvent(doSendMagicEffect, 300, randomPosition, randomAnimation[2])
		end, (i - 1) * 1000 / config.intensity)
	end
	
	--Ataques: Executa o combat várias vezes na mesma posição
	for i = 1, config.hits do
		addEvent(function(c)
			if Creature(c) then
				combatDamage:execute(Creature(c), positionToVariant(spellPos))
			end
		end, (i - 1) * config.duration / config.hits, creature:getId())
	end
	
	return true
end

spell:name("Blizzard")
spell:words("Blizzard")
spell:group("attack")
spell:id(186)
spell:cooldown(60 * 1000)
spell:groupCooldown(4 * 1000)
spell:level(120)
spell:mana(1800)
spell:needCasterTargetOrDirection(true)
spell:register()