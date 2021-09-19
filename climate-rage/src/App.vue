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
}
body {
  background: url('~@/assets/stripes.png') repeat-y; 
  -webkit-background-size: contain;
  -moz-background-size: contain;
  -o-background-size: contain;
  background-size: contain;
}
@font-face {
  font-family: 'Apocalypse Now';
  src: url('~@/assets/apocalypse-now.ttf');
}
</style>
