# 4.13.0

* Updating the `Archives#create` method to allow `quantization_parameter` as an option, and the `WebSocket#connect`  method to allow `bidirectional` as an option. See [#290](https://github.com/opentok/OpenTok-Ruby-SDK/pull/290)

# 4.12.0

* Updating the `Archives#create` method to allow `max_bitrate` as an option. See [#288](https://github.com/opentok/OpenTok-Ruby-SDK/pull/288)

# 4.11.0

* Updating client token creation to use JWTs by default. See [#287](https://github.com/opentok/OpenTok-Ruby-SDK/pull/274)

# 4.9.0

* Adds the `publisheronly` role for client token creation. See [#272](https://github.com/opentok/OpenTok-Ruby-SDK/pull/272)

# 4.8.1

* Fixes a bug with the `Archives#create` method. See [#269](https://github.com/opentok/OpenTok-Ruby-SDK/pull/269) and [#270](https://github.com/opentok/OpenTok-Ruby-SDK/pull/270)

# 4.8.0

* Add support for Captions API [#267](https://github.com/opentok/OpenTok-Ruby-SDK/pull/267)

# 4.7.1

* Updates docs comments for `Broadcasts` and `Sip` [#266](https://github.com/opentok/OpenTok-Ruby-SDK/pull/266)

# 4.7.0

* Adds support for the End-to-end encryption (E2EE) feature [#259](https://github.com/opentok/OpenTok-Ruby-SDK/pull/259)
* Implements Auto-archive improvements [#262](https://github.com/opentok/OpenTok-Ruby-SDK/pull/262)
* Updates the README to explain appending a custom value to the `UserAgent` header [#263](https://github.com/opentok/OpenTok-Ruby-SDK/pull/263)

# 4.6.0

* Adds functionality for working with the Audio Connector feature [#247](https://github.com/opentok/OpenTok-Ruby-SDK/pull/247)

# 4.5.1

* Fixes issue with uninitialized constant by adding missing `require` statement [#256](https://github.com/opentok/OpenTok-Ruby-SDK/pull/256)
* Fixes RubyGems info by adding repo link to gemspec [#255](https://github.com/opentok/OpenTok-Ruby-SDK/pull/255)

Thanks to [`@sailor`](https://github.com/sailor) for the contributions! :raised_hands:

# 4.5.0

* Adds support for multiple archives and records feature [#248](https://github.com/opentok/OpenTok-Ruby-SDK/pull/248)
* Adds Experience Composer functionality [#249](https://github.com/opentok/OpenTok-Ruby-SDK/pull/249)
* Updates code comments to make explicit support for 1080p resolution for Archive and Broadcast [#246](https://github.com/opentok/OpenTok-Ruby-SDK/pull/246)
* Updates various other documentation/code comments [#250](https://github.com/opentok/OpenTok-Ruby-SDK/pull/250)

# 4.4.0

* Implements DVR Pause/Resume and HLS Low-Latency options for Broadcasts [#243](https://github.com/opentok/OpenTok-Ruby-SDK/pull/243)

# 4.3.0

* Fixes an issue with `activesupport` [#238](https://github.com/opentok/OpenTok-Ruby-SDK/pull/238)
* Adds Force Mute feature [#233](https://github.com/opentok/OpenTok-Ruby-SDK/pull/233) and [#237](https://github.com/opentok/OpenTok-Ruby-SDK/pull/237)
* Adds Listing Live Streaming Broadcasts feature [#236](https://github.com/opentok/OpenTok-Ruby-SDK/pull/236). Thanks [@ihors-livestorm](https://github.com/ihors-livestorm)!
* Adds Selective Stream feature [#235](https://github.com/opentok/OpenTok-Ruby-SDK/pull/235)
* Adds Dial DTMF feature [#234](https://github.com/opentok/OpenTok-Ruby-SDK/pull/234)
* Adds Observe Force Mute flag to `Sip#dial` method [#232](https://github.com/opentok/OpenTok-Ruby-SDK/pull/232)
* Updates dependency version (`rake`) [#231](https://github.com/opentok/OpenTok-Ruby-SDK/pull/231)
* Adds Video Outbound flag to `Sip#dial` method [#227](https://github.com/opentok/OpenTok-Ruby-SDK/pull/227)

# 4.2.0

* A new `screenshare_type` parameter has been added to the layout options for archives and broadcasts, and this release makes it available in the SDK: https://tokbox.com/developer/rest/

# 4.1.2 Release

Fixes an issue with custom broadcast layout [#218](https://github.com/opentok/OpenTok-Ruby-SDK/pull/218)

# 4.1.1

Patch release to address issue corrected in [#214](https://github.com/opentok/OpenTok-Ruby-SDK/pull/214)

# Release v4.1.0

Add a `timeout_length` custom parameter that allows for the specification in seconds to wait before timing out for HTTP requests.

# Release 4.0.1

* Addresses an issue with invocation of `Set` in rubies v2.5
* Updates cassettes for request header changes in HTTParty

# Release 4.0.0

* Update gems (thanks [@fidalgo](https://github.com/fidalgo))
* Adds Ruby 2.7 support
* Removes Ruby 2.0 support. (For Ruby v2.0.0 please continue to use the OpenTok Ruby SDK v3.0.0.)
* Add layout to archive create (thanks [@mjthompsgb](https://github.com/mjthompsgb))
* Broadcast sample (thanks [@IGitGotIt](https://github.com/IGitGotIt))

# Release v3.1.0

Adds the following APIs (Thanks @JayTokBox  & [@normanargueta](https://github.com/normanargueta)):
- Force Disconnect
- Signaling
- Resolution Support
- Archive Layouts
- Broadcasting APIs
- Get & List streams

Updates and improves documentation! (Thanks [@jeffswartz](https://github.com/jeffswartz) )

# Release v3.0.3

Fixes internal logging and useragent issue

# Release v3.0.1

Upgraded dependency version ([#155](https://github.com/opentok/OpenTok-Ruby-SDK/pull/155))

# Release v3.0.0

Updating the version of httparty to 0.15. This is a breaking change because we require Ruby >= 2.0.0 now.


# Release v2.5.0

This updates includes the following change:

- [Add a dial method to initiate a SIP call](https://github.com/opentok/OpenTok-Ruby-SDK/pull/133)

Thanks @herestomwiththeweather!

# Release v2.4.1

This updates includes the following changes:

- [Support for the initial_layout_class_list feature of tokens](https://github.com/opentok/OpenTok-Ruby-SDK/pull/146)
- [Remove unnecessary info param from JS samples](https://github.com/opentok/OpenTok-Ruby-SDK/pull/147)

# Release v2.4.0

This updates includes the following changes:

- [Adds support for filtering archives by session ID](https://github.com/opentok/OpenTok-Ruby-SDK/pull/143)
- [Adds support for JWT `X-OPENTOK-AUTH` header, replacing the deprecated `X-TB-PARTNER-AUTH` header](https://github.com/opentok/OpenTok-Ruby-SDK/pull/134)
- [Updates the REST API endpoint URL to use `/project/` replacing the deprecated `/partner/`](https://github.com/opentok/OpenTok-Ruby-SDK/pull/129)

As well as:

- Updates JS code in samples to use latest API and best practices ([#140](https://github.com/opentok/OpenTok-Ruby-SDK/pull/140) and [#144](https://github.com/opentok/OpenTok-Ruby-SDK/pull/144))
- Removes generated HTML docs from this repo
- Updates documentation

# Release v2.4.0.beta.1

This update includes support for the `initial_layout_class_list` feature of tokens.

# Release v2.3.4

This update addresses an issue with loading the opentok gem in certain Rails based projects. (see: [#109](https://github.com/opentok/OpenTok-Ruby-SDK/issues/109), [#113](https://github.com/opentok/OpenTok-Ruby-SDK/pull/113). thanks [@LuckDragon82](https://github.com/LuckDragon82)!)

# Release v2.3.3

This release adds an internal option on the OpenTok initializer used to customize the User Agent string. ([#108](https://github.com/opentok/OpenTok-Ruby-SDK/pull/108))

# Release v2.3.2

This release fixes an issue where connection timeouts are too aggressive. It doubles the time allowed while also only counting the time it takes for TCP connect to finish, not the entire HTTP response to be received ([#106](https://github.com/opentok/OpenTok-Ruby-SDK/pull/106) thanks [@dramalho](https://github.com/dramalho))

# Release v2.3.0

New archiving features:
-  Automatically archived sessions -- See the `:archive_mode` option of the `OpenTok#create_session()` method.
-  Audio-only or video-only archives -- See the `:has_audio` and `:has_video` parameters of the `OpenTok#archives.create()` method.
-  Individual archiving -- See the `:output_mode` parameter of the `OpenTok#archives.create()` method.
-  Paused archives -- When no clients are publishing to a session being archived, its status changes to "paused". See `Archive#status`.

Other improvements:
-  Adds default HTTP timeout for requests ([#78](https://github.com/opentok/OpenTok-Ruby-SDK/pull/78) thanks [@dramalho](https://github.com/dramalho))
-  Fixes Archiving sample app ([#96](https://github.com/opentok/OpenTok-Ruby-SDK/pull/96) thanks [@matsubo](https://github.com/matsubo))

# Release v2.2.4

-  Ruby 2.2.0 compatibility (thanks [@superacidjax](https://github.com/superacidjax)) [#80](https://github.com/opentok/OpenTok-Ruby-SDK/pull/80)
-  Uses updated REST API for `archives.create` and `archives.stop_by_id` [#49](https://github.com/opentok/OpenTok-Ruby-SDK/issues/49) [#88](https://github.com/opentok/OpenTok-Ruby-SDK/issues/88)
-  Adds `rake console` task for gem authors [#91](https://github.com/opentok/OpenTok-Ruby-SDK/pull/91)

# Release v2.2.3

This version fixes a bug related to users on Windows receiving an `OpenTokAuthenticationError` exception because of a bug in an older version of the `httparty` gem. See [#60](https://github.com/opentok/OpenTok-Ruby-SDK/issues/60)

# Release v2.2.2

The default setting for the `create_session()` method is to create a session with the media mode set
to relayed. In previous versions of the SDK, the default setting was to use the OpenTok Media Router
(media mode set to routed). In a relayed session, clients will attempt to send streams directly
between each other (peer-to-peer); if clients cannot connect due to firewall restrictions, the
session uses the OpenTok TURN server to relay audio-video streams.

# Release v2.2.0

This version of the SDK includes support for working with OpenTok 2.0 archives. (This API does not
work with OpenTok 1.0 archives.)

Note also that the `options` parameter of the `OpenTok.create_session()` method has a `media_mode`
property instead of a `p2p` property.

# v0.1.3

Fixes issues:

- [#48](https://github.com/opentok/OpenTok-Ruby-SDK/issues/48) - OpenTokException given invalid number or parameters
