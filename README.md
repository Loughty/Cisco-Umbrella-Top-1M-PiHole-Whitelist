# Cisco Umbrella Top 1M (PiHole)

The top 1 million of most used domains from Cisco Umbrella, but in a format that can be added on a PiHole.

If you use a lot of blacklists in your Pi-hole, you'll eventually run into the problem of having to whitelist several domains because you're getting a lot of false positives. Using a list of the most frequently used domains helps mitigate this problem.

Keep in mind that using the 1 million list as is can be more harmful than helpful, so I also created a 500K list and a 100K list based on that one. To see if any of these lists are suitable for you, you can check the ranking of a domain you're interested in, for example:

43, doubleclick.net
75170, who.int
800130, minergate.com

This shows that even the smallest 100K list will whitelist Google Ads, but will also allow the WHO webpage, and will block the cryptomining website. So yes, if ur purpuse is to block ads, this is not for you, but if you installed PiHole to block phishing websites for example, this can be usefull.
