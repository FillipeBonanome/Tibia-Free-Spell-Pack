--[[
	Descri��o da Magia:
	Cria uma �rea de gelo no alvo, causando dano constantemente em sua volta.
	
	Explica��o:
	Para essa spell utilizaremos um config para ajudar a alterar os valores de alguns par�metros, como por exemplo a dura��o da Magia, anima��es
	e quantos hits ela vai dar. N�o colocaremos os efeitos diretamente no Combat, inv�s disso criaremos os efeitos manualmente no evento onTargetTile.
	Para que a magia n�o fique seguindo o jogador iremos pegar a posi��o inicial da magia e salvar em uma vari�vel, para depois chamarmos o combat
	v�rias vezes com um for e addEvent. A fun��o createDiamondAnimation serve para criar a anima��o dos efeitos de dist�ncia girando para dar a impress�o
	melhor de que se trata de um ciclone.
	
]]--

--Configura��o b�sica da magia, fica mais f�cil de alterar ela por aqui
local config = {
	hits = 8,																	--Quantos hits a magia ir� dar
	totalDuration = 4000,														--Dura��o total da magia
	animationChance = 100,														--Chance de soltar uma anima��o aleat�ria
	animations = {CONST_ME_ICETORNADO, CONST_ME_ICETORNADO, CONST_ME_ICEAREA},	--Lista de anima��es aleat�rias
}

--Cria o objeto de Combat com �rea
local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setArea(createCombatArea(AREA_CIRCLE2X2))

--Calcula a f�rmula de dano da magia e vamos dividir pela config.hits. Ent�o o dano n�o ser� alterado caso mudarmos alguma coisa da config.
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.15) + 32
	local max = (level / 5) + (magicLevel * 7.2) + 48
	return -min / config.hits, -max / config.hits
end

--Cria as anima��es aleat�rias em cada posi��o do Combat.
function onTargetTile(player, pos)
	if math.random(100) <= config.animationChance then
		addEvent(function()
			pos:sendMagicEffect(config.animations[math.random(#config.animations)])
		end, math.random(config.totalDuration / config.hits))
	end
end

combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

--Cria a anima��o circular de dist�ncia
local function createDiamondAnimation(position, start, distance, times)
	local pos = {x = position.x, y = position.y, z = position.z}
	local start = start or 0
	local distance = distance or CONST_ANI_SUDDENDEATH
	local times = times or 8
	local offset = {
		[0] = {x = 0, y = -1},
		[1] = {x = 1, y = 0},
		[2] = {x = 0, y = 1},
		[3] = {x = -1, y = 0}
	}
	local posStart = {x = pos.x + offset[start % 4].x, y = pos.y + offset[start % 4].y, z = pos.z}
	for i = 1, times do
		addEvent(function()
			local posEnd = {x = pos.x + offset[(start + 1) % 4].x, y = pos.y + offset[(start + 1) % 4].y, z = pos.z}
			doSendDistanceShoot(posStart, posEnd, distance)
			posStart = posEnd
			start = start + 1
		end, (i - 1) * 120)
	end
	return true
end

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	--[[
		Pega a posi��o inicial da magia. Se a variant tiver o atributo number, quer dizer que estamos utilizando em um alvo, ent�o teremos que pegar
		a sua posi��o com Creature(variant.number):getPosition(), caso contr�rio podemos pegar diretamente do variant.pos
	--]]
	local spellPos = variant.number and Creature(variant.number):getPosition() or variant.pos
	
	--Criamos 2 anima��es rotativas, uma come�ando da parte norte (0) e outra sul (2)
	createDiamondAnimation(spellPos, 0, CONST_ANI_SMALLICE, config.totalDuration / 120)
	createDiamondAnimation(spellPos, 2, CONST_ANI_SMALLICE, config.totalDuration / 120)
	
	--[[
		Utilizamos o for loop para rodar a magia v�rias vezes em conjunto do addEvent. Lembrar de verificar se o jogador ainda existe na hora
		de castar a magia, por isso do Creature(c).
	--]]
	for i = 1, config.hits - 1 do
		addEvent(function(c)
			if Creature(c) then
				combat:execute(Creature(c), positionToVariant(spellPos))
			end
		end, (config.totalDuration / config.hits) * i, creature:getId())
	end
	
	--Executa a primeira vez
	return combat:execute(creature, variant)
end

spell:name("Cyclone")
spell:words("Cyclone")
spell:group("attack")
spell:id(182)
spell:cooldown(8 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(38)
spell:mana(280)
spell:range(4)
spell:needCasterTargetOrDirection(true)
spell:register()