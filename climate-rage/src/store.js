import Vue from "vue";
import Vuex from "vuex";
import axios from "axios";

const API_URL = "https://by5b508f94.execute-api.eu-central-1.amazonaws.com/serverless_lambda_stage"
Vue.use(Vuex);

//const sample = require("./sample.json");
let state = {
    loading: false,
    user: { screen_name: "Loading", id: 0, name: ""},
    tweets: [],
}

let mutations = {
    setLoading( state, loadingState) {
        state.loading = Boolean(loadingState)
    },
    setUser(state, userData) {
        state.user = userData
    },
    setTweets(state, tweetList) {
        state.tweets = tweetList
    }
}
let m = {}
Object.keys(mutations).map((mutation) => { m[mutation] = mutation});

let actions = {
    async loadHighlights({commit}){
        commit(m.setLoading, true);
       
        // Call the API from here
        axios.get(API_URL+'/highligh')
            .then(function ({ data }) {
                
                commit(m.setUser, data.user);
                commit(m.setTweets, data.tweets);
            })
            .catch(function (error) {
                // handle error
                console.log(error);
            }).then(() => {
                commit(m.setLoading, false);
            })

    }
}
const store = new Vuex.Store({
    state,
    mutations,
    actions,
    getters: {
        loading: ({loading}) => loading,
        userData: ({user}) => user,
        tweets: ({tweets}) => tweets,
        tweetsWithHashtags: (state) => (hashtags) => {
            return state.tweets.filter( tweet => {
                return Boolean(tweet.entities.hashtags.length)
            })
            .filter( tweet => {
                return tweet.entities.hashtags.filter(({text}) => hashtags.includes(text)).length > 0
            });
        },
    }
});

export default store;