local Scaling = {}

function Scaling.getScaleFactor()
    return scaleFactor or 1
end

function Scaling.getBaseDimensions()
    return baseWidth or 1200, baseHeight or 900
end

function Scaling.getWindowDimensions()
    return windowWidth or love.graphics.getWidth(), windowHeight or love.graphics.getHeight()
end

function Scaling.scale(value)
    return value * Scaling.getScaleFactor()
end

function Scaling.scaleCoordinates(x, y)
    local scale = Scaling.getScaleFactor()
    return x * scale, y * scale
end

function Scaling.getScaledFontSize(baseSize)
    return math.max(8, math.floor(baseSize * Scaling.getScaleFactor()))
end

function Scaling.getUIScale()
    local wScale = (windowWidth or love.graphics.getWidth()) / (baseWidth or 1200)
    local hScale = (windowHeight or love.graphics.getHeight()) / (baseHeight or 900)
    return math.min(wScale, hScale)
end

function Scaling.scaleUI(width, height)
    local scale = Scaling.getUIScale()
    return width * scale, height * scale
end

function Scaling.getCenteredPosition(elementWidth, elementHeight)
    local windowW, windowH = Scaling.getWindowDimensions()
    return (windowW - elementWidth) / 2, (windowH - elementHeight) / 2
end

function Scaling.getRelativePosition(xPercent, yPercent)
    local windowW, windowH = Scaling.getWindowDimensions()
    return windowW * xPercent, windowH * yPercent
end

return Scaling
