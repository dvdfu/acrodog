package.path = '?/?.lua;'..package.path
package.path = 'modules/?/?.lua;'..package.path
package.path = 'modules/hump/?.lua;'..package.path
package.path = 'modules/love-misc-libs/?/?.lua;'..package.path

function love.conf(t)
    t.window.title = ''
    t.window.fullscreen = false
    t.window.resizable = false
    t.window.vsync = true
    t.window.width = 768
    t.window.height = 480
end
