--[[
	Descrição da Magia:
	Cria uma wave de gelo que empurra todos os inimigos afetados.
	
	Explicação:
	Precisamos calcular a posição em que o inimigo irá parar e se essa posição é andável/não é PZ/Não possui nenhuma criatura, para então empurra-lo
]]--

local config = {
	delay = 100,
	animations = {CONST_ME_ICETORNADO, CONST_ME_ICEAREA}
}

local area = {
	{1,1,1,1,1},
	{1,1,1,1,1},
	{0,1,1,1,0},
	{0,1,1,1,0},
	{0,0,1,0,0},
	{0,0,3,0,0},
}

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
combat:setArea(createCombatArea(area))

--Calcula a fórmula de dano da magia
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 5.15) + 32
	local max = (level / 5) + (magicLevel * 7.2) + 48
	return -min, -max
end

--Cria uma reta entre 2 posições de tamanho N
local function createLine(posa, posb, n)
	local distance = getDistanceBetween(posa, posb)
	local positionsLerp = {}
	for i = 1, n do
		positionsLerp[i] = {x = posa.x + math.floor((posb.x - posa.x) * (i/distance) + 0.5), y = posa.y + math.floor((posb.y - posa.y) * (i/distance) + 0.5), z = posa.z}
	end
	return positionsLerp
end

function onTargetCreature(cid, target)
	local distance = getDistanceBetween(cid:getPosition(), target:getPosition())
	local line = createLine(cid:getPosition(), target:getPosition(), distance + 1)
	if #line < 1 then return end
	local nextPosition = line[#line]
	if Tile(nextPosition) then
		local tile = Tile(nextPosition)
		if tile:isWalkable() and not tile:hasFlag(TILESTATE_FLOORCHANGE) and not tile:hasFlag(TILESTATE_PROTECTIONZONE) and not tile:getTopCreature() then
			target:teleportTo(nextPosition, true)
		end
	end
end

function onTargetTile(cid, pos)
	local distance = getDistanceBetween(cid:getPosition(), pos)
	addEvent(function()
		pos:sendMagicEffect(config.animations[math.random(#config.animations)])
	end, math.max(0, distance - 1) * config.delay)
end

combat:setCallback(CALLBACK_PARAM_TARGETCREATURE, "onTargetCreature")
combat:setCallback(CALLBACK_PARAM_TARGETTILE, "onTargetTile")
combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell("instant")

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:name("Gust")
spell:words("Gust")
spell:group("attack")
spell:id(193)
spell:cooldown(12 * 1000)
spell:groupCooldown(2 * 1000)
spell:level(65)
spell:mana(415)
spell:needDirection(true)
spell:register()