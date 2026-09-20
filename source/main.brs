' Ponto de entrada do canal Roku
sub Main()
    ' Cria a tela SceneGraph
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.SetMessagePort(m.port)

    ' Cria e exibe a cena principal
    scene = screen.CreateScene("MainScene")
    screen.Show()

    ' Loop de eventos da aplicação para manter a cena ativa
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
