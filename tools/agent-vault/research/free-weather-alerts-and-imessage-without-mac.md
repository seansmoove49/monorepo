# Free weather alerts and iMessage with the Mac off

Researched 2026-11-03 for a weekly NFL game-weather alert. Nothing was built, signed up for or sent, so delivery is untested. Pricing and terms can change, so recheck them before relying on this.

## The job

A small script runs Saturday night and optionally Sunday morning. It reads the nflverse `games.csv`, gets Open-Meteo forecasts for about 10 outdoor stadiums, and sends a short summary to one US phone. That's about 8 messages a month.

## Recommendations

| Goal | Pick | Cost |
|---|---|---|
| Free and dependable | GitHub Actions in a private repo + Telegram bot | $0 |
| Free real iMessage, Mac off | GitHub Actions + messages.dev sandbox, with Telegram as fallback | $0, but a test tier from a small vendor |
| Real SMS | GitHub Actions + Twilio toll-free, then sole-proprietor 10DLC if rejected | About $2.25-2.45/month toll-free; about $3.25-3.45/month + $19.50 upfront for 10DLC |
| No third party | iPhone Shortcut (Time of Day automation) | $0, must be tested on the phone |

## Scheduler

GitHub Actions is the best fit.

| | GitHub Actions | Cloudflare Workers | AWS Lambda + EventBridge Scheduler | Google Apps Script |
|---|---|---|---|---|
| Free limits | Public: free on standard runners. Private: $12/month of compute, about 2,000 Linux minutes | 100k requests/day, 5 cron triggers, 10 ms CPU per run | 1M requests and 400k GB-seconds/month; 14M schedule invocations/month | 90 min/day trigger runtime, 100 email recipients/day, 20k URL fetches/day |
| Card needed | No | No, per Cloudflare's pricing page | Usually not at signup; long-term use needs a Paid plan | Not stated; inferred no |
| Python | Yes | Yes, but the CPU limit makes it risky | Yes | No, JS only |
| Timing | Can be delayed or dropped under load, especially at the top of the hour; supports an IANA `timezone` key | UTC only; no delivery guarantee stated | Time zones, retries and dead-letter queue | Randomized time within the chosen hour |
| Stops if inactive | Public: after 60 days. Private: no such rule stated | None stated | Free plan account closes at 6 months or when credits run out | None found |
| Setup | Low | Low in JS, uncertain in Python | Highest | Low, browser only |

- **Use a private repo:** GitHub states the 60-day inactivity shutoff for public repos only.
- **Schedule off the hour:** for example 8:47pm Saturday and 7:47am Sunday with `timezone: America/New_York`. The Sunday run also backs up a dropped Saturday run.
- **Cloudflare risk:** `games.csv` measured 2.19 MB, so parsing it in 10 ms of CPU looks unlikely. This is inferred, not tested.
- **CloudFront:** ruled out. It's a CDN and can't run scheduled jobs.
- **Limit of any cloud runner:** `data/raw` lives on the Mac, so the job can send weather but can't re-run the models unless it also rebuilds them.

## Real SMS

No free, reliable option was found.

| Option | Status | Verdict |
|---|---|---|
| Twilio trial | 100 SMS, expires after 30 days; 10DLC registration needs a paid account | Testing only |
| Twilio toll-free | $0 upfront, about $2.25-2.45/month. The $2.15 number price is from a secondary source, and approval for personal use is uncertain (inferred) | First paid choice |
| Twilio sole-proprietor 10DLC | $4.50 brand + $15 vetting upfront, about $3.25-3.45/month. Needs a working website, privacy policy, terms and opt-in description | Fallback |
| Amazon SNS / End User Messaging | No SMS free tier found; about $1-2/month for a number plus messages. Individual eligibility unconfirmed | Not free |
| TextBelt free key | About 1 text/day; reliability unknown, and shared cloud IPs could matter | Worth a test, not dependable |
| textbee | 300/month per the vendor; needs an Android phone with a SIM kept on | Only free SMS, if you have a spare Android |
| Carrier email gateways | AT&T ended June 17, 2025. Verizon's retirement is expected complete by March 31, 2027. T-Mobile reportedly ended December 2024 (vendor reports only) | Dead end |

Message cost for about 8 a month is about $0.10, or up to about $0.30 if each summary runs 2-3 segments.

## Other alert channels

| Option | Cost | Mac off | Schedules by itself | Notes |
|---|---|---|---|---|
| Telegram bot | Free | Yes | Yes | About 5 min setup; you must message the bot first. Closest free feel to a text |
| Pushover | 30-day trial, then $4.99 once per platform | Yes | Yes | Alert, not a thread |
| ntfy | Free | Yes | Yes | Fine on Android; docs call the iOS app buggy, and development paused. The topic name acts as a password |
| Discord webhook | No cost mentioned | Yes | Yes | Older threads say an active desktop client can suppress phone pushes |
| Email to Gmail | Free | Yes | Yes | Least like a text; Apps Script can send without an app password |
| Facebook Messenger | Free | Yes | No | See below |

**Messenger:** a bot can only message within 24 hours of your last message. Meta's docs say `CONFIRMED_EVENT_UPDATE`, `ACCOUNT_UPDATE` and `POST_PURCHASE_UPDATE` tags return an error from April 27, 2026. A third-party blog reports a 7-day window for chats started from ads, which isn't useful here and wasn't confirmed on Meta's pages.

## iMessage with the Mac off

Apple has no public send API that we could find. Vendors say none exists, though one WebProNews report and one Dutch article hint at new agent access, with no Apple documentation found.

| Option | Free | Mac off | Real iMessage | Reliability | Account/ToS risk | Setup |
|---|---|---|---|---|---|---|
| **messages.dev sandbox** | Yes: 50/day, no card, no expiry documented | Yes | Yes per vendor, shared line, mechanism undisclosed | Unknown; no SLA or independent reviews found | Low for your Apple ID (inferred, no sign-in in docs); vendor sees text | About 15 min |
| iPhone Shortcut, Send Message to self | Yes | Yes | Yes, but reportedly no alert | Medium to low; test while locked | None; Apple-supported | About 15 min |
| Shortcut + Show Notification only | Yes | Yes | No, local notification | Medium; locked fetch unconfirmed | None | About 10 min |
| Spare iPhone/iPad on a second Apple ID | If you own one | Yes, spare stays on | Yes (inferred) | Medium | Low | About 30 min |
| Hermes Agent + BlueBubbles | Yes | **No**, needs an always-on Mac | Yes | Depends on the Mac | Not assessed | Medium |
| Sendblue sandbox | $0, but "No outbound messaging" | Yes | N/A | N/A | N/A | Not viable |
| LoopMessage sandbox | $0 | Yes | Yes | You must text first; 24-hour window | Terms bar production use | Not viable |
| Linq sandbox | 7 days only | Yes | Yes | Inbound-first; may be simulated | Test only | Not viable |
| Blooio trial | 20 messages total, then $39+/month | Yes | Yes | About 10 weeks' worth | Low | Stopgap |
| OpenBubbles/rustpush | Yes, but needs a real Mac once or an always-on iPhone | Partly | Yes | No supported server mode found | Real: Apple-blocked precedent, account block possible | High |
| pypush | Yes | Yes | Not currently; removed during rewrite | Unstable | Same category | Not viable |
| GitHub Actions macOS runner | Minutes yes (private about 193 min/month) | Yes | No evidence it works | Very poor (inferred) | High (inferred): repeated new-device logins | Not viable |
| macOS VM/Hackintosh on Linux | Yes | Yes | Unreliable | Poor | License breach; ban warnings | High |
| Free-trial cloud Macs | No; about $0.99 for 24 hours (competitor source) | Yes | Unconfirmed | Ends with trial | Apple ID on a rented machine | Not viable |
| Google RCS test agent | Unconfirmed | Yes | No, RCS | iPhone test delivery unconfirmed | Agent approval rules | High |
| Apple Messages for Business | Provider may charge | Yes | Business chat | Customer starts the chat | Not meant for this | Not viable |

### messages.dev sandbox

Pricing page checked directly on 2026-11-03: sandbox free, 50 messages a day, no card; dedicated line $99/month.

Steps:
1. Create an account and open the Lines page.
2. Text the activation code from the iPhone to the sandbox number to pair it.
3. Store the API key as a GitHub Actions secret.
4. Send with `from` as the sandbox line and `to` as the paired number. The base is `https://api.messages.dev/v1/` with bearer auth; the exact send path is unconfirmed, so check the docs.
5. Fail the job on a non-2xx response, and optionally fall back to Telegram.
6. Save the shared number as a contact so messages aren't filtered as unknown (inferred).

Caveats:
- The docs recommend a dedicated line for production. No rule banning personal sandbox use was found.
- The terms promise no uptime and don't guarantee delivery.
- Free could end at any time, and other users' behavior can affect the shared line (inferred).
- The vendor can see message text.

### iPhone Shortcut

What's verified:
- Time of Day, Email and Message triggers can run automatically.
- "Allow Running When Locked" exists under Info > Privacy.
- iOS 26 uses Run Immediately and iOS 27 uses Confirm Before Run off, both with Show Compose Sheet off (third-party guide, updated Nov 1, 2026).

Problems:
- **Silent self-messages:** an April 2024 iOS 17 thread says automated iMessages to yourself are marked read with no alert. Check this on current iOS. Workarounds are a Show Notification action or a spare device on another Apple ID (inferred).
- **Green bubbles:** older threads report texts to your own number going as SMS; using the Apple ID email reportedly fixed it.
- **Locked phone:** a 2023 thread reports locked sends not firing, while an Oct 30, 2026 guide describes them working with no test results. An older report says a slow network call failed on lock.
- **After a restart:** data can stay locked until first unlock (third-party source).

GitHub can trigger it by emailing you, with an Email-trigger automation. Reports are mixed: one says iCloud fires within seconds, another found iCloud failing where Gmail worked.

### Why to avoid the rest

- **Reverse-engineered clients:** Apple blocked Beeper Mini in December 2023, citing fake credentials. OpenBubbles' FAQ says accounts may be blocked in rare cases. BrightBubbles was parked 2026-09-24. The Hermes rustpush plugin's setup is macOS-only and requires turning off Contact Key Verification.
- **Ban risk at scale:** Lindy reports a permanent, no-appeal ban in March 2026 after 10K messages in 12 hours through a Mac bridge. Two a week is nothing like that, but the rules are opaque.
- **Licensing:** the macOS Tahoe license is for Apple-branded systems, with VM copies only on Apple computers you own or control, and it bars relay-type use. iCloud terms bar automated access by scripts; whether that covers iMessage is inferred.
- **Hermes Agent:** iMessage support arrived in v0.9.0 (v2026.4.13), but it runs through BlueBubbles on an always-on Mac. Hermes settings come from search summaries of its docs.

## Still unconfirmed

- Whether the messages.dev sandbox has an expiry or inactivity rule, and how the sender appears on the phone.
- Whether iOS 26/27 still silences self-sent messages, and whether a locked Shortcut can fetch a URL.
- Typical GitHub schedule delays; GitHub only publishes the warning.
- Telegram and Pushover notification reliability (inferred good).
- Twilio's sole-proprietor fees on the original page (403) and its toll-free number price and carrier fees on an official page.
- TextBelt's paid price, free-limit basis and deliverability.
- T-Mobile's official gateway status. Google Fi, US Cellular and Boost reports conflict.
- Whether Lambda's allowance is permanent, and whether Python Workers is still in beta.
- RCS free tiers and iPhone test-device behavior.
- Vendor limits come mostly from vendors' own sites; Texting Blue and Linq limits weren't fully confirmed.

## Sources

### Schedulers
- [GitHub schedule event](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)
- [GitHub workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)
- [Cloudflare pricing](https://developers.cloudflare.com/workers/platform/pricing/)
- [Cloudflare limits](https://developers.cloudflare.com/workers/platform/limits/)
- [Cloudflare cron triggers](https://developers.cloudflare.com/workers/configuration/cron-triggers/)
- [Cloudflare Python Workers](https://developers.cloudflare.com/workers/languages/python/)
- [Cloudflare plans](https://workers.cloudflare.com/plans)
- [Lambda pricing](https://aws.amazon.com/lambda/pricing/)
- [EventBridge pricing](https://aws.amazon.com/eventbridge/pricing/)
- [EventBridge Scheduler](https://docs.aws.amazon.com/eventbridge/latest/userguide/using-eventbridge-scheduler.html)
- [AWS free plans](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier-plans.html)
- [AWS signup FAQ](https://aws.amazon.com/free/registration-faqs/)
- [Apps Script quotas](https://developers.google.com/apps-script/guides/services/quotas)
- [Apps Script triggers](https://developers.google.com/apps-script/guides/triggers/installable)

### SMS
- [Twilio trial](https://www.twilio.com/docs/usage/tutorials/how-to-use-your-free-trial-account)
- [Twilio US SMS pricing](https://www.twilio.com/en-us/sms/pricing/us)
- [Twilio sole proprietor](https://www.twilio.com/docs/messaging/compliance/a2p-10dlc/direct-sole-proprietor-registration-overview)
- [Twilio fee article](https://support.twilio.com/hc/en-us/articles/1260803965530)
- [Twilio vetting FAQ](https://support.twilio.com/hc/en-us/articles/11587910480155-A2P-10DLC-Campaign-Vetting-FAQ)
- [Twilio toll-free verification API](https://www.twilio.com/docs/messaging/api/tollfree-verification-resource)
- [Twilio toll-free price (secondary)](https://www.telphiconsulting.com/blog/twilio-phone-number-cost)
- [AWS messaging pricing](https://aws.amazon.com/end-user-messaging/pricing/)
- [SNS sandbox](https://docs.aws.amazon.com/sns/latest/dg/sns-sms-sandbox.html)
- [TextBelt](https://textbelt.com/)
- [TextBelt docs](https://docs.textbelt.com/)
- [TextBelt older post](https://www.indiehackers.com/product/textbelt)
- [textbee FAQ](https://textbee.dev/docs/faq)
- [AT&T notice](https://www.att.com/support/article/wireless/KM1061254/)
- [Verizon notice](https://www.verizon.com/support/vtext-vzwpix-shutdown/)
- [T-Mobile troubleshooting](https://www.t-mobile.com/support/devices/device-troubleshooting/messaging-and-email-troubleshooting)
- [Gateway tracker (vendor)](https://sigspan.com/carrier-gateway-shutdown)
- [Free SMS roundup](https://publicapis.io/blog/free-sms-apis)

### Other alert channels
- [Telegram bots intro](https://core.telegram.org/bots)
- [Telegram bot FAQ](https://core.telegram.org/bots/faq)
- [ntfy publish and limits](https://docs.ntfy.sh/publish/)
- [ntfy FAQ](https://docs.ntfy.sh/faq/)
- [ntfy known issues](https://docs.ntfy.sh/known-issues/)
- [ntfy iOS delay report](https://noted.lol/ntfy/)
- [Pushover pricing](https://pushover.net/pricing)
- [Discord webhooks](https://docs.discord.com/developers/resources/webhook)
- [Discord push thread](https://support.discord.com/hc/en-us/community/posts/360051267774-Request-Send-mobile-notifications-even-when-Windows-client-is-running-visible-and-active)
- [Gmail app passwords](https://support.google.com/mail/answer/185833)
- [Meta: Send a Message](https://developers.facebook.com/documentation/business-messaging/messenger-platform/send-messages)
- [Meta: Messenger Platform policy](https://developers.facebook.com/documentation/business-messaging/messenger-platform/policy.md)
- [Spur: 7-day window report](https://www.spurnow.com/fr/blogs/instagram-messenger-ads-7-day-messaging-window)

### iMessage: messages.dev
- [Full docs](https://messages.dev/llms-full.txt)
- [Pricing](https://messages.dev/pricing)
- [Terms](https://messages.dev/terms)
- [Volume limits](https://messages.dev/docs/scaling/limits)
- [SDK](https://github.com/messages-dev/sdk)

### iMessage: Shortcuts
- [Apple: add automations](https://support.apple.com/guide/shortcuts/add-automations-apdfbdbd7123/ios)
- [Apple: Shortcuts triggers](https://support.apple.com/en-ca/guide/shortcuts/apd932ff833f/ios)
- [Apple: personal automation intro](https://support.apple.com/guide/shortcuts/intro-to-personal-automation-apd690170742/ios)
- [iOS 26/27 troubleshooting](https://www.fwrdsms.com/blog/shortcuts-automation-not-running)
- [iOS 27 guide](https://techtiff.substack.com/p/iphone-text-message-automation)
- [Self-message marked read](https://discussions.apple.com/thread/255572589)
- [MacRumors self-message thread (search snippet only)](https://forums.macrumors.com/threads/message-sent-to-myself-via-shortcuts-action-does-not-show-as-a-new-message-notification-on-other-devices-any-tips-or-workarounds.2308537)
- [Locked send failure](https://discussions.apple.com/thread/255141835)
- [Slow call on lock](https://talk.macpowerusers.com/t/shortcut-wont-run-unless-iphone-is-unlocked/34878)
- [Green bubble to self](https://discussions.apple.com/thread/254261873)
- [Email trigger template](https://www.val.town/x/dcm31/iosEmailAutomation)
- [Email trigger report](https://discussions-jp-prz.apple.com/en/thread/255934170)

### iMessage: vendors
- [Sendblue pricing](https://www.sendblue.com/pricing)
- [Sendblue on no Apple API](https://www.sendblue.com/blog/imessage-api)
- [LoopMessage](https://loopmessage.com/)
- [LoopMessage sandbox](https://loopmessage.com/helpdesk/sandbox-environment)
- [Blooio pricing](https://blooio.com/pricing.md)
- [Linq sandbox](https://help.linqapp.com/what-is-sandbox-)
- [Linq hackathon page](https://linqapp.com/hackathon)
- [ZeroSettle comparison](https://zerosettle.io/blog/best-imessage-api-providers/)
- [Claw Messenger comparison](https://www.clawmessenger.com/compare/imessage-api)
- [WebProNews agent report](https://www.webpronews.com/apple-opens-imessage-to-first-third-party-ai-agent-as-agents-shift-from-chatbots-to-action-takers/)

### iMessage: reverse engineering and Hermes
- [OpenBubbles FAQ](https://openbubbles.app/docs/faq.html)
- [OpenBubbles quickstart](https://openbubbles.app/quickstart.html)
- [OpenBubbles repo](https://github.com/OpenBubbles/openbubbles-app)
- [OpenBubbles issue 222](https://github.com/OpenBubbles/openbubbles-app/issues/222)
- [BrightBubbles](https://github.com/gi-os/BrightBubbles)
- [pypush](https://github.com/JJTech0130/pypush)
- [Hermes rustpush plugin](https://hermes-agent.nousresearch.com/docs/plugins/hermes-rustpush-imessage)
- [Hermes BlueBubbles docs](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/bluebubbles)
- [Hermes v2026.4.13 release notes](https://newreleases.io/project/github/NousResearch/hermes-agent/release/v2026.4.13)
- [ToolNavs BlueBubbles guide](https://toolnavs.com/article/1753-how-to-configure-hermes-agent-bluebubbles)
- [Beeper block, MacRumors](https://www.macrumors.com/2023/12/10/apple-confirms-it-shut-down-beeper-mini/)
- [Lindy ban](https://www.lindy.ai/blog/imessage-api-three-rewrites-one-apple-ban-and-what-actually-works)

### Cloud Mac, licensing and others
- [macOS Tahoe license](https://www.apple.com/legal/sla/docs/macOSTahoe.pdf)
- [iCloud terms](https://www.apple.com/legal/internet-services/icloud/)
- [Sequoia VM and Apple ID](https://eclecticlight.co/2024/07/12/sequoia-virtualisation-and-apple-id/)
- [Parallels iMessage failure](https://forum.parallels.com/threads/imessage-sign-in-fails-on-sequoia.365289/)
- [Docker-OSX activation issue](https://github.com/sickcodes/Docker-OSX/issues/526)
- [MacinCloud alternatives (competitor)](https://rentamac.io/macincloud-alternatives/)
- [Google RBM test devices](https://developers.google.com/business-communications/rcs-business-messaging/guides/build/test)
- [AWS RCS testing](https://docs.aws.amazon.com/sms-voice/latest/userguide/rcs-testing.html)
- [Apple Messages for Business FAQ](https://register.apple.com/resources/messages/messaging-documentation/faq)
