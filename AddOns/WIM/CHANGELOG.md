# WIM

## [3.8.15](https://github.com/sylvanaar/wow-instant-messenger/tree/3.8.15) (2020-10-14)
[Full Changelog](https://github.com/sylvanaar/wow-instant-messenger/compare/3.8.14...3.8.15) [Previous Releases](https://github.com/sylvanaar/wow-instant-messenger/releases)

- Fix to GetBNGetGameAccountInfo for retail, it was throwing errors beccause it's possible for gameaccount to be nil, and old logic fell back to classic code, which is bad. instead if game account is nil we generate an empty table but continue to proceed on retail path, DO NOT TAG YET, needs more testing.  
- Bump retail TOC  
- ReglohPri\_Deprecated\_GuildRoster (#31)  
