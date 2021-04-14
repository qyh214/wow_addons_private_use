# <DBM> Pandaria

## [r140](https://github.com/DeadlyBossMods/DBM-MoP/tree/r140) (2021-03-09)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-MoP/compare/r139...r140) [Previous Releases](https://github.com/DeadlyBossMods/DBM-MoP/releases)

- TOC Bump  
- Fix #9 (#15)  
    * Fix #9  
    Invalid case of return to stone being called here. This is simply a case where a buff was cast, and should not refresh the timer, especially since other cases of return to stone uses a GUID clause.  
- Fix #6 (#14)  
    Variable timers should always be their lowest value, so remove 2.6 as molky reported.  
- Fixed/Updated Istrivial checks to use cores built in checks instead of hard coded (and incorrect) pre squish levels  
- LuaCheck cleanup (#13)  
- Merge pull request #12 from DeadlyBossMods/ci  
    Ci updates from master  
- Ci updates from master  
- Update CI  
- Update README.md  
- Delete .travis.yml  
- Create ci.yml  
- delete the now unused variable  
- Fixed icon marking on tortos, which has been broken for years when nit was ported over to prototype incorrectly. Also simplified it since it was grossly over complicated  
