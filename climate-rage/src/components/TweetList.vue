<template>
  <div>
    <b-jumbotron header="#ClimateCrisis" lead="Meidän tulee jättää tuleville sukupolville elinkelpoinen planeetta!">
    </b-jumbotron>
    <b-container>
      <b-skeleton-wrapper :loading="isLoading">
        <template #loading>
          <b-row v-for="tweet in tweets" v-bind:key="tweet.id" class="justify-content-md-center" align-v="center">
            <b-col cols="2">
              <b-spinner style="width: 3rem; height: 3rem;" type="grow"></b-spinner>
            </b-col>
            <b-col sm="10" md="8" lg="6">
              <blockquote class="twitter-tweet">
                <b-skeleton width="85%"></b-skeleton>
                <b-skeleton width="55%"></b-skeleton>
                <b-skeleton width="70%"></b-skeleton>
                <b-skeleton class="skeleton-signature" width="45%"></b-skeleton>
              </blockquote>
            </b-col>
          </b-row>
        </template>
        <b-row v-for="tweet in tweets" v-bind:key="tweet.id" class="justify-content-md-center" align-v="center">
          <b-col cols="2">
            <b-img :src="user.profile_image_url_https" class="profile-pic" rounded="circle"></b-img>
          </b-col>
          <b-col sm="10" md="8" lg="6">
            <blockquote class="twitter-tweet">
              <p dir="ltr" class="tweet">
                {{ tweet.text | hideUrls }}
              </p>
              <p v-if="tweet.entities.media">
                <b-img
                  v-for="pick in tweet.entities.media"
                  v-bind:key="pick.id_str"
                  :src="pick.media_url_https"
                  fluid-grow
                ></b-img>
              </p>
              <p>
                <span v-for="mention in tweet.entities.user_mentions" v-bind:key="mention.screen_name">
                  <a :href="`https://twitter.com/${mention.screen_name}`" target="_blank">
                    {{mention.name}} (@{{mention.screen_name}})
                  </a>
                  &nbsp;
                </span>
              </p>
              <p>
                <span v-for="link in tweet.entities.urls" v-bind:key="link.expanded_url">
                  <a :href="link.expanded_url" target="_blank">
                    {{link.display_url}}&nbsp;
                    <b-icon icon="box-arrow-in-up-right"></b-icon>
                  </a>
                  &nbsp;
                </span>
              </p>
              <div class="author">
                &mdash; @{{ user.screen_name }} <a :href="`https://twitter.com/i/web/status/${tweet.id}`" target="_blank">{{ tweet.created_at | formatDate }}</a>
              </div>
            </blockquote> 
          </b-col>
        </b-row>
      </b-skeleton-wrapper>
    </b-container>
    
  </div>
</template>
<script>
import moment from 'moment'

export default {
  name: 'TweetList',
  components: {
  },
  props: {
    screenName: String,
    hashTags: Array
  },
  data() {
        return {
          tags: [
              "ilmastokriisi",
              "ClimateCrisis",
              "elokapina",
              "nytOnPakko",
              "IlmastonMuutos",
          ]
        }
 
  },

  computed:{
    isLoading: function(){
      return this.$store.getters.loading
    },
    tweets: function(){
      return this.$store.getters.tweetsWithHashtags(this.tags)
    },
    user: function(){
      return this.$store.getters.userData
    }
  },
  filters: {
    formatDate: function(value) {
      if (value) {
        return moment(String(value)).format('YYYY-MM-DD hh:mm')
      }
    },
    hideUrls: (text) => {
      return text.replace(/(?:https?|ftp):\/\/[\n\S]+/g, '');
    }
  },

  beforeMount: function() {
    this.$store.dispatch('loadHighlights')
  }
}


</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h1 > a {
  color: #f5f5f5;
  text-shadow: 0px -2px 4px crimson, 0px -2px 10px #FF3, 0px -10px 20px         #F90, 0px -20px 40px #C33;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}

img.profile-pic {
  border-radius: 50%;
}
.jumbotron p {
  background-color: white;
  filter: drop-shadow(0px 0px 0.75rem white);
}

.twitter-tweet img {
  border-radius: 15px;
  filter: drop-shadow(7px 7px 0.75rem darkgray);
  max-width: 50%;
  height: auto;
}
a {
  text-decoration: none;
}
pre  {
  text-align: left;
}
p.tweet {
  font-size: 1.2em;
}
div.author {
  text-align: right;
  padding-right: 5px;
}
.twitter-tweet {
	position: relative;
	border: 2px solid #6bb4bb;
	border-radius: 1.4em;
  background-color: white;
  /*box-shadow: 10px 10px 5px darkgray;*/

  filter: drop-shadow(7px 7px 0.75rem darkgray);
  padding: .5em;
  margin-bottom: 2em;
}

.twitter-tweet:after {
	content: '';
	position: absolute;
	left: 0;
	top: 50%;
	width: 0;
	height: 0;
	border: 31px solid transparent;
	border-right-color: #00aabb;
	border-left: 0;
	border-bottom: 0;
	margin-top: -15.5px;
	margin-left: -31px;
}

.sceleton-signature {
  margin-left: 65%;
}
</style>
