local Board = require("board")

function love.load()
	board = Board.new()
end

function love.draw()
	board:draw()
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
end

function love.keypressed(k)
	if k == 'a' then
		board:slide("left")
	end
	if k == 'd' then
		board:slide("right")
	end
	if k == 's' then
		board:slide("down")
	end
	if k == 'w' then
		board:slide("up")
	end
end
