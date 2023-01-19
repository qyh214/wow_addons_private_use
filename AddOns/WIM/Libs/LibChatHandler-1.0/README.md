# LibChatHandler-1.0 (WoW AddOn Library)

## Description
A MVC for chat event handling. Bring compatibility between chat related addons.

## Usage

To use the library, you must first create a delegate. Delegates monitor and process chat events. A delegate can be created or your existing object can be promoted to a delegate.
```lua
local lib = LibStub("LibChatHandler-1.0");
local delegate = lib:NewDelegate();
```
or
```lua
local MyAddon = {}
LibStub("LibChatHandler-1.0"):Embed(MyAddon);
```

## Delegate
A delegate listens for and manages whether or not an event is delivered, delayed, blocked, etc.
### RegisterChatEvent (eventName, [priority])
Register a chat event to listen for and manage.
```lua
delegate:RegisterChatEvent("CHAT_MSG_WHISPER")
```
When an event is received it will first see if a controller is in place:
```lua
function delegate:CHAT_MSG_WHISPER_CONTROLLER(ControllerEvent, arg1, ..., argN)

end
```
This method is similar to a basic event with the exception that a controller is provided. This controller can be used to control the delivery of the event. By default, an event is delivered unless a controller specifies otherwise.

Once the event clears a controller it is delivered (conditionally) to:
```lua
function delegate:CHAT_MSG_WHISPER(arg1, ..., argN)

end
```

### UnregisterChatEvent (eventName)
Unregister / no longer listen for specified event.

## ControllerEvent

### Allow()
Allow the event to continue to be processed/delivered. This is the default action.

### Block()
Stop processing event, do not deliver to Blizzard UI, remaining controllers or delegates. This could be used to block spam for example.

### BlockFromChatFrame()
Continue processing the event, but do not deliver it to the Blizzard UI. This is useful if you are listening for a particular message and want to execute an action against it, but do not want it to be displayed to the user.

### BlockFromDelegate(delegate)
If you are controlling more than one delegate, you can block the event from being delivered to a specific one.

### Suspend()
Continue to have the event processed by all controllers, but do not deliver the event yet. This is useful if you would like to do some other operation before delivering the event.

A use case (though not longer possible) would be to receive a whisper, but before delivering it, do a who lookup on the user and if the user is a level 1 character, block it, otherwise deliver it.

The controller must release a suspended event in order for it to be delivered.

```lua
local suspended;
function delegate:CHAT_MSG_WHISPER_CONTROLLER(ControllerEvent, arg1, ..., argN)
  controller:Suspend();
  suspended = ControllerEvent
end

--- ... do other work and when you're all done, release the

if (suspended) then
  suspended:Release();
end
```

### Release()
Release a suspended event.

## Example
In the following example, a whisper is received, it is not delivered to the Default Blizzard UI, but it is delivered to all listening delegates.

```lua
local lib = LibStub("LibChatHandler-1.0");
local delegate = lib:NewDelegate();

delegate:RegisterChatEvent("CHAT_MSG_WHISPER")

-- this function gets called first, the controller can be used to block messages, delay them etc.
function delegate:CHAT_MSG_WHISPER_CONTROLLER(ControllerEvent, arg1, ..., argN)
  ControllerEvent:BlockFromChatFrame()
end

-- once the even has been processed (and not blocked, it will be delivered here and to other delegates)
function delegate:CHAT_MSG_WHISPER(arg1, arg2, ..., argN)
  -- do something with event
end
```

## Disclaimer
> World of Warcraft© and Blizzard Entertainment© are all trademarks or registered trademarks of Blizzard Entertainment in the United States and/or other countries. These terms and all related materials, logos, and images are copyright © Blizzard Entertainment.