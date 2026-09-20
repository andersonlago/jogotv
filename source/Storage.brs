' Camada de Armazenamento Local (roRegistrySection) para Kurions
' Permite salvar e recuperar o progresso dos episódios e configurações

function GetStorage() as Object
    return {
        secName: "KurionsApp",

        ' Salva o progresso em segundos e duração total
        saveProgress: function(episodeId as String, position as Integer, duration as Integer)
            sec = CreateObject("roRegistrySection", m.secName)
            sec.Write("pos_" + episodeId, position.toStr())
            sec.Write("dur_" + episodeId, duration.toStr())
            sec.Write("last_episode", episodeId)
            sec.Flush()
        end function,

        ' Retorna { position: Integer, duration: Integer, percent: Integer }
        getProgress: function(episodeId as String) as Object
            sec = CreateObject("roRegistrySection", m.secName)
            res = { position: 0, duration: 0, percent: 0 }
            if sec.Exists("pos_" + episodeId)
                res.position = Val(sec.Read("pos_" + episodeId))
            end if
            if sec.Exists("dur_" + episodeId)
                res.duration = Val(sec.Read("dur_" + episodeId))
            end if
            if res.duration > 0
                res.percent = Fix((res.position / res.duration) * 100)
                if res.percent > 100 then res.percent = 100
            end if
            return res
        end function,

        ' Marca como concluído
        markCompleted: function(episodeId as String)
            sec = CreateObject("roRegistrySection", m.secName)
            sec.Write("done_" + episodeId, "true")
            sec.Write("pos_" + episodeId, "0")
            sec.Flush()
        end function,

        isCompleted: function(episodeId as String) as Boolean
            sec = CreateObject("roRegistrySection", m.secName)
            return sec.Exists("done_" + episodeId) and sec.Read("done_" + episodeId) = "true"
        end function,

        getLastEpisode: function() as String
            sec = CreateObject("roRegistrySection", m.secName)
            if sec.Exists("last_episode")
                return sec.Read("last_episode")
            end if
            return "ep_1"
        end function,

        clearAllData: function()
            sec = CreateObject("roRegistrySection", m.secName)
            keys = sec.GetKeyList()
            for each k in keys
                sec.Delete(k)
            end for
            sec.Flush()
        end function,

        saveGameData: function(gems as Integer, maxHp as Integer, beamRange as Integer, potions as Integer, highestStage = 1 as Integer)
            sec = CreateObject("roRegistrySection", m.secName)
            sec.Write("game_gems", gems.toStr())
            sec.Write("game_max_hp", maxHp.toStr())
            sec.Write("game_beam_range", beamRange.toStr())
            sec.Write("game_potions", potions.toStr())
            sec.Write("game_highest_stage", highestStage.toStr())
            sec.Flush()
        end function,

        getGameData: function() as Object
            sec = CreateObject("roRegistrySection", m.secName)
            data = {
                gems: 0,
                maxHp: 3,
                beamRange: 1,
                potions: 0,
                highestStage: 1
            }
            if sec.Exists("game_gems") then data.gems = Val(sec.Read("game_gems"))
            if sec.Exists("game_max_hp") then data.maxHp = Val(sec.Read("game_max_hp"))
            if sec.Exists("game_beam_range") then data.beamRange = Val(sec.Read("game_beam_range"))
            if sec.Exists("game_potions") then data.potions = Val(sec.Read("game_potions"))
            if sec.Exists("game_highest_stage") then data.highestStage = Val(sec.Read("game_highest_stage"))
            return data
        end function
    }
end function
