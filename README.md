Slack bot that posts a daily roundup of dumb holidays

Overengineered with fuzzy emoji-translating based on keywords

![](https://pbs.twimg.com/media/De93hOBVMAAwD_G.jpg)

# Setup

1. Create a Slack bot integration and acquire a bot token
1. Set `SLACK_BOT_TOKEN` and `CHANNEL` in `.env`
1. Invite your bot to `CHANNEL`
1. Setup a scheduler to run `ruby progam.rb` once a day
1. Enjoy your dumb holidays 