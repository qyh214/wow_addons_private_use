local _, MySlot = ...

local L = setmetatable({}, {
    __index = function(table, key)
        if key then
            table[key] = tostring(key)
        end
        return tostring(key)
    end,
})


MySlot.L = L

--
-- Use http://www.wowace.com/addons/myslot/localization/ to translate thanks
-- 
local locale = GetLocale()

if locale == 'enUs' then
L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = true
L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = true
L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = true
L["<- share your profile here"] = true
L["All slots were restored"] = true
L["Are you SURE to delete '%s'?"] = true
L["Are you SURE to import ?"] = true
L["Bad importing text [CRC32]"] = true
L["Bad importing text [TEXT]"] = true
L["Clear before Import"] = true
L["Close"] = true
L["DANGEROUS"] = true
L["Export"] = true
L["Feedback"] = true
L["Force Import"] = true
L["Ignore during Export"] = true
L["Ignore during Import"] = true
L["Ignore unattained pet [id=%s]"] = true
L["Ignore unknown macro [id=%s]"] = true
L["Ignore unlearned skill [id=%s], %s"] = true
L["Import"] = true
L["Import is not allowed when you are in combat"] = true
L["Key Binding"] = true
L["Macro %s was ignored, check if there is enough space to create"] = true
L["Main Action Bar Page"] = true
L["Minimap Icon"] = true
L["Myslot"] = true
L["Name of exported text"] = true
L["Open Myslot"] = true
L["Please type %s to confirm"] = true
L["Remove all Key Bindings"] = true
L["Remove all Macros"] = true
L["Remove everything in ActionBar"] = true
L["Rename"] = true
L["Skip bad CRC32"] = true
L["Stance Action Bar"] = true
L["Time"] = true
L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"
L["Try force importing"] = true
L["Unsaved"] = true
L["Use random mount instead of an unattained mount"] = true

elseif locale == 'deDE' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
--[[Translation missing --]]
--[[ L["All slots were restored"] = "All slots were restored"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to import ?"] = "Are you SURE to import ?"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [CRC32]"] = "Bad importing text [CRC32]"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [TEXT]"] = "Bad importing text [TEXT]"--]] 
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
--[[Translation missing --]]
--[[ L["Close"] = "Close"--]] 
--[[Translation missing --]]
--[[ L["DANGEROUS"] = "DANGEROUS"--]] 
--[[Translation missing --]]
--[[ L["Export"] = "Export"--]] 
--[[Translation missing --]]
--[[ L["Feedback"] = "Feedback"--]] 
--[[Translation missing --]]
--[[ L["Force Import"] = "Force Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unlearned skill [id=%s], %s"] = "Ignore unlearned skill [id=%s], %s"--]] 
--[[Translation missing --]]
--[[ L["Import"] = "Import"--]] 
--[[Translation missing --]]
--[[ L["Import is not allowed when you are in combat"] = "Import is not allowed when you are in combat"--]] 
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
--[[Translation missing --]]
--[[ L["Macro %s was ignored, check if there is enough space to create"] = "Macro %s was ignored, check if there is enough space to create"--]] 
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
--[[Translation missing --]]
--[[ L["Myslot"] = "Myslot"--]] 
--[[Translation missing --]]
--[[ L["Name of exported text"] = "Name of exported text"--]] 
--[[Translation missing --]]
--[[ L["Open Myslot"] = "Open Myslot"--]] 
--[[Translation missing --]]
--[[ L["Please type %s to confirm"] = "Please type %s to confirm"--]] 
--[[Translation missing --]]
--[[ L["Remove all Key Bindings"] = "Remove all Key Bindings"--]] 
--[[Translation missing --]]
--[[ L["Remove all Macros"] = "Remove all Macros"--]] 
--[[Translation missing --]]
--[[ L["Remove everything in ActionBar"] = "Remove everything in ActionBar"--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Skip bad CRC32"] = "Skip bad CRC32"--]] 
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
--[[Translation missing --]]
--[[ L["Time"] = "Time"--]] 
--[[Translation missing --]]
--[[ L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"--]] 
--[[Translation missing --]]
--[[ L["Try force importing"] = "Try force importing"--]] 
--[[Translation missing --]]
--[[ L["Unsaved"] = "Unsaved"--]] 
--[[Translation missing --]]
--[[ L["Use random mount instead of an unattained mount"] = "Use random mount instead of an unattained mount"--]] 

elseif locale == 'esES' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
L["All slots were restored"] = "Se han restaurado todos los huecos"
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
L["Are you SURE to import ?"] = "¿Seguro que quieres importarlo?"
L["Bad importing text [CRC32]"] = "Texto de importación incorrecto [CRC32]"
L["Bad importing text [TEXT]"] = "Texto de importación incorrecto [TEXT]"
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
L["Close"] = "Cerrar"
L["DANGEROUS"] = "PELIGROSO"
L["Export"] = "Exportar"
L["Feedback"] = "Comentarios"
L["Force Import"] = "Importación forzosa"
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
L["Ignore unlearned skill [id=%s], %s"] = "Ignora la facultad no obtenida [id=%s], %s"
L["Import"] = "Importar"
L["Import is not allowed when you are in combat"] = "No se puede importar mientras estás en combate"
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
L["Macro %s was ignored, check if there is enough space to create"] = "La macro %s se ha ignorado, comprueba si tienes suficiente espacio para crearla"
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
L["Myslot"] = "Myslot"
L["Name of exported text"] = "Nombre del texto exportado"
L["Open Myslot"] = "Abrir Myslot"
L["Please type %s to confirm"] = "Escribe %s para confirmar"
L["Remove all Key Bindings"] = "Borrar todos los atajos de teclado"
L["Remove all Macros"] = "Borrar todas las macros"
L["Remove everything in ActionBar"] = "Borrar todo sobre las barras de acción"
L["Rename"] = "Renombrar"
L["Skip bad CRC32"] = "Se salta CRC32 maligno"
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
L["Time"] = "Hora"
L["TOC_NOTES"] = "Myslot sirve para transferir opciones entre distintas cuentas. Comentarios a farmer1992@gmail.com"
L["Try force importing"] = "Intentar importación forzosa"
L["Unsaved"] = "No está guardado"
L["Use random mount instead of an unattained mount"] = "Usa una montura aleatoria en vez de una no disponible"

elseif locale == 'esMX' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
--[[Translation missing --]]
--[[ L["All slots were restored"] = "All slots were restored"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to import ?"] = "Are you SURE to import ?"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [CRC32]"] = "Bad importing text [CRC32]"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [TEXT]"] = "Bad importing text [TEXT]"--]] 
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
--[[Translation missing --]]
--[[ L["Close"] = "Close"--]] 
--[[Translation missing --]]
--[[ L["DANGEROUS"] = "DANGEROUS"--]] 
--[[Translation missing --]]
--[[ L["Export"] = "Export"--]] 
--[[Translation missing --]]
--[[ L["Feedback"] = "Feedback"--]] 
--[[Translation missing --]]
--[[ L["Force Import"] = "Force Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unlearned skill [id=%s], %s"] = "Ignore unlearned skill [id=%s], %s"--]] 
--[[Translation missing --]]
--[[ L["Import"] = "Import"--]] 
--[[Translation missing --]]
--[[ L["Import is not allowed when you are in combat"] = "Import is not allowed when you are in combat"--]] 
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
--[[Translation missing --]]
--[[ L["Macro %s was ignored, check if there is enough space to create"] = "Macro %s was ignored, check if there is enough space to create"--]] 
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
--[[Translation missing --]]
--[[ L["Myslot"] = "Myslot"--]] 
--[[Translation missing --]]
--[[ L["Name of exported text"] = "Name of exported text"--]] 
--[[Translation missing --]]
--[[ L["Open Myslot"] = "Open Myslot"--]] 
--[[Translation missing --]]
--[[ L["Please type %s to confirm"] = "Please type %s to confirm"--]] 
--[[Translation missing --]]
--[[ L["Remove all Key Bindings"] = "Remove all Key Bindings"--]] 
--[[Translation missing --]]
--[[ L["Remove all Macros"] = "Remove all Macros"--]] 
--[[Translation missing --]]
--[[ L["Remove everything in ActionBar"] = "Remove everything in ActionBar"--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Skip bad CRC32"] = "Skip bad CRC32"--]] 
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
--[[Translation missing --]]
--[[ L["Time"] = "Time"--]] 
--[[Translation missing --]]
--[[ L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"--]] 
--[[Translation missing --]]
--[[ L["Try force importing"] = "Try force importing"--]] 
--[[Translation missing --]]
--[[ L["Unsaved"] = "Unsaved"--]] 
--[[Translation missing --]]
--[[ L["Use random mount instead of an unattained mount"] = "Use random mount instead of an unattained mount"--]] 

elseif locale == 'frFR' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
--[[Translation missing --]]
--[[ L["All slots were restored"] = "All slots were restored"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to import ?"] = "Are you SURE to import ?"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [CRC32]"] = "Bad importing text [CRC32]"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [TEXT]"] = "Bad importing text [TEXT]"--]] 
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
--[[Translation missing --]]
--[[ L["Close"] = "Close"--]] 
--[[Translation missing --]]
--[[ L["DANGEROUS"] = "DANGEROUS"--]] 
--[[Translation missing --]]
--[[ L["Export"] = "Export"--]] 
--[[Translation missing --]]
--[[ L["Feedback"] = "Feedback"--]] 
--[[Translation missing --]]
--[[ L["Force Import"] = "Force Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unlearned skill [id=%s], %s"] = "Ignore unlearned skill [id=%s], %s"--]] 
--[[Translation missing --]]
--[[ L["Import"] = "Import"--]] 
--[[Translation missing --]]
--[[ L["Import is not allowed when you are in combat"] = "Import is not allowed when you are in combat"--]] 
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
--[[Translation missing --]]
--[[ L["Macro %s was ignored, check if there is enough space to create"] = "Macro %s was ignored, check if there is enough space to create"--]] 
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
--[[Translation missing --]]
--[[ L["Myslot"] = "Myslot"--]] 
--[[Translation missing --]]
--[[ L["Name of exported text"] = "Name of exported text"--]] 
--[[Translation missing --]]
--[[ L["Open Myslot"] = "Open Myslot"--]] 
--[[Translation missing --]]
--[[ L["Please type %s to confirm"] = "Please type %s to confirm"--]] 
--[[Translation missing --]]
--[[ L["Remove all Key Bindings"] = "Remove all Key Bindings"--]] 
--[[Translation missing --]]
--[[ L["Remove all Macros"] = "Remove all Macros"--]] 
--[[Translation missing --]]
--[[ L["Remove everything in ActionBar"] = "Remove everything in ActionBar"--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Skip bad CRC32"] = "Skip bad CRC32"--]] 
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
--[[Translation missing --]]
--[[ L["Time"] = "Time"--]] 
--[[Translation missing --]]
--[[ L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"--]] 
--[[Translation missing --]]
--[[ L["Try force importing"] = "Try force importing"--]] 
--[[Translation missing --]]
--[[ L["Unsaved"] = "Unsaved"--]] 
--[[Translation missing --]]
--[[ L["Use random mount instead of an unattained mount"] = "Use random mount instead of an unattained mount"--]] 

elseif locale == 'itIT' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
--[[Translation missing --]]
--[[ L["All slots were restored"] = "All slots were restored"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to import ?"] = "Are you SURE to import ?"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [CRC32]"] = "Bad importing text [CRC32]"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [TEXT]"] = "Bad importing text [TEXT]"--]] 
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
--[[Translation missing --]]
--[[ L["Close"] = "Close"--]] 
--[[Translation missing --]]
--[[ L["DANGEROUS"] = "DANGEROUS"--]] 
--[[Translation missing --]]
--[[ L["Export"] = "Export"--]] 
--[[Translation missing --]]
--[[ L["Feedback"] = "Feedback"--]] 
--[[Translation missing --]]
--[[ L["Force Import"] = "Force Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unlearned skill [id=%s], %s"] = "Ignore unlearned skill [id=%s], %s"--]] 
--[[Translation missing --]]
--[[ L["Import"] = "Import"--]] 
--[[Translation missing --]]
--[[ L["Import is not allowed when you are in combat"] = "Import is not allowed when you are in combat"--]] 
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
--[[Translation missing --]]
--[[ L["Macro %s was ignored, check if there is enough space to create"] = "Macro %s was ignored, check if there is enough space to create"--]] 
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
--[[Translation missing --]]
--[[ L["Myslot"] = "Myslot"--]] 
--[[Translation missing --]]
--[[ L["Name of exported text"] = "Name of exported text"--]] 
--[[Translation missing --]]
--[[ L["Open Myslot"] = "Open Myslot"--]] 
--[[Translation missing --]]
--[[ L["Please type %s to confirm"] = "Please type %s to confirm"--]] 
--[[Translation missing --]]
--[[ L["Remove all Key Bindings"] = "Remove all Key Bindings"--]] 
--[[Translation missing --]]
--[[ L["Remove all Macros"] = "Remove all Macros"--]] 
--[[Translation missing --]]
--[[ L["Remove everything in ActionBar"] = "Remove everything in ActionBar"--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Skip bad CRC32"] = "Skip bad CRC32"--]] 
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
--[[Translation missing --]]
--[[ L["Time"] = "Time"--]] 
--[[Translation missing --]]
--[[ L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"--]] 
--[[Translation missing --]]
--[[ L["Try force importing"] = "Try force importing"--]] 
--[[Translation missing --]]
--[[ L["Unsaved"] = "Unsaved"--]] 
--[[Translation missing --]]
--[[ L["Use random mount instead of an unattained mount"] = "Use random mount instead of an unattained mount"--]] 

elseif locale == 'koKR' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
--[[Translation missing --]]
--[[ L["All slots were restored"] = "All slots were restored"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to import ?"] = "Are you SURE to import ?"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [CRC32]"] = "Bad importing text [CRC32]"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [TEXT]"] = "Bad importing text [TEXT]"--]] 
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
--[[Translation missing --]]
--[[ L["Close"] = "Close"--]] 
--[[Translation missing --]]
--[[ L["DANGEROUS"] = "DANGEROUS"--]] 
--[[Translation missing --]]
--[[ L["Export"] = "Export"--]] 
--[[Translation missing --]]
--[[ L["Feedback"] = "Feedback"--]] 
--[[Translation missing --]]
--[[ L["Force Import"] = "Force Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unlearned skill [id=%s], %s"] = "Ignore unlearned skill [id=%s], %s"--]] 
--[[Translation missing --]]
--[[ L["Import"] = "Import"--]] 
--[[Translation missing --]]
--[[ L["Import is not allowed when you are in combat"] = "Import is not allowed when you are in combat"--]] 
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
--[[Translation missing --]]
--[[ L["Macro %s was ignored, check if there is enough space to create"] = "Macro %s was ignored, check if there is enough space to create"--]] 
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
--[[Translation missing --]]
--[[ L["Myslot"] = "Myslot"--]] 
--[[Translation missing --]]
--[[ L["Name of exported text"] = "Name of exported text"--]] 
--[[Translation missing --]]
--[[ L["Open Myslot"] = "Open Myslot"--]] 
--[[Translation missing --]]
--[[ L["Please type %s to confirm"] = "Please type %s to confirm"--]] 
--[[Translation missing --]]
--[[ L["Remove all Key Bindings"] = "Remove all Key Bindings"--]] 
--[[Translation missing --]]
--[[ L["Remove all Macros"] = "Remove all Macros"--]] 
--[[Translation missing --]]
--[[ L["Remove everything in ActionBar"] = "Remove everything in ActionBar"--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Skip bad CRC32"] = "Skip bad CRC32"--]] 
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
--[[Translation missing --]]
--[[ L["Time"] = "Time"--]] 
--[[Translation missing --]]
--[[ L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"--]] 
--[[Translation missing --]]
--[[ L["Try force importing"] = "Try force importing"--]] 
--[[Translation missing --]]
--[[ L["Unsaved"] = "Unsaved"--]] 
--[[Translation missing --]]
--[[ L["Use random mount instead of an unattained mount"] = "Use random mount instead of an unattained mount"--]] 

elseif locale == 'ptBR' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
--[[Translation missing --]]
--[[ L["All slots were restored"] = "All slots were restored"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
--[[Translation missing --]]
--[[ L["Are you SURE to import ?"] = "Are you SURE to import ?"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [CRC32]"] = "Bad importing text [CRC32]"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [TEXT]"] = "Bad importing text [TEXT]"--]] 
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
--[[Translation missing --]]
--[[ L["Close"] = "Close"--]] 
--[[Translation missing --]]
--[[ L["DANGEROUS"] = "DANGEROUS"--]] 
--[[Translation missing --]]
--[[ L["Export"] = "Export"--]] 
--[[Translation missing --]]
--[[ L["Feedback"] = "Feedback"--]] 
--[[Translation missing --]]
--[[ L["Force Import"] = "Force Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unlearned skill [id=%s], %s"] = "Ignore unlearned skill [id=%s], %s"--]] 
--[[Translation missing --]]
--[[ L["Import"] = "Import"--]] 
--[[Translation missing --]]
--[[ L["Import is not allowed when you are in combat"] = "Import is not allowed when you are in combat"--]] 
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
--[[Translation missing --]]
--[[ L["Macro %s was ignored, check if there is enough space to create"] = "Macro %s was ignored, check if there is enough space to create"--]] 
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
--[[Translation missing --]]
--[[ L["Myslot"] = "Myslot"--]] 
--[[Translation missing --]]
--[[ L["Name of exported text"] = "Name of exported text"--]] 
--[[Translation missing --]]
--[[ L["Open Myslot"] = "Open Myslot"--]] 
--[[Translation missing --]]
--[[ L["Please type %s to confirm"] = "Please type %s to confirm"--]] 
--[[Translation missing --]]
--[[ L["Remove all Key Bindings"] = "Remove all Key Bindings"--]] 
--[[Translation missing --]]
--[[ L["Remove all Macros"] = "Remove all Macros"--]] 
--[[Translation missing --]]
--[[ L["Remove everything in ActionBar"] = "Remove everything in ActionBar"--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Skip bad CRC32"] = "Skip bad CRC32"--]] 
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
--[[Translation missing --]]
--[[ L["Time"] = "Time"--]] 
--[[Translation missing --]]
--[[ L["TOC_NOTES"] = "Myslot is for transferring settings between accounts. Feedback farmer1992@gmail.com"--]] 
--[[Translation missing --]]
--[[ L["Try force importing"] = "Try force importing"--]] 
--[[Translation missing --]]
--[[ L["Unsaved"] = "Unsaved"--]] 
--[[Translation missing --]]
--[[ L["Use random mount instead of an unattained mount"] = "Use random mount instead of an unattained mount"--]] 

elseif locale == 'ruRU' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"--]] 
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
L["All slots were restored"] = "Все слоты восстановлены"
L["Are you SURE to delete '%s'?"] = "Вы УВЕРЕНЫ, что хотите удалить \"%s\"?"
L["Are you SURE to import ?"] = "Вы УВЕРЕНЫ, что хотите импортировать?"
--[[Translation missing --]]
--[[ L["Bad importing text [CRC32]"] = "Bad importing text [CRC32]"--]] 
--[[Translation missing --]]
--[[ L["Bad importing text [TEXT]"] = "Bad importing text [TEXT]"--]] 
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
L["Close"] = "Закрыть"
L["DANGEROUS"] = "ОПАСНО "
L["Export"] = "Экспорт"
L["Feedback"] = "Обратная связь"
L["Force Import"] = "Принудительно импортировать"
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
L["Ignore unlearned skill [id=%s], %s"] = "Игнорировать невыученные навыки [id=%s], %s"
L["Import"] = "Импорт"
--[[Translation missing --]]
--[[ L["Import is not allowed when you are in combat"] = "Import is not allowed when you are in combat"--]] 
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
--[[Translation missing --]]
--[[ L["Macro %s was ignored, check if there is enough space to create"] = "Macro %s was ignored, check if there is enough space to create"--]] 
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
L["Minimap Icon"] = "Иконка у мини-карты"
--[[Translation missing --]]
--[[ L["Myslot"] = "Myslot"--]] 
--[[Translation missing --]]
--[[ L["Name of exported text"] = "Name of exported text"--]] 
L["Open Myslot"] = "Открыть Myslot"
--[[Translation missing --]]
--[[ L["Please type %s to confirm"] = "Please type %s to confirm"--]] 
L["Remove all Key Bindings"] = "Удалить все привязки клавиш"
L["Remove all Macros"] = "Удалить все макросы"
L["Remove everything in ActionBar"] = "Удалить всё в панели действий"
L["Rename"] = "Переименовать"
--[[Translation missing --]]
--[[ L["Skip bad CRC32"] = "Skip bad CRC32"--]] 
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
L["Time"] = "Время"
L["TOC_NOTES"] = "Myslot предназначен для передачи настроек между аккаунтами. Обратная связь farmer1992@gmail.com"
--[[Translation missing --]]
--[[ L["Try force importing"] = "Try force importing"--]] 
L["Unsaved"] = "Не сохранять"
--[[Translation missing --]]
--[[ L["Use random mount instead of an unattained mount"] = "Use random mount instead of an unattained mount"--]] 

elseif locale == 'zhCN' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] 忽略不支持的按键绑定 [ %s ]，请通知作者 %s"
L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] 忽略不支持的按键类型 [ %s ]，请通知作者 %s"
L["<- share your profile here"] = "<- 分享你的配置"
L["All slots were restored"] = "所有按钮及按键邦定位置恢复完毕"
L["Are you SURE to delete '%s'?"] = "确定要删除 '%s'"
L["Are you SURE to import ?"] = "你确定要导入吗?"
L["Bad importing text [CRC32]"] = "导入文本校验不合法 [CRC32] 通常是没有复制完全"
L["Bad importing text [TEXT]"] = "导入文本校验不合法 [TEXT]"
L["Clear before Import"] = "导入前清空"
L["Close"] = "关闭"
L["DANGEROUS"] = "危险行为"
L["Export"] = "导出"
L["Feedback"] = "问题/建议"
L["Force Import"] = "强制导入"
L["Ignore during Export"] = "导出时忽略"
L["Ignore during Import"] = "导入时忽略"
L["Ignore unattained pet [id=%s]"] = "忽略未获得宠物 [id=%s]"
L["Ignore unknown macro [id=%s]"] = "忽略未知宏 [id=%s]"
L["Ignore unlearned skill [id=%s], %s"] = "忽略未掌握技能[id=%s]：%s"
L["Import"] = "导入"
L["Import is not allowed when you are in combat"] = "请在非战斗时候使用导入功能"
L["Key Binding"] = "快捷键"
L["Macro %s was ignored, check if there is enough space to create"] = "宏 [ %s ] 被忽略，请检查是否有足够的空格创建宏"
L["Main Action Bar Page"] = "主动作条"
L["Minimap Icon"] = "小地图图标"
L["Myslot"] = "Myslot"
L["Name of exported text"] = "导出文本的名字"
L["Open Myslot"] = "打开 Myslot"
L["Please type %s to confirm"] = "请输入 %s 来确认删除"
L["Remove all Key Bindings"] = "删除所有快捷键"
L["Remove all Macros"] = "删除所有宏"
L["Remove everything in ActionBar"] = "清空全部按键摆放"
L["Rename"] = "重命名"
L["Skip bad CRC32"] = "忽略CRC32错误"
L["Stance Action Bar"] = "姿态动作条"
L["Time"] = "时间"
L["TOC_NOTES"] = "Myslot可以帮助你在账号之间共享配置。反馈：farmer1992@gmail.com"
L["Try force importing"] = "尝试强制导入"
L["Unsaved"] = "未保存"
L["Use random mount instead of an unattained mount"] = "使用随机坐骑代替没有获得的坐骑"

elseif locale == 'zhTW' then
--[[Translation missing --]]
--[[ L["[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"] = "[WARN] Ignore slot due to an unknown error DEBUG INFO = [S=%s T=%s I=%s] Please send Importing Text and DEBUG INFO to %s"--]] 
L["[WARN] Ignore unsupported Key Binding [ %s ] , contact %s please"] = "[WARN] 忽略不支援的按鍵設置：K = [ %s ] ，請通知作者 %s"
L["[WARN] Ignore unsupported Slot Type [ %s ] , contact %s please"] = "[WARN] 忽略不支援的欄位設置：K = [ %s ] ，請通知作者 %s"
--[[Translation missing --]]
--[[ L["<- share your profile here"] = "<- share your profile here"--]] 
L["All slots were restored"] = "所有按鍵設定都已恢復完畢"
--[[Translation missing --]]
--[[ L["Are you SURE to delete '%s'?"] = "Are you SURE to delete '%s'?"--]] 
L["Are you SURE to import ?"] = "你確定要導入麼?"
L["Bad importing text [CRC32]"] = "錯誤的導入字串[CRC32]"
L["Bad importing text [TEXT]"] = "錯誤的導入字串[TEXT]"
--[[Translation missing --]]
--[[ L["Clear before Import"] = "Clear before Import"--]] 
L["Close"] = "關閉"
L["DANGEROUS"] = "危險"
L["Export"] = "導出"
L["Feedback"] = "反饋"
L["Force Import"] = "強制導入"
--[[Translation missing --]]
--[[ L["Ignore during Export"] = "Ignore during Export"--]] 
--[[Translation missing --]]
--[[ L["Ignore during Import"] = "Ignore during Import"--]] 
--[[Translation missing --]]
--[[ L["Ignore unattained pet [id=%s]"] = "Ignore unattained pet [id=%s]"--]] 
--[[Translation missing --]]
--[[ L["Ignore unknown macro [id=%s]"] = "Ignore unknown macro [id=%s]"--]] 
L["Ignore unlearned skill [id=%s], %s"] = "忽略未習得技能 [id=%s], %s"
L["Import"] = "導入"
L["Import is not allowed when you are in combat"] = "請在非戰鬥狀態時使用導入功能"
--[[Translation missing --]]
--[[ L["Key Binding"] = "Key Binding"--]] 
L["Macro %s was ignored, check if there is enough space to create"] = "忽略巨集 [%s] ，請檢查是否有足夠的欄位創建新巨集"
--[[Translation missing --]]
--[[ L["Main Action Bar Page"] = "Main Action Bar Page"--]] 
--[[Translation missing --]]
--[[ L["Minimap Icon"] = "Minimap Icon"--]] 
L["Myslot"] = "Myslot "
L["Name of exported text"] = "導出文本名"
L["Open Myslot"] = "開啟Myslot"
L["Please type %s to confirm"] = "請輸入 %s 以進行確認"
L["Remove all Key Bindings"] = "移除全部按鍵綁定"
L["Remove all Macros"] = "移除全部巨集"
L["Remove everything in ActionBar"] = "清除全部快捷列"
L["Rename"] = "重新命名"
L["Skip bad CRC32"] = "略過CRC32錯誤"
--[[Translation missing --]]
--[[ L["Stance Action Bar"] = "Stance Action Bar"--]] 
L["Time"] = "時間"
L["TOC_NOTES"] = "Myslot可以跨帳號綁定技能與按鍵設置。反饋通道：farmer1992@gmail.com"
L["Try force importing"] = "嘗試強制導入"
L["Unsaved"] = "未保存"
L["Use random mount instead of an unattained mount"] = "使用隨機座騎代替沒有獲得的座騎"

end

