<template>
  <div>
    <app-header></app-header>

    <main role="main" class="container">
      <router-view></router-view>
    </main>

    <app-footer></app-footer>
  </div>
</template>

<script>
import { AppHeader, AppFooter } from "./shared/layouts";

export default {
  name: "app",
  components: {
    AppHeader,
    AppFooter
  }
};
</script>

<style>
</style>
