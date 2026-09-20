' Camada de Acesso a Dados (Local e futura API REST) para Kurions

function GetDataManager() as Object
    return {
        loadJsonFile: function(filePath as String) as Object
            raw = ReadAsciiFile(filePath)
            if raw <> ""
                parsed = ParseJson(raw)
                if parsed <> invalid
                    return parsed
                end if
            end if
            print "[DataManager] Falha ao ler ou parsear arquivo JSON: " + filePath
            return []
        end function,

        getEpisodes: function() as Object
            return m.loadJsonFile("pkg:/data/episodes.json")
        end function,

        getCharacters: function() as Object
            return m.loadJsonFile("pkg:/data/characters.json")
        end function,

        getKurions: function() as Object
            return m.loadJsonFile("pkg:/data/kurions.json")
        end function,

        getLore: function() as Object
            return m.loadJsonFile("pkg:/data/lore.json")
        end function,

        getEpisodeById: function(episodeId as String) as Object
            episodes = m.getEpisodes()
            for each ep in episodes
                if ep.id = episodeId then return ep
            end for
            return invalid
        end function
    }
end function
