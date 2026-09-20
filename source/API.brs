' Camada de Abstração de API REST e Serviços do Sistema para Kurions
' Suporta consumo de serviços HTTP remotos com fallback transparente para o cache/JSON local.

function GetAPIClient() as Object
    return {
        baseUrl: "https://api.kurions.local",
        dataManager: GetDataManager(),

        ' Verifica o status da conexão com a rede/internet
        isNetworkAvailable: function() as Boolean
            devInfo = CreateObject("roDeviceInfo")
            return devInfo.GetLinkStatus()
        end function,

        ' Retorna informações formatadas do dispositivo da Roku TV
        getDeviceInfo: function() as Object
            devInfo = CreateObject("roDeviceInfo")
            os = devInfo.GetOSVersion()
            osStr = "Roku OS"
            if os <> invalid and type(os) = "roAssociativeArray"
                majorStr = ""
                minorStr = ""
                buildStr = ""
                if os.major <> invalid then majorStr = os.major.toStr()
                if os.minor <> invalid then minorStr = os.minor.toStr()
                if os.build <> invalid then buildStr = os.build.toStr()
                osStr = majorStr + "." + minorStr + " b" + buildStr
            end if

            modelStr = devInfo.GetModel()
            dispMode = devInfo.GetDisplayMode()
            vidMode = devInfo.GetVideoMode()

            return {
                model: modelStr,
                version: osStr,
                displayMode: dispMode,
                videoMode: vidMode,
                isConnected: devInfo.GetLinkStatus()
            }
        end function,

        ' Obtenção do catálogo de episódios
        getEpisodes: function() as Object
            return m.dataManager.getEpisodes()
        end function,

        ' Obtenção dos personagens
        getCharacters: function() as Object
            return m.dataManager.getCharacters()
        end function,

        ' Obtenção da enciclopédia de Kurions
        getKurions: function() as Object
            return m.dataManager.getKurions()
        end function,

        ' Obtenção de lore e história
        getLore: function() as Object
            return m.dataManager.getLore()
        end function
    }
end function
