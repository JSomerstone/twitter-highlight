<template>
  <div id="app">
    <TweetList />
  </div>
</template>

<script>
import TweetList from './components/TweetList.vue'

export default {
  name: 'App',
  components: {
    TweetList
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  padding-top: 60px;
  background: url('~@/assets/stripes.png') repeat-y center center fixed; 
  -webkit-background-size: cover;
  -moz-background-size: cover;
  -o-background-size: cover;
  background-size: cover;
}
</style>
