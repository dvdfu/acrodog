package.path = '?/?.lua;'..package.path
package.path = 'modules/?/?.lua;'..package.path
package.path = 'modules/hump/?.lua;'..package.path
package.path = 'modules/love-misc-libs/?/?.lua;'..package.path

function love.conf(t)
    t.window.title = ''
    t.window.fullscreen = false
    t.window.resizable = false
    t.window.vsync = true
    t.window.width = 384*2
    t.window.height = 240*2
end
