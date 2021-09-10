const { time } = require('console');
const { TwitterClient } = require('twitter-api-client');

const twitterClient = new TwitterClient({
    apiKey: process.env.TWITTER_API_KEY,
    apiSecret: process.env.TWITTER_API_SECRET,
    accessToken: process.env.TWITTER_ACCESS_TOKEN,
    accessTokenSecret: process.env.TWITTER_ACCESS_SECRET,
});
const headers = {
  'Content-Type': 'application/json',
}

let now = ~~(Date.now() / 1000)

async function loadTweets() {
  let body = {};
  const result = await twitterClient.accountsAndUsers.usersSearch({
      q: process.env.TWITTER_USER
  })
  if (result.length == 0) {
    statusCode = 404
    body.error = "Not found!"
  } else {
    const { id, name, screen_name, url, profile_image_url_https, profile_banner_url } = result[0];
    body.user = { id, name, screen_name, url, profile_image_url_https, profile_banner_url }
    console.log("User found", {id, name, screen_name })
    const tweets = await twitterClient.tweets.statusesUserTimeline({
      screen_name,
      trim_user: true,
      exclude_replies: true,
      include_rts: true,
      count: 200
    })
    console.log("tweets found", tweets.length);
    body.tweets = tweets
  }
  return body
}

let cached = {};

module.exports.handler = async (event) => {
    console.log('Getting user info');
    let statusCode = 200;
    try {
      if (~~(Date.now() / 1000) - now >= 60*15 || !cached.user){
        cached = await loadTweets()
        now = ~~(Date.now() / 1000)
      } else {
        console.log("Using cached result")
      }
      
    } catch(err) {
      statusCode = 500
      body.error = err
    }

    return {
      statusCode,
      headers,
      body: JSON.stringify(cached),
    }
  }
  