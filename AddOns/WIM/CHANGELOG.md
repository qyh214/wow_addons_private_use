# WIM

## [3.10.9](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.10.9) (2023-02-26)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.10.8...3.10.9) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Fix #15, NewcomerChat was not being handled.  
- Fix #5, clicking names in chat window throwing errors.  
- Remove old source file no longer used.  
- Stop using ChatThrottleLib. Normal chat messages should always be handled normally. Only addon messages should be conscious of throttling. Fixes #33  
- Merge branch 'master' of https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger  
- Increased BNet message length to 800 characters. #30  
