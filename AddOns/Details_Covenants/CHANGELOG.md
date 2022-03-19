##### v1.3.3 Update for 9.2

- - update `.toc` for 9.2

##### v1.3.2 Make covenant detection less aggressive

- make covenant detection less aggressive, now track only players in group

##### v1.3.1 Fix error with wrong GUID

- check is GUID is a player GUID
- send and show always correct info about your own covenant

##### v1.3.0 New covenant swap system

- remove caching for detected covenants, because of new covenant swap system

##### v1.2.1 Fix errors in Skada

- fix [#9](https://github.com/spromicky/Details_Covenants/issues/9) errors for Skada

##### v1.2.0 Ignore nickmames in Details!

- now you can ignore nicknames from Details. Use command `/dc ignore on` [#6](https://github.com/spromicky/Details_Covenants/issues/6)

##### v1.1.0
    
- add option to align covenant icon [#8](https://github.com/spromicky/Details_Covenants/issues/8). Now you can choose on which side of name covenant icon will be show.
- update checking for own messages
- update `.toc` for 9.1

##### v1.0.0

- other addons can acdess to covenants info (`_G.Oribos:getCovenantIconForPlayer(<playerName>)`)
- improve detections of character's covenants, now players with this addon share they covenants
- add commads to control chat log and print all collected data
- add spellId for venthyr protection warrior

##### v0.0.2

- implements Skada support as well

##### v0.0.1

- first version of addon